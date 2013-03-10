require 'spec_helper'

describe UploadCuffdiff do
  before(:all) do
    DatabaseCleaner.clean
  end
  
  after(:all) do
    DatabaseCleaner.clean
  end
  
  before(:each) do 
    #Switch to the directory of the test files
    Dir.chdir("#{Rails.root}/spec/view_models/query_analysis/test_files/cuffdiff")
    #Create and fill in the class
    @it = UploadCuffdiff.new(@current_user)
    @it.dataset_name = 'Test_Dataset'
    @it.has_diff_exp = true
    @it.has_transcript_isoforms = true
    @it.transcripts_fasta_file = make_http_uploaded_file('transcripts.fasta')
    @it.transcript_diff_exp_file = make_http_uploaded_file('isoform_exp.diff')
    @it.gene_diff_exp_file = make_http_uploaded_file('gene_exp.diff')
    @it.transcript_isoforms_file = make_http_uploaded_file('isoforms.fpkm_tracking')
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
    #Stub the method to get the go terms so we don't need to run it for each test
    UploadUtil.stub(:generate_go_terms){"#{Dir.pwd}/go_terms.annot"}
    #Stub the blast database creation and rollback
    UploadUtil.stub(:create_blast_database){}
    UploadUtil.stub(:rollback_blast_database){}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  describe 'validations' do
    it 'should require a dataset name'
    it 'should require a transcript isoforms file that exists'
  end
  
  describe 'when valid' do
    shared_examples_for 'any number of samples' do
      it 'should process the transcript isoforms file when ' +
         'has_transcript_isoforms is true' do
        upload_cuffdiff.has_transcript_isoforms = true
        upload_cuffdiff.should_receive(:process_transcripts_isoforms_file)
        upload_cuffdiff.save
      end
    end
    
    describe 'with any number of samples' do
      it 'should process the transcript isoforms file when ' +
         'has_transcript_isoforms is true' do
        @it.has_transcript_isoforms = true
        @it.should_receive(:process_transcripts_isoforms_file)
        @it.save
      end
      
      it 'should not call transcript isoforms when has_transcript_isoforms is false' do
        @it.has_transcript_isoforms = false
        @it.should_not_receive(:process_transcripts_isoforms_file)
        @it.save
      end
      
      it 'should delete the uploaded files when done' do
        File.exists?(@it.transcripts_fasta_file.tempfile.path).should be_false
        File.exists?(@it.transcript_diff_exp_file.tempfile.path).should be_false
        File.exists?(@it.gene_diff_exp_file.tempfile.path).should be_false
        File.exists?(@it.transcript_isoforms_file.tempfile.path).should be_false
      end
      
      it 'should save without errors' do
        @it.save
      end
      
      it 'should email the user announcing success' do
        @it.save
        ActionMailer::Base.deliveries.count.should eq(1)
        ActionMailer::Base.deliveries.last.to.should eq([@current_user.email])
        ActionMailer::Base.deliveries.last.subject.should match('Success')
      end
      
      it 'should call blast2go abd the other programs exactly once???'
    end
    
    describe 'with 1 sample' do
      it_should_behave_like 'any number of samples' do
        let(:upload_cuffdiff){@it}
      end
    end
    
    describe 'with 2 samples' do
      it_should_behave_like 'any number of samples' do
        let(:upload_cuffdiff){@it}
      end
    end
    
    describe 'with 3 samples' do
      it_should_behave_like 'any number of samples' do
        let(:upload_cuffdiff){@it}
      end
    end
    
    describe 'with 4 samples' do
      it_should_behave_like 'any number of samples' do
        let(:upload_cuffdiff){@it}
      end
    end
  end
    
  describe 'when an exception occurs' do
    before (:each) do
        #UploadUtil.stub(:generate_go_terms){raise Exception, 'Seeded exception'}
        TranscriptHasGoTerm.stub(:create!){raise Exception, 'Seeded exception'}
      end
      
      it 'should email the user announcing failure' do
        lambda do
          @it.save
        end.should raise_error(Exception, 'Seeded exception')
        ActionMailer::Base.deliveries.count.should eq(1)
        ActionMailer::Base.deliveries.last.to.should eq([@current_user.email])
        ActionMailer::Base.deliveries.last.subject.should match('Fail')
      end
      
      it 'should not write any transcripts to the database' do
        lambda do
          @it.save
        end.should change(Transcript, :count).by(0)
      end
      
      it 'should not write any datasets to the database' do
        lambda do
          @it.save
        end.should change(Dataset, :count).by(0)
      end
      
      it 'should not create a blast database'
      
      it 'should still delete the files'
  end
  
#   it 'should have all genes have transcripts' do
#     @it.save
#     @it.dataset.genes.each do |gene|
#       gene.transcripts.count.should_not eq(0)
#     end
#   end
  
#   it 'should work concurrently' do   
# #     old_ds = Dataset.count
# #     @it.save!
# #     #Process.wait(pid = @it.save!)
# #     sleep 15
# #     Dataset.establish_connection
# #     new_ds = Dataset.count
# #     new_ds.should eq(old_ds + 1)
#       #
#       #debugger
#       #SuckerPunch::Queue[:awesome_queue].async.perform()
#     lambda do
#       100.times do
#         SuckerPunch::Queue[:upload_cuffdiff_queue].async.perform(@it.clone)
#       end
#       while(SuckerPunch::Queue[:upload_cuffdiff_queue].busy_size > 0)
#         puts 'sleeping'
#         sleep 1
#       end
#     end.should change(Dataset, :count).by(100)
#       #User.find(u.id).name.should eq('awesome')
#   end
  
  
#   it 'should save without errors if valid' do
#     @it.save
#   end
  
#   it 'should create a blast database' do
#     #@it.save
# #     ds = double("Dataset")
# #     ds.should_receive(:name)
# #     ds.name
#     #ds.should_receive(:name)
# #     UploadUtil.create_blast_databas("",FactoryGirl.create(:dataset))
#     UploadUtil.should_receive(:create_blast_database).with(kind_of(String),kind_of(Dataset))
#     #UploadUtil.create_blast_database("",FactoryGirl.create(:dataset))
#     @it.save
#     #blastdbcmd -info -db db/blast_databases/dev/1_db
#   end
#   
#   it 'should delete the blast database on rollback if it was created'
#   
#   it 'should put the blast database it the right place' do
#   end
#   #blastdbcmd -info -db db/blast_databases/dev/1_db
#   
#   

end
