require 'spec_helper'

shared_examples_for 'a required attribute' do
  it 'should not be valid for nil' do
    @it.send("#{@attribute}=",nil)
    @it.should_not be_valid
  end
  
  it 'should not be valid for an empty string' do
    @it.send("#{@attribute}=",'')
    @it.should_not be_valid
  end
end

shared_examples_for 'an uploaded file' do
  it 'should be valid when the type is "ActionDispatch::Http::UploadedFile"' do
    #The factory should make this attribute an uploaded file by default
    @it.send(@attribute).class.to_s.should eq('ActionDispatch::Http::UploadedFile')
    @it.should be_valid
  end
  
  it 'should not be valid when the type is a string' do
    @it.send("#{@attribute}=","")
    @it.should_not be_valid
  end
  
  it 'should not be valid when the type is a hash' do
    @it.send("#{@attribute}=",{})
    @it.should_not be_valid
  end
  
  it 'should not be valid when the type is an object' do
    @it.send("#{@attribute}=",Object.new)
    @it.should_not be_valid
  end
  
  it 'should not be valid when the type is an integer' do
    @it.send("#{@attribute}=",45)
    @it.should_not be_valid
  end
end

shared_examples_for 'an array of uploaded files' do
  it 'should be valid for any array of uploaded files' do
    uploaded_files = []
    uploaded_files << to_cuffdiff_uploaded_file(2,'transcripts.fasta')
    @it.send("#{@attribute}=",uploaded_files)
    @it.should be_valid
  end
  it 'should not be valid for an uploaded file' do
    @it.send("#{@attribute}=",FactoryGirl.build(:upload_cuffdiff_with_2_samples))
    @it.should_not be_valid
  end
  it 'should not be valid when it is a string' do
    @it.send("#{@attribute}=","hello")
    @it.should_not be_valid
  end
  it 'should not be valid when it is an array of strings' do
    @it.send("#{@attribute}=",["hello",""])
    @it.should_not be_valid
  end
  it 'should not be valid for an integer' do
    @it.send("#{@attribute}=",42)
    @it.should_not be_valid
  end
  it 'should not be valid for any array of integers' do
    @it.send("#{@attribute}=",[42,32])
    @it.should_not be_valid
  end
  it 'should not be valid for an object' do
    @it.send("#{@attribute}=",Object.new)
    @it.should_not be_valid
  end
  it 'should not be valid for any array of objects' do
    @it.send("#{@attribute}=",[Object.new,Object.new])
    @it.should_not be_valid
  end
end

shared_examples_for 'a view model-style boolean' do
  it 'should be valid for "1"' do
    @it.send("#{@attribute}=",'1')
    @it.should be_valid
  end
  it 'should be valid for "0"' do
    @it.send("#{@attribute}=",'0')
    @it.should be_valid
  end
  
  it 'should not be valid for strings besides "0" or "1"' do
    ["", "hello", "llamas"].each do |invalid_string|
      @it.send("#{@attribute}=",invalid_string)
      @it.should_not be_valid
    end
  end
  
  it 'should not be valid for integer value 1' do
    @it.send("#{@attribute}=",1)
    @it.should_not be_valid
  end
  
  it 'should not be valid for integer value 0' do
    @it.send("#{@attribute}=",0)
    @it.should_not be_valid
  end
  
  it 'should not be valid for double value 1.0' do
    @it.send("#{@attribute}=",1.0)
    @it.should_not be_valid
  end
  
  it 'should not be valid for double value 0.0' do
    @it.send("#{@attribute}=",0.0)
    @it.should_not be_valid
  end
  
  it 'should not be valid for boolean true' do
    @it.send("#{@attribute}=",true)
    @it.should_not be_valid
  end
  
  it 'should not be valid for boolean false' do
    @it.send("#{@attribute}=",false)
    @it.should_not be_valid
  end
end

shared_examples_for 'any upload view model when no exception occurs' do
  it 'should create 1 blast database' do
    @it.save
    exec_path = "#{Rails.root}/bin/blast/bin"
    database_path = "#{Rails.root}/db/blast_databases/test/#{@it.instance_eval('@dataset').id}"
    #result = system("#{exec_path}/blastdbcmd -info -db #{database_path}")
    lambda do
      SystemUtil.system!("#{exec_path}/blastdbcmd -info -db #{database_path}")
    end.should_not raise_error(StandardError)
  end
  
  it 'should create 1 dataset' do
    lambda do
      @it.save
    end.should change(Dataset, :count).by(1)
  end
  it 'should create 0 users' do
    lambda do
      @it.save
    end.should change(User, :count).by(0)
  end
  it 'should send 1 email notifying the user of success' do
    @it.save
    ActionMailer::Base.deliveries.count.should eq(1)
    current_user = @it.instance_variable_get('@current_user')
    ActionMailer::Base.deliveries.last.to.should eq([current_user.email])
    ActionMailer::Base.deliveries.last.subject.should match('Success')
  end
end

shared_examples_for 'any upload view model when an exception occurs' do
  before (:each) do
    UploadUtil.stub('create_blast_database') do
      fasta_file_path = 
        @it.instance_eval('@transcripts_fasta_file').tempfile.path
      dataset = @it.instance_eval('@dataset')
      SystemUtil.system!("#{Rails.root}/bin/blast/bin/makeblastdb " +
                          "-in #{fasta_file_path} " +
                          "-title #{dataset.id} " +
                          "-out #{dataset.blast_db_location} " +
                          "-hash_index -parse_seqids -dbtype nucl ")
      raise SeededTestException
    end
  end

  it 'should add 0 datasets to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(Dataset, :count).by(0)
  end
  it 'should add 0 users to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(User, :count).by(0)
  end
  it 'should add 0 transcripts to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(Transcript, :count).by(0)
  end
  it 'should add 0 genes to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(Gene, :count).by(0)
  end
  it 'should add 0 fpkm samples to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(FpkmSample, :count).by(0)
  end
  it 'should add 0 samples to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(Sample, :count).by(0)
  end
  it 'should add 0 sample comparisons to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(SampleComparison, :count).by(0)
  end
  it 'should add 0 differential expression tests to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(DifferentialExpressionTest, :count).by(0)
  end
  it 'should add 0 transcript has go terms to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(TranscriptHasGoTerm, :count).by(0)
  end
  it 'should add 0 transcript fpkm tracking informations to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(TranscriptFpkmTrackingInformation, :count).by(0)
  end
  it 'should add 0 go terms to the database' do
    lambda do
      begin
        @it.save
      rescue SeededTestException => ex
      end
    end.should change(GoTerm, :count).by(0)
  end
  it 'should not create the blast database' do
    begin
        @it.save
    rescue SeededTestException => ex
    end
    dir_path = "db/blast_databases/#{Rails.env}"
    cmd_string = "ls #{dir_path}/#{@it.instance_eval('@dataset').id}.*"
    system(cmd_string).should be_false
  end
  it 'should send an email notifying user of failure' do
    begin
        @it.save
    rescue SeededTestException => ex
    end
    ActionMailer::Base.deliveries.count.should eq(1)
    current_user = @it.instance_variable_get('@current_user')
    ActionMailer::Base.deliveries.last.to.should eq([current_user.email])
    ActionMailer::Base.deliveries.last.subject.should match('Fail')
  end
end
