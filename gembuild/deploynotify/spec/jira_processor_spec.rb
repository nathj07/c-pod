require File.join(File.dirname(__FILE__), "/spec_helper" )

describe JiraProcessor do

  context "deploy" do

    before(:each) do
      config_path = File.join(File.dirname(__FILE__), "/testconfig.yml" )
      config = YAML.load_file(config_path)
      @dry_run = config['dry_run']

      @jira = JiraProcessor.new(nil, @dry_run)

      # create pivotal object and log in
      username = config['jira']['user']
      password = config['jira']['passwd']
      @login = @jira.login(username, password)
    end

    it "should be able to log in " do
      @login.should be_a(String)
    end

    it "should find an issue by id" do
      issue = @jira.find_issue_by_id('DSN-129')
      issue.project.should == "DSN"
      issue.key == "DSN-129"
    end

    it "should return nil if issue can't be found" do
      issue = @jira.find_issue_by_id('XXX-999')
      issue.should be_nil
    end

    # fix this:
    # this test will fail if the story is not currently in state finished.
    it "should be able to update the status of an issue" do
      issue = @jira.find_issue_by_id('CSA-95')

      # update for build 30
      resp = @jira.update_issue(issue, nil, '30')
      p resp
      # TODO test response 
    end

  end

end

