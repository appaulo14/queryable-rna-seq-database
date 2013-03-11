require 'spec_helper'

describe UploadCuffdiff do
  before(:all) do
    @test_files_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                       "test_files/cuffdiff"
    DatabaseCleaner.clean
  end
  
  after(:all) do
    DatabaseCleaner.clean
  end
  
  before(:each) do 
    @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
    UploadUtil.stub(:generate_go_terms){
      "#{@test_files_path}/2_samples/go_terms.annot"
    }
#     UploadUtil.stub(:generate_go_terms){
#      @goat
#     }
    #Stub the blast database creation and rollback
#     UploadUtil.stub(:create_blast_database){}
#     UploadUtil.stub(:rollback_blast_database){}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  describe 'validations', :type => :validations do
    it 'should require a dataset name'
    it 'should require a transcript isoforms file that exists'
    it "should require has_diff_exp be '1' or '0'"
    it 'should not save when not valid'
  end
  
  describe 'flow control', :type => :white_box do
    before(:each) do
      #Stub it all
      #Change @it to @uc?
      @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
      @it.stub(:process_args_to_create_dataset){}
      @it.stub(:process_transcript_differential_expression_file){}
      @it.stub(:process_gene_differential_expression_file){}
      @it.stub(:process_transcript_isoforms_file){}
      @it.stub(:find_and_process_go_terms){}
      @it.stub(:delete_files)
      QueryAnalysisMailer.stub(:notify_user_of_upload_success){}
      QueryAnalysisMailer.stub(:notify_user_of_upload_failure){}
      UploadUtil.stub(:create_blast_database)
      UploadUtil.stub(:rollback_blast_database)
      #etc.
    end
    
    shared_examples_for 'all options when an exception occurs' do
      it 'should call QueryAnalysisMailer.notify_user_of_upload_failure'
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_success'
      it 'should rollback the blast database'
    end
    
    shared_examples_for 'all options when no exception occurs' do
      it 'should call process_args_to_create_dataset'
      it 'should call Upload.create_blast_database'
      it 'should call QueryAnalysisMailer.notify_user_of_upload_success'
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_failure'
      it 'should not call UploadUtil.rollback_blast_database'
    end
    
    shared_examples_for 'all options regardless of whether an exception occurs' do
       it 'should delete the uploaded files' 
#       do       
#         File.should_receive(:delete).with(@it.transcripts_fasta_file.tempfile.path)
#         File.should_receive(:delete).with(@it.transcript_diff_exp_file.tempfile.path)
#         File.should_receive(:delete).with(@it.gene_diff_exp_file.tempfile.path)
#         File.should_receive(:delete).with(@it.transcript_isoforms_file.tempfile.path)
#         @it.save
#       end
    end
    
    describe 'when both has_transcript_isoforms and has_diff_exp are "1"' do
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options regardless of whether an exception occurs'
      
      it 'should call process_transcript_differential_expression_file'
      it 'should call process_gene_differential_expression_file'
      #etc.
    end
    
    describe 'when has_transcript_isoforms is "1" but has_diff_exp is "0" ' do
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options regardless of whether an exception occurs'
    end
    
    describe 'when has_transcript_isoforms is "0" but has_diff_exp is "1" ' do
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options regardless of whether an exception occurs'
    end
    
    describe 'when both has_transcript_isoforms and has_diff_exp are "0"' do
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options regardless of whether an exception occurs'
      
      it 'should not call go terms'
    end
  end
    
#     describe 'when an exception is thrown' do
#       it_should_behave_like 'all paths'
#       
#       it 'should rollback the blast database'
#       it 'should notify the user of failure'
#       it 'should rollback the blast database'
# #       it 'should rollback the database transaction' do
# #         lambda do
# #           @it.stub(:process_args_to_create_dataset){raise Exception, "Seeded exception"}
# #           ActiveRecord::Base.should_receive(:rollback_active_record_state!).and_call_original
# #           @it.save
# #         end.should raise_error(Exception, "Seeded exception")
# #       end
#     end
#   end
  
  describe 'database/email/file interaction', :type => :black_box do
    shared_examples_for 'any number of samples when an exception occurs' do
      it 'should create 0 datasets'
      it 'should create 0 transcripts'
      it 'should send an email notifying user of failure'
      it 'should rollback the blast database'
      #etc.
    end
    
    shared_examples_for 'any number of samples when no exception occurs' do
      it 'should create 1 blast database' 
#       do
#         exec_path = "#{Rails.root}/bin/blast/bin"
#         database_path = "db/blast_databases/test/#{dataset.id}_db"
#         result = system("#{exec_path}/blastdbcmd -info -db #{database_path}")
#         result.should be_true
#       end
      it 'should create 1 dataset'
      it 'should create 0 users'
      it 'should send 1 email notifying the user of success'
      #etc.?
    end
    
    shared_examples_for 'any number of samples regardless of whether an exception occurs' do
      it 'should delete the uploaded files' do       
        File.should_receive(:delete).with(uc.transcripts_fasta_file.tempfile.path)
        File.should_receive(:delete).with(uc.transcript_diff_exp_file.tempfile.path)
        File.should_receive(:delete).with(uc.gene_diff_exp_file.tempfile.path)
        File.should_receive(:delete).with(uc.transcript_isoforms_file.tempfile.path)
        @it.save
      end
    end
    
    describe 'for 1 sample' do
      before(:each) do
        #Stub blast2go because it takes a long time
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/1_sample/go_terms.annot"
        }
      end
      
      it_should_behave_like 'any number of samples when an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_1_sample)}
      end
      
      it_should_behave_like 'any number of samples when no exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_1_sample)}
      end
      
      it_should_behave_like 'any number of samples regardless of whether an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_1_sample)}
      end
      
      describe 'when it has transcript isoforms only' do
      end
      
      describe 'when it has no transcript isoforms' do
        it 'should have 0 transcripts'
        #etc.
      end
    end
    
    describe 'for 2 sample' do
      before(:each) do
        #Stub blast2go because it takes a long time
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/2_samples/go_terms.annot"
        }
      end
      
      it_should_behave_like 'any number of samples when an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_2_samples)}
      end
      
      it_should_behave_like 'any number of samples when no exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_2_samples)}
      end
      
      it_should_behave_like 'any number of samples regardless of whether an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_2_samples)}
      end

      describe 'when it has differenntial expression tests and transcript isoforms' do
      end
      
      describe 'when it has differenntial expression tests only' do
      end
      
      describe 'when it transcript isoforms only' do
      end
      
      describe 'when it has neither differenntial expression tests nor transcript isoforms' do
        it 'should have 0 transcripts'
        #etc.
      end
    end
    
    describe 'for 3 sample' do
      before(:each) do
        #Stub blast2go because it takes a long time
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/3_samples/go_terms.annot"
        }
      end
      
      it_should_behave_like 'any number of samples when an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_3_samples)}
      end
      
      it_should_behave_like 'any number of samples when no exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_3_samples)}
      end
      
      it_should_behave_like 'any number of samples regardless of whether an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_3_samples)}
      end

      describe 'when it has differenntial expression tests and transcript isoforms' do
      end
      
      describe 'when it has differenntial expression tests only' do
      end
      
      describe 'when it transcript isoforms only' do
      end
      
      describe 'when it has neither differenntial expression tests nor transcript isoforms' do
        it 'should have 0 transcripts'
        #etc.
      end
    end
    
    describe 'for 4 sample' do
      before(:each) do
        #Stub blast2go because it takes a long time
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/2_samples/go_terms.annot"
        }
      end
      
      it_should_behave_like 'any number of samples when an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_4_samples)}
      end
      
      it_should_behave_like 'any number of samples when no exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_4_samples)}
      end
      
      it_should_behave_like 'any number of samples regardless of whether an exception occurs' do
        let(:uc){FactoryGirl.build(:upload_cuffdiff_with_4_samples)}
      end
      
      describe 'when it has differenntial expression tests and transcript isoforms' do
      end
      
      describe 'when it has differenntial expression tests only' do
      end
      
      describe 'when it transcript isoforms only' do
      end
      
      describe 'when it has neither differenntial expression tests nor transcript isoforms' do
        it 'should have 0 transcripts'
        #etc.
      end
    end
  end
  
#   describe 'happy paths' do
#     shared_examples_for 'all samples for the has_transcript_isoforms option' do
#       it 'should process the transcript isoforms file when ' +
#          'has_transcript_isoforms is true' do
#         uc.has_transcript_isoforms = true
#         uc.should_receive(:process_transcripts_isoforms_file)
#         uc.save
#       end
#       
#       it 'should not call transcript isoforms when has_transcript_isoforms is false' do
#         uc.has_transcript_isoforms = false
#         uc.should_not_receive(:process_transcripts_isoforms_file)
#         uc.save
#       end
#     end
#     
#     shared_examples_for 'samples 2-4 for the has_diff_exp option' do
#       it 'should process the transcript isoforms file when ' +
#          'has_transcript_isoforms is true' do
#         uc.has_transcript_isoforms = true
#         uc.should_receive(:process_transcripts_isoforms_file)
#         uc.save
#       end
#       
#       it 'should not call transcript isoforms when has_transcript_isoforms is false' do
#         uc.has_transcript_isoforms = false
#         uc.should_not_receive(:process_transcripts_isoforms_file)
#         uc.save
#       end
#     end
#     
#     shared_examples_for 'all samples and options' do
#       it 'should delete the uploaded files when done' 
# #       do
# # #         File.exists?(uc.transcripts_fasta_file.tempfile.path).should be_false
# # #         File.exists?(uc.transcript_diff_exp_file.tempfile.path).should be_false
# # #         File.exists?(uc.gene_diff_exp_file.tempfile.path).should be_false
# # #         File.exists?(uc.transcript_isoforms_file.tempfile.path).should be_false
# #       end
#       
#       it 'should save without errors' do
#         uc.save
#       end
#       
#       it 'should email the user announcing success' do
#         uc.save
#         ActionMailer::Base.deliveries.count.should eq(1)
#         current_user = uc.instance_variable_get('@current_user')
#         ActionMailer::Base.deliveries.last.to.should eq([current_user.email])
#         ActionMailer::Base.deliveries.last.subject.should match('Success')
#       end
#       
#       it 'should call blast2go and the other methods exactly once???'
#     end
    
#     describe 'with 1 sample' do
#       before(:each) do
#         #Stub the method to get the go terms so we don't need to run it for each test
#         UploadUtil.stub(:generate_go_terms){
#           "#{@test_files_path}/1_sample/go_terms.annot"
#         }
#       end
#       
#       it_should_behave_like 'all samples and options' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_1_sample)}
#       end
#       
#       it_should_behave_like 'all samples for the has_transcript_isoforms option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_1_sample)}
#       end
#     end
#     
#     describe 'with 2 samples' do
#       before(:each) do
#         #Stub the method to get the go terms so we don't need to run it for each test
#         UploadUtil.stub(:generate_go_terms){
#           "#{@test_files_path}/2_samples/go_terms.annot"
#         }
#       end
#       
#       it_should_behave_like 'all samples and options' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_2_samples)}
#       end
#       
#       it_should_behave_like 'all samples for the has_transcript_isoforms option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_2_samples)}
#       end
#       
#       it_should_behave_like 'samples 2-4 for the has_diff_exp option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_2_samples)}
#       end
#     end
#       
#     describe 'with 3 samples' do
#       before(:each) do
#         #Stub the method to get the go terms so we don't need to run it for each test
#         UploadUtil.stub(:generate_go_terms){
#           "#{@test_files_path}/3_samples/go_terms.annot"
#         }
#       end
#       
#       it_should_behave_like 'all samples and options' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_3_samples)}
#       end
#       
#       it_should_behave_like 'all samples for the has_transcript_isoforms option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_3_samples)}
#       end
#       
#       it_should_behave_like 'samples 2-4 for the has_diff_exp option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_3_samples)}
#       end
#     end
#       
#     describe 'with 4 samples' do
#       before(:each) do
#         #Stub the method to get the go terms so we don't need to run it for each test
#         UploadUtil.stub(:generate_go_terms){
#           "#{@test_files_path}/4_samples/go_terms.annot"
#         }
#       end
#       
#       it_should_behave_like 'all samples and options' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_4_samples)}
#       end
#       
#       it_should_behave_like 'all samples for the has_transcript_isoforms option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_4_samples)}
#       end
#       
#       it_should_behave_like 'samples 2-4 for the has_diff_exp option' do
#         let(:uc){FactoryGirl.build(:upload_cuffdiff_with_4_samples)}
#       end
#     end
#   end
    
#   describe 'when an exception occurs' do
#     before (:each) do
#       #UploadUtil.stub(:generate_go_terms){raise Exception, 'Seeded exception'}
#       TranscriptHasGoTerm.stub(:create!){raise Exception, 'Seeded exception'}
#     end
#       
#     it 'should email the user announcing failure' do
#       lambda do
#         @it.save
#       end.should raise_error(Exception, 'Seeded exception')
#       ActionMailer::Base.deliveries.count.should eq(1)
#       ActionMailer::Base.deliveries.last.to.should eq([@current_user.email])
#       ActionMailer::Base.deliveries.last.subject.should match('Fail')
#     end
#     
#     it 'should not write any transcripts to the database' do
#       lambda do
#         @it.save
#       end.should change(Transcript, :count).by(0)
#     end
#     
#     it 'should not write any datasets to the database' do
#       lambda do
#         @it.save
#       end.should change(Dataset, :count).by(0)
#     end
#     
#     it 'should not create a blast database'
#     
#     it 'should still delete the files'
#   end
  
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
