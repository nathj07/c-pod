require 'cgi'
# local requires
require "git_reporter"
require "email_reporter"
require "bugzilla_processor"
require "pivotal_processor"
require "jira_processor"

module Deploynotify

  #
  # Sends out deployment notification emails and automatically
  # updates Bugzilla and Pivotal Tracker with information from the
  # Git commit logs
  #
  # dependencies: grit, pivotal-tracker and pony
  #
  # @Author Peter Hulst
  #
  class BuildUpdateProcessor
    attr_reader :git, :pivotal, :bugzilla, :jira, :reporter, :build_number

    # constructor
    # @param build_revision   git revision sha for current build
    # @param build_num        current build number
    # @param repo_path        path to git repository for project
    # @param config_path      path to deploy_notify_cfg.yml config file
    # @param prev_build       optional, previous build number to run deploy notifications on
    def initialize(build_revision, build_num, repo_path, config_path, prev_build = nil)
      # this heavy initializer isn't a great idea for testing. Should rework
      # this to make rspec tests with mocks easier.
      @init_success = false
      send_email_on_error do
        @build_number = build_num.to_i

        # read configuration from config file
        config = YAML.load_file(config_path)
        @dry_run = config['dry_run']
        @project_name = config['project_name']

        puts "DRYRUN: NOT ACTUALLY UPDATING BUGZILLA, PIVOTAL or JIRA" if @dry_run

        # create reporter instance
        email_from = config['email']['from']
        email_notify_list = config['email']['notify_list']
        @reporter = EmailReporter.new(@dry_run, email_from, email_notify_list)

        # create bugzilla object and log in
        bugzilla_user = config['bugzilla']['user']
        bugzilla_pwd  = config['bugzilla']['passwd']
        @bugzilla = BugzillaProcessor.new(@reporter, @dry_run)
        @bugzilla.login(bugzilla_user, bugzilla_pwd)

        # create pivotal object and log in
        pivotal_project_ids = config['pivotal']['project_ids']
    	  pivotal_api_token = config['pivotal']['api_token']
        @pivotal = PivotalProcessor.new(@reporter, @dry_run)
        @pivotal.login(pivotal_api_token, pivotal_project_ids)

        # create jira object and log in
        jira_user = config['jira']['user']
        jira_pwd  = config['jira']['passwd']
        @jira = JiraProcessor.new(@reporter, @dry_run)
        @jira.login(jira_user, jira_pwd)

        # create GitReporter object
        @git = GitReporter.new(repo_path, build_revision, prev_build, @dry_run)
        @init_success = true
      end
    end

    # does all the processing and reporting
    def process_all
      if @init_success 
        send_email_on_error do
          @git.get_commits

          # notify authors of invalid tasks
          notify_invalid_tasks

          # update bug reports
          @bugzilla.update_bug_reports(completed_only(@git.bugs, true), @build_number)

          # update all Pivotal Tracker stories
          @pivotal.update_pivotal_stories(completed_only(@git.pivotal_stories, true), @build_number)

          # update all Jira issues
          @jira.update_jira_issues(completed_only(@git.jira_issues, true), @build_number)

          # send email report with summary
          report = generate_report
          @reporter.email_report(@project_name, @build_number, report)
          puts "\n\n#{report}"
        end
      end
    end

    # runs a block of code passed in and sends out an email notification to deploy@blurb.com if it fails.
    # Email address is hardcoded as it's not guaranteed that the configuration was succesfully read. 
    def send_email_on_error
      begin
        yield 
      rescue => err
        if !@dry_run && !@reporter.nil?
          stack = caller.join("\n")
          @reporter.email_message("ACTION REQUIRED: deployment notification script failed", "#{err.inspect}\nstacktrace:\n#{stack}", 'deploy@blurb.com')
        else
          puts "DEPLOYMENT NOTIFICATION SCRIPT FAILED!"
          puts err.to_s
        end
      end
    end
    
    #
    # Notifies authors of git commits of invalid bug/story IDs
    #
    def notify_invalid_tasks
      @git.invalid_tasks.each do |t|
          @reporter.notify_bad_task(t)
        end
    end

    #
    # generates and sends an email report with all updates
    def generate_report
      msg = ""

      # first, report completed Jira issues
      completed_issues = completed_only(@git.jira_issues, true)
      if (completed_issues.length > 0)
        msg << "<b>The following Jira issues are delivered in this build:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(completed_issues)
      end

      # first, report completed Pivotal stories
      completed_stories = completed_only(@git.pivotal_stories, true)
      if (completed_stories.length > 0)
        msg << "<b>The following stories are delivered in this build:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(completed_stories)
      end

      # then, report resolved bugs
      # first, report completed Pivotal stories
      completed_bugs = completed_only(@git.bugs, true)
      if (completed_bugs.length > 0)
        msg << "<b>The following bugs have been fixed in this build:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(completed_bugs)
      end

      # then report other commits not associated to a specific story/bug
      if (@git.unmatched.length > 0)
        msg << "<b>The following commits were not part of a specific bug or story:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(@git.unmatched)
      end

      # report commits for unfinished jira issues
      incomplete_issues = completed_only(@git.jira_issues, false)
      if (incomplete_issues.length > 0)
        msg << "<b>Commits for Jira issues still in development:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(incomplete_issues)
      end

      # report commits for unfinished stories
      incomplete_stories = completed_only(@git.pivotal_stories, false)
      if (incomplete_stories.length > 0)
        msg << "<b>Commits for Pivotal stories still in development:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(incomplete_stories)
      end

      # report commits for unfinished bugs
      partial_bug_fixes = completed_only(@git.bugs, false)
      if (partial_bug_fixes.length > 0)
        msg << "<b>Other partial fixes for bugs:\n"
        msg << "------------------------------------------------------------------</b>\n"
        msg << report_tasks(partial_bug_fixes)
      end
      msg
    end

    # returns a list of only completed tasks or only uncompleted tasks, based on
    # value passed in
    def completed_only(tasks, completed)
      tasks.select do |task|
        completed ? task[:completed] : !task[:completed]
      end
    end

    # formatting for task
    def report_tasks(track_list)
      msg = ""
      track_list.each do |t|
        last_commit = t[:commits].last
        last_commit_author = last_commit[:author]
        if (t[:task_num])
          msg << "#{task_link(t)} by #{last_commit_author}\n"
          msg << "  title: #{t[:task_name]}\n"
        else
          msg << "by #{last_commit[:author]}\n"
        end
        t[:commits].each do |commit|
          datetime = commit[:date].strftime("on %m/%d/%Y at %I:%M%p")
          commit_msg = CGI.escapeHTML(commit[:message])
          msg << "  commit msg: #{commit_msg} - #{datetime}"
          if commit[:author] != last_commit_author
            # this commit was done by a different author, make sure to mention it
            msg << " (by #{commit[:author]})"
          end  
          msg << "\n"
        end
        msg << "\n"
      end
      msg
    end

    # creates a hyperlink for the task, either to Pivotal, Bugzilla or Jira
    def task_link(task)
      link = "<a href=\""
      id = task[:task_num]
      if task[:type] == :bugzilla
        link << @bugzilla.bug_url(id)
      elsif task[:type] == :pivotal
        link << @pivotal.story_url(id)
      elsif task[:type] == :jira
        link << @jira.issue_url(id)
      end
      link << "\">#{id}</a>"
    end
  end
end