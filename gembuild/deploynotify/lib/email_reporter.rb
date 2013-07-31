require 'pony'

# handles sending email for the deployment notifications
#
class EmailReporter
  SUBJECT_PREFIX = "Deploy notification: "

  # constructor
  def initialize(dry_run, from, notify_list)
    @dry_run = dry_run
    @from = from
    @notify_list = notify_list

    # no options required at this point, using smtp via localhost seems to work
    @mail_options = {
      #:address        => 'mail.blurb.com',
      #:port           => '25',
      #:user_name      => @from,
      #:password       => 'password',
      #:authentication => :plain, # :plain, :login, :cram_md5, no auth by default
      #:domain         => "localhost.localdomain" # the HELO domain provided by the client to the server
    }
  end

  #
  # emails the Author of a commit if a task appears to be a valid Pivotal story or bug, but
  # the number
  #
  def notify_bad_task(task)
    str = <<eos
Hi, this is the Git reporting script. You recently committed a change with an encoded pivotal or bugzilla ID,
but this ID doesn't appear to be valid, so I couldn't update Pivotal Tracker or Bugzilla for you.
Please review this commit and set the story/bug to 'delivered' manually.
eos
    str = str + printable_commit_data(task)
    email_message("ACTION REQUIRED - bad bug/story id in commit log", str, task[:commits].last[:author_email])
  end


  #
  # notifies user of missing bug in bugzilla
  #
  def notify_bug_id_not_found(task)
    str = <<eos
Hi, this is the Git reporting script. You committed a fix for bug %s but I can't find that bug in Bugzilla.
Please review your Git commit and update bugzilla as appropriate.
eos
    str = sprintf(str, task[:task_num]) + printable_commit_data(task)
    email_message("ACTION REQUIRED - invalid bug ID", str, task[:commits].last[:author_email])
  end

  #
  # notifies user of missing story in Pivotal Tracker
  #
  def notify_story_id_not_found(task)
    str = <<eos
Hi, this is the Git reporting script. Your Git commit logs indicate that you finished story %s but I can't
find that story in Pivotal Tracker. Perhaps the project ID of the Pivotal project for this story hasn't
been added to deploynotify_cfg.yml yet. Please check this and manually set your Pivotal story to 'delivered.'
eos
    str = sprintf(str, task[:task_num]) + printable_commit_data(task)
    email_message("ACTION REQUIRED - invalid story ID", str, task[:commits].last[:author_email])
  end

  #
  # notifies user of missing issue in Jira
  #
  def notify_issue_id_not_found(task)
    str = <<eos
Hi, this is the Git reporting script. Your Git commit logs indicate that you finished issue %s but I can't
find that issue in Jira. Please review your Git commit and update Jira as appropriate.
eos
    str = sprintf(str, task[:task_num]) + printable_commit_data(task)
    email_message("ACTION REQUIRED - invalid Jira ID", str, task[:commits].last[:author_email])
  end


  #
  # sends an email report to the entire list
  #
  def email_report(project_name, build_number, msg)
    email_message("#{project_name} build #{build_number}", msg, @notify_list, true)
  end

  # sends off a message
  def email_message(subject, msg, to, html = false)
    if (!@dry_run)
      msg_hash = {:to => to,
                :subject => "#{SUBJECT_PREFIX}#{subject}",
                :from => @from,
                :via => :smtp,
                :via_options => @mail_options }
      if html
        msg_hash[:html_body] = "<PRE>#{msg}</PRE>"
      else
        msg_hash[:body] = msg
      end
      Pony.mail(msg_hash)
    else
      puts "email message to: #{to}:"
      puts msg
    end
  end

  private

  # returns printable string containing commit info
  def printable_commit_data(task)
    str = <<eos

Here's the log of the last commit for this task:

commit:        %s
date:          %s
committed by:  You

  %s
eos
    last_commit = task[:commits].last
    sprintf( str, last_commit[:sha], last_commit[:date], last_commit[:message] )
  end
  #Code here
end