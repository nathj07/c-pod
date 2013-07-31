require File.join(File.dirname(__FILE__), "/spec_helper" )

# these tests are very basic, just a starting point for more extensive tests
module Deploynotify
  describe BuildUpdateProcessor do
    context "deployment notification" do
      before(:each) do
        config_path = File.join(File.dirname(__FILE__), "/testconfig.yml" )
        File.exist?(config_path).should be_true

        revision = '8c2d240bd1b0f2091ef4baa43fdcb555e1b7f4c4'
        build_number = 1
        project_dir = "../../../obt" 
        @processor = BuildUpdateProcessor.new(revision, build_number, project_dir, config_path)
      end

      it "should initialize ok" do
        @processor.should_not be_nil
        @processor.build_number.should == 1
      end  

      it "should have set up an email reporter" do
        @processor.reporter.should_not be_nil
      end
      
      it "should have set up a bugzilla processor" do
        @processor.bugzilla.should_not be_nil
      end

      it "should have set up a pivotal processor" do
        @processor.pivotal.should_not be_nil
      end

      it "should have set up a git processor" do
        @processor.git.should_not be_nil
      end

      it "should have set up a jira processor" do
        @processor.jira.should_not be_nil
      end
    end
  end
end

