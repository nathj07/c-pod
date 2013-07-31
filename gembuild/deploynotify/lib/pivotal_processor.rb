require 'pivotal-tracker'

# handles functionality related to fetching and updating stories in Pivotal Tracker
#
# install gem with : gem install pivotal-tracker
#
class PivotalProcessor
  attr_reader :project_ids, :projects
  
  FIXED_COMMENT_PREFIX = "Deploy Notification: "

  # constructor
  def initialize(email_reporter, dryrun = true)
    @dryrun = dryrun # if true, talk to Pivotal Tracker but don't actually update anything
    @email_reporter = email_reporter
  end

  # initializes this class, though it doesn't actually log in anymore as there can now be multiple projects that it may need to fetch. 
  # @param api_token - api token for pivotal
  # @param project_ids - array of all project ids that may have stories on the current repository
  def login(api_token, project_ids)
    PivotalTracker::Client.token = api_token
    PivotalTracker::Client.use_ssl = true

    @project_ids = project_ids
    @projects = []
  end

  # returns an internally cached project object, or fetches it if it wasn't available yet 
  def find_project(project_id)
    # check if we already fetched the project
    @projects.each do |proj|
      return proj if proj.id == project_id
    end
    # project not found, fetch it
    @projects << PivotalTracker::Project.find(project_id)
    @projects.last
  end

  # returns a Pivotal story by ID. This will need to search all associated projects for the story id, 
  # so it will be most efficient to put the most likely project for all stories first in the list
  def find_story_by_id(story_id)
    #TODO: navigate @project_ids and @projects array to find a project that contains the given story. 
    @project_ids.each do |proj_id|
      story = find_project(proj_id).stories.find(story_id)
      return story if story
    end
    nil
  end

  # returns the story url
  def story_url(story_id)
    "https://www.pivotaltracker.com/story/show/#{story_id}"
  end

  #
  # update all stories in Pivotal Tracker and updates the task name for all stories from Pivotal
  #
  def update_pivotal_stories(stories, build_number)
    puts "Updating pivotal stories..."
    # update pivotal stories
    stories.each do |story|
      story_data = find_story_by_id(story[:task_num])
      if (story_data)
        # story was found, update comments and status
        update_story(story_data, story, build_number)
        # set story title in task object
        story[:task_name] = story_data.name
      else
        # unknown story, notify author of commit
        @email_reporter.notify_story_id_not_found(story)
      end
    end
  end

  # updates status of Pivotal story to delivered
  def update_story(story_data, story_task, build_number)
    # get last comment
    last_obj = story_data.notes.all.last
    last_comment = last_obj.text if last_obj

    # if state is 'Finished', update it to delivered
    if (story_data.current_state == 'finished')
      puts "marking story #{story_task[:task_num]} as 'delivered'"
      story_data.update(:current_state => 'delivered') if !@dryrun
    elsif (story_data.current_state != 'delivered')
      #if not finished or delivered, write error
      puts "story #{story_task[:task_num]} in unexpected state '#{story_data.current_state}', not updating state."
    end

    if (!last_comment || !last_comment.start_with?(FIXED_COMMENT_PREFIX))
      # if there's no comments yet, or if that comment doesn't start with FIXED_COMMENT_PREFIX
      comment_text = update_comment_text(story_data, story_task, build_number)
      story_data.notes.create(:text => comment_text) if !@dryrun
      # do we need to add :noted_at => '06/29/2010 05:00 EST'  attribute in above call?
      puts "adding comment to story #{story_task[:task_num]}:\n#{comment_text}"
    end
  end

  # @story.tasks.find(74685).update(:complete => true)

  private

  # generates and returns the comment to add to Pivotal
  def update_comment_text(story_data, bug_task, build_number)
    txt = String.new(FIXED_COMMENT_PREFIX)  # comment should always begin with this
    txt << "Fixed in Git and deployed with build #{build_number}"

    if (story_data.current_state != 'finished' && story_data.current_state != 'delivered' && story_data.current_state != 'accepted')
      txt << "\n\nNOTE: this story is not in the expected status 'Finished'... please verify and update status if necessary"
    end
    txt
  end

end
