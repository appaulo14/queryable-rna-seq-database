require 'spec_helper'
require 'view_models/shared_examples.rb'

describe UploadCuffdiff do
  before(:all) do
    @test_files_path = "#{Rails.root}/spec/view_models/query_analysis/" +
                       "test_files/cuffdiff"
    DatabaseCleaner.clean
  end
  
  before(:each) do
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
  end
  
  after(:all) do
    DatabaseCleaner.clean
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  describe 'validations', :type => :validations do
    before (:each) do
      @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
    end
    
#    :transcripts_fasta_file, 
#    :transcript_diff_exp_file, 
#    :gene_diff_exp_file, 
#    :transcript_isoforms_file,
#    :has_diff_exp,
#    :has_transcript_isoforms,
#    :dataset_name
    describe 'transcripts_fasta_file' do
      before(:each) do @attribute = 'transcripts_fasta_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'transcript_diff_exp_file' do
    end
    
    describe 'gene_diff_exp_file' do
    end
    
    describe 'transcript_isoforms_file' do
    end
    
    describe 'has_diff_exp' do
      
    end
    
    describe 'has_transcript_isoforms' do
    end
    
    describe 'dataset_name' do
    end
    
    shared_examples_for 'any option' do
      it 'should require a dataset name'
      it 'should require has_diff_exp be "1" or "0"'
      it 'should require has_transcript_isoforms be "1" or "0"'
      it 'should not save when not valid'
      it 'should require a transcript fasta file'
    end
    
    describe 'when has_diff_exp is "1"' do
      before (:each) do
        @it.has_diff_exp = '1'
      end
      
      it_should_behave_like 'any option'
      
      it 'should require a gene differential expression file'
      it 'should require a transcript differenntial expression file'
    end
    
    describe 'when has_diff_exp is "0"' do
      before (:each) do
        @it.has_diff_exp = '1'
      end
      
      it_should_behave_like 'any option'
      
      it 'should not require a gene differential expression file'
      it 'should not require a transcript differenntial expression file'
    end
    
    describe 'when has_transcript_isoforms is "1"' do
      before (:each) do
        @it.has_transcript_isoforms = '1'
      end
      
      it_should_behave_like 'any option'
      
      it 'should require an uploaded transcript isoforms file'
    end
    
    describe 'when has_transcript_isoforms is "0"' do
      before (:each) do
        @it.has_transcript_isoforms = '1'
      end
      
      it_should_behave_like 'any option'
      
      it 'should not require an uploaded transcript isoforms file'
    end
  end
  
  describe 'flow control', :type => :white_box do
    before(:each) do
      @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
      #Stub all the methods since we are just testing control flow
      @it.stub(:process_args_to_create_dataset)
      @it.stub(:process_gene_differential_expression_file)
      @it.stub(:process_transcript_differential_expression_file)
      @it.stub(:process_transcript_isoforms_file)
      @it.stub(:find_and_process_go_terms)
      @it.stub(:delete_uploaded_files)
      UploadUtil.stub(:create_blast_database)
      UploadUtil.stub(:rollback_blast_database)
      QueryAnalysisMailer.stub(:notify_user_of_upload_success)
      QueryAnalysisMailer.stub(:notify_user_of_upload_failure)
    end
    
    shared_examples_for 'all options when an exception occurs' do
      before (:each) do
        UploadUtil.stub(:create_blast_database){raise SeededTestException}
      end
      
      it 'should call valid?' do
        @it.should_receive(:valid?)
        @it.save
      end
      it 'should call QueryAnalysisMailer.notify_user_of_upload_failure'do
        begin
          QueryAnalysisMailer.should_receive(:notify_user_of_upload_failure)
          @it.save
        rescue SeededTestException => ex
        end
      end
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_success' do
        begin 
          QueryAnalysisMailer.should_receive(:notify_user_of_upload_failure)
          @it.save 
        rescue SeededTestException => ex
        end
      end
      it 'should rollback the blast database' do
        begin
          UploadUtil.should_receive(:rollback_blast_database)
          @it.save
        rescue SeededTestException => ex
        end
      end
      it 'should delete the uploaded files' do
        begin 
          @it.should_receive(:delete_uploaded_files)
          @it.save
        rescue SeededTestException => ex
        end
      end
    end
    
    shared_examples_for 'all options when no exception occurs' do
      it 'should call valid?' do
        @it.should_receive(:valid?)
        @it.save
      end
      it 'should call process_args_to_create_dataset' do
        @it.should_receive(:process_args_to_create_dataset)
        @it.save
      end
      it 'should call UploadUtil.create_blast_database' do
        UploadUtil.should_receive(:create_blast_database)
        @it.save
      end
      it 'should call QueryAnalysisMailer.notify_user_of_upload_success' do
        QueryAnalysisMailer.should_receive(:notify_user_of_upload_success)
        @it.save
      end
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_failure' do
        QueryAnalysisMailer.should_not_receive(:notify_user_of_upload_failure)
        @it.save
      end
      it 'should not call UploadUtil.rollback_blast_database' do
        UploadUtil.should_not_receive(:rollback_blast_database)
        @it.save
      end
      it 'should delete the uploaded files' do
        @it.should_receive(:delete_uploaded_files)
        @it.save
      end
    end
    
    describe 'when both has_transcript_isoforms and has_diff_exp are "1"' do
      before (:each) do
        @it.has_diff_exp = '1'
        @it.has_transcript_isoforms = '1'
      end

      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      
      it 'should call process_transcript_differential_expression_file' do
        @it.should_receive(:process_transcript_differential_expression_file)
        @it.save
      end
      
      it 'should call process_gene_differential_expression_file' do
        @it.should_receive(:process_gene_differential_expression_file)
        @it.save
      end
      it 'should call process_transcript_isoforms_file' do
        @it.should_receive(:process_transcript_isoforms_file)
        @it.save
      end
      it 'should call find_and_process_go_terms' do
        @it.should_receive(:find_and_process_go_terms)
        @it.save
      end
    end
    
    describe 'when has_transcript_isoforms is "1" but has_diff_exp is "0" ' do
      before (:each) do
        @it.has_diff_exp = '0'
        @it.has_transcript_isoforms = '1'
      end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      
      it 'should not call process_transcript_differential_expression_file' do
        @it.should_not_receive(:process_transcript_differential_expression_file)
        @it.save
      end
      
      it 'should not call process_gene_differential_expression_file' do
        @it.should_not_receive(:process_gene_differential_expression_file)
        @it.save
      end
      it 'should call process_transcript_isoforms_file' do
        @it.should_receive(:process_transcript_isoforms_file)
        @it.save
      end
      it 'should call find_and_process_go_terms' do
        @it.should_receive(:find_and_process_go_terms)
        @it.save
      end
    end
    
    describe 'when has_transcript_isoforms is "0" but has_diff_exp is "1" ' do
      before (:each) do
        @it.has_diff_exp = '1'
        @it.has_transcript_isoforms = '0'
      end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      
      it 'should call process_transcript_differential_expression_file' do
        @it.should_receive(:process_transcript_differential_expression_file)
        @it.save
      end
      
      it 'should call process_gene_differential_expression_file' do
        @it.should_receive(:process_gene_differential_expression_file)
        @it.save
      end
      it 'should not call process_transcript_isoforms_file' do
        @it.should_not_receive(:process_transcript_isoforms_file)
        @it.save
      end
      it 'should call find_and_process_go_terms' do
        @it.should_receive(:find_and_process_go_terms)
        @it.save
      end
    end
    
    describe 'when both has_transcript_isoforms and has_diff_exp are "0"' do
      before (:each) do
        @it.has_diff_exp = '0'
        @it.has_transcript_isoforms = '0'
      end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      
      it 'should not call process_transcript_differential_expression_file' do
        @it.should_not_receive(:process_transcript_differential_expression_file)
        @it.save
      end
      
      it 'should not call process_gene_differential_expression_file' do
        @it.should_not_receive(:process_gene_differential_expression_file)
        @it.save
      end
      it 'should not call process_transcript_isoforms_file' do
        @it.should_not_receive(:process_transcript_isoforms_file)
        @it.save
      end
      it 'should not call find_and_process_go_terms' do
        @it.should_not_receive(:find_and_process_go_terms)
        @it.save
      end
    end
  end
  
  describe 'database/email/file interaction', :type => :black_box do
    
    shared_examples_for 'any number of samples when an exception occurs' do
      it 'should add 0 datasets to the database'
      it 'should add 0 users to the database'
      it 'should add 0 transcripts to the database'
      it 'should add 0 genes to the database'
      it 'should add 0 fpkm samples to the database'
      it 'should add 0 samples to the database'
      it 'should add 0 sample comparisons to the database'
      it 'should add 0 differential expression tests to the database'
      it 'should add 0 transcript has go terms to the database'
      it 'should add 0 transcript fpkm tracking informations to the database'
      it 'should add 0 go terms to the database'
      it 'should rollback the blast database'
      it 'should send an email notifying user of failure'
    end
    
    shared_examples_for 'any number of samples when no exception occurs' do
      it 'should create 1 blast database' do
        exec_path = "#{Rails.root}/bin/blast/bin"
        database_path = "db/blast_databases/test/#{dataset.id}_db"
        result = system("#{exec_path}/blastdbcmd -info -db #{database_path}")
        result.should be_true
      end
      
      it 'should create 1 dataset'
      it 'should create 0 users'
      it 'should send 1 email notifying the user of success'
    end
    
    shared_examples_for 'any number of samples regardless of whether an exception occurs' do
      #TODO?: Move to white box and make two methods for each, such as:
      #it 'should delete the transcripts diff exp file when it is not nil' do
      #  File.should_receive(:delete).with(@it.transcript_diff_exp_file.tempfile.path)
      #  @it.save
      #end
      #it 'should not try to delete the transcript diff exp file when not nil' do
      #  @it.transcript_diff_exp_file = nil
      #  File.should_not_receive(:delete).with(@it.transcript_diff_exp_file.tempfile.path)
      #  @it.save
      #end
      it 'should delete the uploaded files' do 
        if @it.transcripts_fasta_file.nil?
          File.should_not_receive(:delete).with(@it.transcripts_fasta_file.tempfile.path)
        else
          File.should_receive(:delete).with(@it.transcripts_fasta_file.tempfile.path)
        end
        if @it.transcript_diff_exp_file.nil?
          File.should_not_receive(:delete).with(@it.transcript_diff_exp_file.tempfile.path)
        else
          File.should_receive(:delete).with(@it.transcript_diff_exp_file.tempfile.path)
        end
        if @it.gene_diff_exp_file.nil?
          File.should_not_receive(:delete).with(@it.gene_diff_exp_file.tempfile.path)
        else
          File.should_receive(:delete).with(@it.gene_diff_exp_file.tempfile.path)
        end
        if @it.transcript_isoforms_file.nil?
          File.should_not_receive(:delete).with(@it.transcript_isoforms_file.tempfile.path)
        else
          File.should_receive(:delete).with(@it.transcript_isoforms_file.tempfile.path)
        end
        @it.save
      end
    end
    
    describe 'for 1 sample' do
      before(:each) do
        @it = FactoryGirl.build(:upload_cuffdiff_with_1_sample)
        #Stub blast2go because it takes a long time
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/1_sample/go_terms.annot"
        }
      end
          
      describe 'when it has transcript isoforms only' do
        it_should_behave_like 'any number of samples when an exception occurs'
        it_should_behave_like 'any number of samples when no exception occurs'
        it_should_behave_like 'any number of samples regardless of whether an exception occurs'
        
        it 'should add X transcripts to the database'
        it 'should add X genes to the database'
        it 'should add X fpkm samples to the database'
        it 'should add X samples to the database'
        it 'should add X sample comparisons to the database'
        it 'should add X differential expression tests to the database'
        it 'should add X transcript has go terms to the database'
        it 'should add X transcript fpkm tracking informations to the database'
        it 'should add X go terms to the database'
        it 'should add X go terms to the database if Y already exist in the database'
        
      end
      
      describe 'when it has no transcript isoforms' do
        it_should_behave_like 'any number of samples when an exception occurs'
        it_should_behave_like 'any number of samples when no exception occurs'
        it_should_behave_like 'any number of samples regardless of whether an exception occurs'
        
        it 'should have 0 transcripts'
        #etc.
      end
    end
    
    describe 'for 2 sample' do
      before(:each) do 
        @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
        #Stub the generate go terms method so we don't need to run blast2go
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/2_samples/go_terms.annot"
        }
      end
      
      #TODO: Put these below??
      it_should_behave_like 'any number of samples when an exception occurs'
      it_should_behave_like 'any number of samples when no exception occurs' 
      it_should_behave_like 'any number of samples regardless of whether an exception occurs'

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
        @it = FactoryGirl.build(:upload_cuffdiff_with_3_samples)
        #Stub the generate go terms method so we don't need to run blast2go
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/3_samples/go_terms.annot"
        }
      end
      
      it_should_behave_like 'any number of samples when an exception occurs'
      it_should_behave_like 'any number of samples when no exception occurs'
      it_should_behave_like 'any number of samples regardless of whether an exception occurs'

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
        @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
        #Stub the generate go terms method so we don't need to run blast2go
        UploadUtil.stub(:generate_go_terms){
          "#{@test_files_path}/2_samples/go_terms.annot"
        }
      end
      
      it_should_behave_like 'any number of samples when an exception occurs'
      it_should_behave_like 'any number of samples when no exception occurs'
      
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
