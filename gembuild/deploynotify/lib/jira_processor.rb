require 'rubygems'
require 'jira4r'

#
# handles functionality related to fetching and updating JIRA issues for build notifier
#
class JiraProcessor

  FIXED_COMMENT_PREFIX = "Deploy Notification: "
  STATUS = { :notyetstarted => '10000',
             :started => '10001',
             :finished => '10002',
             :delivered => '10003',
             :rejected => '10005',
             :readyforqa => '10006',
             :accepted => '10004'
  }
  JIRA_ACTION_ID = { :delivered => '31' }

  BUILD_VERSION_FIELD = "Build Number"

  # constructor
  def initialize(email_reporter, dry_run)
    @dry_run = dry_run # if true, talk to Jira don't actually update anything
    @jira = jira = Jira4R::JiraTool.new(2, "http://jira.blurb.com")
    @email_reporter = email_reporter
  end

  # Log in the jira user, returns access token
  def login(username, pwd)
    # we don't really need the @login_token. If login fails, an exception will be thrown
    @login_token = @jira.login(username, pwd)
    puts "Logged in user #{username} to Jira with access token #{@login_token}" if @dry_run
    @login_token
  end

  # returns an issue from Jira with ID. If not found, returns nil
  def find_issue_by_id(issue_id)
    issue = nil
    begin
      issue = @jira.getIssue(issue_id)
    rescue => e
      puts "no match for issue #{issue_id} in Jira"
    end
    issue
  end

  # returns the url for the issue
  def issue_url(issue_id)
    "http://jira.blurb.com/browse/#{issue_id}"
  end

  #
  # update all issues in Jira, and sets the task name for every issue from Jira
  #
  def update_jira_issues(issues, build_number)
    puts "Updating jira issues..."
    issues.each do |issue|
      issue_data = find_issue_by_id(issue[:task_num])
      if (issue_data)
        # issue was found, update comments and status
        update_issue(issue_data, issue, build_number)
        # set issue title in task object
        issue[:task_name] = issue_data.summary
      else
        # unknown issue, notify author of commit
        @email_reporter.notify_issue_id_not_found(issue)
      end
    end
  end

  # updates status and comments in issue
  def update_issue(issue_data, issue_task, build_number)
    
    issue_key =  issue_data.key
    comments = @jira.getComments(issue_key)
    last_comment = comments.last

    # get the status
    status = STATUS.index(issue_data.status)
    if !status
      puts "ERROR: unknown status for issue #{issue_key}: "
      p issue_data
      return
    end

    puts "status for issue #{issue_key} = #{status}" if @dry_run

    # comment will be posted if
    #  - the last comment wasn't already from the deploy notify script
    #  - if the state is in :notyetstarted, :started, :finished or :rejected mode
    if (last_comment && !last_comment.body.start_with?(FIXED_COMMENT_PREFIX)) || !last_comment
      
      txt = String.new(FIXED_COMMENT_PREFIX)  # comment should always begin with this
      txt << "Fixed in Git and deployed with build #{build_number}"

      if [:notyetstarted, :started, :finished, :rejected].include?(status)

        if status != :finished
          txt << "\n\nNOTE: this issue is not in expected finished state... please verify and update status to delivered if necessary"
        end

        comment = Jira4R::V2::RemoteComment.new()
        comment.body = txt

        begin
          @jira.addComment(issue_key, comment) if !@dry_run
        rescue => err
          puts "ERROR: unable to add comment to issue issue #{issue_key}:\n#{err}"
        end

        # jira won't allow us to update status to delivered unless it's in rejected state
        if status == :finished
          puts "updating issue #{issue_key} to status delivered"
          begin
            @jira.progressWorkflowAction(issue_key, JIRA_ACTION_ID[:delivered], []) if !@dry_run
          rescue => err
            puts "ERROR: unable to update issue #{issue_key}:\n#{err}"
          end
        else
          puts "issue #{issue_key} is in unexpected status #{status}, not updating status."
        end
      end
    end
  end
end
