require File.join(File.dirname(__FILE__), "/spec_helper" )

# these tests are very basic, just a starting point for more extensive tests
  describe PivotalProcessor do
    context "git reporter" do
      PROJECT1 = 62109
      PROJECT1_STORY = 3314140
      
      PROJECT2 = 75805
      PROJECT2_STORY = 9249479
      
      before(:each) do
        config_path = File.join(File.dirname(__FILE__), "/testconfig.yml" )
        config = YAML.load_file(config_path)
        
        # create pivotal object and log in
        pivotal_project_ids = config['pivotal']['project_ids']
    	  pivotal_api_token = config['pivotal']['api_token']
        @pivotal = PivotalProcessor.new(nil, true) # dry run
        @pivotal.login(pivotal_api_token, pivotal_project_ids)
      end

      it "should load project ids" do
        @pivotal.should_not be_nil
        project_ids = @pivotal.project_ids
        project_ids.should be_instance_of(Array)
        project_ids.size.should == 2
        project_ids[0].should == PROJECT1
        project_ids[1].should == PROJECT2
      end  
      
      it "should find a project" do
        project = @pivotal.find_project(PROJECT1)
        project.id.should == PROJECT1
        @pivotal.projects.size.should == 1
        
        # when called again, it should not call the api again
        project = @pivotal.find_project(PROJECT1)
        project.id.should == PROJECT1
        @pivotal.projects.size.should == 1 # size of array should still be 1
        
        project = @pivotal.find_project(PROJECT2)
        project.id.should == PROJECT2
        @pivotal.projects.size.should == 2
      end
      
      it "should find stories for any project" do
        # first try to find a story for PROJECT2
        story = @pivotal.find_story_by_id(PROJECT2_STORY)
        story.id.should == PROJECT2_STORY
        
        # try to find a story for PROJECT1
        story = @pivotal.find_story_by_id(PROJECT1_STORY)
        story.id.should == PROJECT1_STORY
      end
      
    end
  end

