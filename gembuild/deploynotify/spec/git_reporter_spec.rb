require File.join(File.dirname(__FILE__), "/spec_helper" )

describe GitReporter do

  context "test" do

    before(:each) do
      f = File.join(File.dirname(__FILE__), "../../.." )
      @git = GitReporter.new(f, 10, true) # dry run

      #config_path = File.join(File.dirname(__FILE__), "/testconfig.yml" )
      #config = YAML.load_file(config_path)
    end

    it "should set the build revision" do
      @git.build_revision.should == 10
    end

    it "should parse commit logs" do
      c = []
      c << stub_commit( { :date => Time.now, :message => 'my bugzilla commit #43229*', :sha => '123ab23', :author_name => 'Peter Hulst', :author_email => 'first@blurb.com'})
      c << stub_commit( { :date => Time.now, :message => '@1275639* pivotal story fix', :sha => '9374fa', :author_name => 'Peter Hulst', :author_email => 'second@blurb.com'})
      c << stub_commit( { :date => Time.now, :message => 'this is an unrelated checkin', :sha => 'bbb123', :author_name => 'Peter Hulst', :author_email => 'third@blurb.com'})
      c << stub_commit( { :date => Time.now, :message => 'Jira issue BFY-34* and bug #15430 fixes', :sha => 'd32f3ab23', :author_name => 'Peter Hulst', :author_email => 'fourth@blurb.com'})
      c << stub_commit( { :date => Time.now, :message => 'another checkin for Jira issue BFY-34', :sha => '3256b2d3', :author_name => 'Peter Hulst', :author_email => 'fourth@blurb.com'})

      @git.load_tasks(c)
      #tasks.length.should == 4

      bugs = @git.bugs
      # there should be two bugs resolved
      bugs.length.should == 2

      bug1 = bugs[0]
      #puts bug1.inspect
      bug1[:task_num].should == 43229
      bug1[:completed].should == false
      bug1[:commits][0][:author_email].should == 'first@blurb.com'
      bug1[:commits][0][:author].should == 'Peter Hulst'
      bug1[:type].should == :bugzilla

      bug2 = bugs[1]
      #puts bug2.inspect
      bug2[:task_num].should == 15430
      bug2[:completed].should == true
      bug2[:commits][0][:author_email].should == 'fourth@blurb.com'
      bug2[:commits][0][:author].should == 'Peter Hulst'
      bug2[:type].should == :bugzilla

      stories = @git.pivotal_stories
      stories.should_not be_nil
      stories.length.should == 1
      st = stories[0]
      #puts st.inspect
      st[:task_num].should == 1275639
      st[:completed].should == false
      st[:commits][0][:author_email].should == 'second@blurb.com'
      st[:commits][0][:author].should == 'Peter Hulst'
      st[:type].should == :pivotal

      issues = @git.jira_issues
      issues.should_not be_nil
      issues.length.should == 1
      is = issues[0]
      # this issue should have 2 commits
      is[:commits].length.should == 2
      is[:task_num].should == 'BFY-34'
      is[:commits][0][:sha].should == 'd32f3ab23'
      is[:commits][1][:sha].should == '3256b2d3'
      is[:type].should == :jira

      # check unmatched
      unmatched = @git.unmatched
      unmatched.length.should == 1
      un = unmatched[0]
      un[:commits].length.should == 1
      un[:commits][0][:sha].should == 'bbb123'
      un[:type].should be_nil


      invalid = @git.invalid_tasks
      invalid.length.should == 0
    end

    def stub_commit(opts)
      commit = stub(:date => opts[:date],
                    :message => opts[:message],
                    :sha => opts[:sha],
                    :author => stub(:name => opts[:author_name], :email => opts[:author_email]))
    end


  end

end