require 'rubygems'
require 'grit'

include Grit

# handles all Git interaction for deployment notification 
#
# install grit gem with
# gem install grit -s http://gemcutter.org
class GitReporter
  attr_reader :bugs, :pivotal_stories, :jira_issues, :unmatched, :invalid_tasks, :current_build_number, :build_revision

  # constructor
  # @param repository name
  # @param revision latest SHA of repository
  # @param prev_build previous build number to run deployment notifications from (if nil, run from most recent git tag instead)
  def initialize(repository, revision, prev_build, dry_run = false)
    @repo_path = repository
    @repo = Repo.new(repository)
    @head = @repo.head()
    @dry_run = dry_run

    if (@head.name != 'staging' && !@dry_run)
      puts "You must be on staging when running this script"
      exit 1
    end

    @build_revision = revision
    @prev_build = prev_build
  end

  # fetches all commits between current revision and the previous tag, and returns as list of
  # tasks (see load_tasks)
  #
  def get_commits
    # get the last build number
    build_tag = last_build_git_data
    @last_build_number = build_tag[:build_number]
    if @last_build_number == 0
      puts "unable to get last build number using git describe. It returned #{build_tag[:describe]} but \
expecting something that has letters followed by numbers. Unable to continue"
      exit 1
    end

    # Jenkins will tag the build before running the deploy, @last_build_number - 1 will get the previous built version to get the diff.
    # However, if prev_build is set, use that instead. 
    from_build = (@prev_build.nil?) ? (@last_build_number.to_i - 1) : @prev_build.to_i
    
    # now fetch all commits for anything between the current revision and the last build number
    last_build_tag = "#{build_tag[:tag_name]}#{from_build}"
    # puts "looking for commits between #{last_build_tag} and #{@build_revision}"
    
    commits = @repo.commits_between(last_build_tag, @build_revision)
    if (commits && commits.length > 0)
      load_tasks(commits)
    else
      puts "No commits logs (other than possibly merges) were found between tag #{last_build_tag} and build revision #{build_revision}. \n
Nothing to report on, exiting. "
      exit 1
    end
  end


  # returns the most recent build number based on response from ''git describe'
  def last_build_git_data
    describe = @repo.recent_tag_name()
    m = describe.match(/(\D*)(\d+)/)
    build = 0
    if (m && m.length == 3)
      build = m[2].to_i
      tag_name = m[1]
      if (build > 0)
        puts "most recent tag found is for build #{build}"
      else
        build = 0
      end
    end
    { :build_number => build, :tag_name => tag_name, :describe => describe}
  end

  #
  # takes a list of commits, and loads 4 arrays: @bugs, @pivotal_stories, @jira_issues and @unmatched,
  # containing hashes with the following properties:
  #
  # :task_num        - the task number, either bugzilla, pivotal or Jira id (not set in @unmatched array)
  # :completed       - boolean indicating whether story has been completed or not (based on most recent
  #                    update mentioning this task)
  # :author          - name of author (based on last commit for this bug/story/issue)
  # :author_email    - email address of author (based on last commit for this bug/story/issue)
  # :messages        - array of commit messages associated to this task
  # :sha             - sha of last commit for a task
  # :date            - date of last commit for a task
  def load_tasks(commits)
    @bugs = []
    @pivotal_stories = []
    @jira_issues = []
    @unmatched = []
    @invalid_tasks = []

    # this pattern will match any pivotal story, bugzilla or jira issue notation.
    # For testing of this regular expression, I recommend rubular.com.
    regexp = /((#)(\d{4,5})|(@)(\d{7,8})|([A-Z]{2,8})-(\d{1,5}))(\*?)(\W|$)/
    commits.each do |c|
      puts ("commit by #{c.author.name} on #{c.date}: #{c.message}") 

      task_tracked = false
      invalid_id = false
      matches = c.message.scan(regexp)
      coll = nil
      if (matches.length > 0)
        matches.each do |match|
          task = parse_task(match, c)
          coll = nil
          if task
            if task[:type] == :pivotal
              coll = @pivotal_stories
            elsif task[:type] == :bugzilla
              coll = @bugs
            elsif task[:type] == :jira
              coll = @jira_issues
            end
          end
          if (coll)
            track_task(coll, task, c)
          else
            invalid_id = true
          end
        end
      end

      if ((c.message !~ /^Merge branch/) && coll.nil?)
        # there weren't any matches. Still track this as an unmatched task, unless it's a
        # simply merge commit

        task = { :commits => [commit_hash(c)] } # we don't have a task id or completed flag here'
        @unmatched << task

        if (invalid_id)
          @invalid_tasks << task
        end
      end
    end
  end


  private

  # adds the task to the task list or updates an existing task in that list if it already existed
  def track_task(task_list, task, commit)
    # find the track item for this task
    idx = task_list.index { |x|
      x[:task_num] == task[:task_num]
    }
    if idx
      track_item = task_list[idx]
      # this task was already in the list, add the message and update the last status, sha, date, etc
      track_item[:completed] = task[:completed] # set to completed if most recent task is marked as completed
      track_item[:commits] << commit_hash(commit)
    else
      # track item doesn't exist yet
      track_item = { :task_num => task[:task_num],
                     :completed => task[:completed],
                     :commits => [commit_hash(commit)],
                     :type => task[:type]}
      task_list << track_item
    end
  end

  def commit_hash(commit)
    { :message => commit.message,
      :sha => commit.sha,
      :date => commit.date,
      :author => commit.author.name,
      :author_email => commit.author.email
    }
  end

  # parses a task match and returns it as hash with 3 properties:
  # :task_num  - the number (or ID for Jira issues)
  # :completed - true unless task number ended in '*'
  # :type - :pivotal if task started with @, :bugzilla if started with #
  # or :jira if task matches pattern ABC-nnnn
  # will return nil if task appears to be invalid
  def parse_task(match, commit)
    task = { :completed => (match[7] != '*') }

    if match[3]
      task[:type] = :pivotal
      task[:task_num] = match[4].to_i
    elsif match[1]
      task[:type] = :bugzilla
      task[:task_num] = match[2].to_i
    elsif match[5]
      task[:task_num] = match[0]
      task[:type] = :jira
    else
      puts "WARNING: UNABLE TO DETERMINE TASK TYPE IN: #{commit.message}"
      return nil
    end
    task
  end
end
