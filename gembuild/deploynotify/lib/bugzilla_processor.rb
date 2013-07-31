require 'xmlrpc/client'

# handles functionality related to fetching and updating bugs for build notifier
#
class BugzillaProcessor

  FIXED_COMMENT_PREFIX = "Deploy Notification: "

  # hacked to add debug support
  class XMLRPC::Client
    def set_debug
      @http.set_debug_output($stderr);
    end
  end

  # constructor
  def initialize(email_reporter, dry_run)
    @dry_run = dry_run # if true, talk to bugzilla but don't actually update anything
    @server = XMLRPC::Client.new2("https://bugzilla.blurb.com/xmlrpc.cgi")
    @email_reporter = email_reporter
  end

  # Turn on the setting below to enable xml-rpc debugging of this script
  # server.set_debug
  def login(username, pwd)
    user = @server.proxy('User')
    logged_in_user_response = user.login({'login' => username, 'password' => pwd})
    #puts "\nlogged in user id = " + logged_in_user_response['id'].to_s
  end

  # returns a bug from bugzilla with given ID. If not found, returns nil
  def find_bug_by_id(bug_id)
    bugproxy = @server.proxy('Bug')
    bug = nil
    begin
      data = bugproxy.get({:ids => bug_id})
      if (data)
        bug = data['bugs'][0]
      end
    rescue XMLRPC::FaultException => e
      puts "no match for bug #{bug_id} in bugzilla"
    end
    bug
  end

  # returns the bug url
  def bug_url(bug_id)
    "https://bugzilla.blurb.com/show_bug.cgi?id=#{bug_id}"
  end

  #
  # update all Bugzilla reports, and updates the task name from bugzilla for all bugs
  #
  def update_bug_reports(bugs, build_number)
    puts "Updating bug reports..."
    # update bugzilla reports
    bugs.each do |bug|
      bug_data = find_bug_by_id(bug[:task_num])
      if (bug_data)
        # bug was found, update comments and status
        update_bug(bug_data, bug, build_number)
        # set bug title in task object
        bug[:task_name] = bug_data['internals']['short_desc']
      else
        # unknown bug, notify author of commit
        @email_reporter.notify_bug_id_not_found(bug)
      end
    end
  end

  # updates status and comments in bug
  def update_bug(bug_data, bug_task, build_number)
    bug_id =  bug_data['id']
    bugproxy = @server.proxy('Bug')
    comments_result = bugproxy.comments({:ids => bug_id})
    #puts comments_result
    comments = comments_result['bugs']["#{bug_id}"]['comments']
    last_comment = comments.last

    if last_comment
      if !last_comment['text'].start_with? FIXED_COMMENT_PREFIX

        # only add a comment if the state isn't already VERIFIED, REVERIFIED or CLOSED
        status = bug_data['status']
        txt = String.new(FIXED_COMMENT_PREFIX)  # comment should always begin with this
        txt << "Fixed in Git and deployed with build #{build_number}"

        if !(status == 'RESOLVED' || verified_or_closed?(status))
          txt << "\n\nNOTE: it appears that this bug has not been marked resolved yet... please verify and update status if necessary"
        end

        if (!verified_or_closed?(status) && !@dry_run)
          add_comment_response = bugproxy.add_comment({'id' => bug_id, 'comment' => txt})

          #puts "adding comment to bug id #{bug_id}\n #{txt}"
          # TODO: add delivered in build field
          # unfortunately it doesn't look like the API gives us a way to update custom fields
          # http://www.bugzilla.org/docs/tip/en/html/api/Bugzilla/WebService/Bug.html#fields
        end
      end
    end
    #puts "Last comment:\n#{last_comment}"
  end

  private

  # returns true if bug status is verified or closed
  def verified_or_closed?(status)
    (status == 'VERIFIED' || status == 'REVERIFIED' || status == 'CLOSED')
  end
end