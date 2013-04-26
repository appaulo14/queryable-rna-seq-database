require 'spec_helper'
require 'view_models/shared_examples.rb'
require 'upload/blast_util.rb'

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
    DatabaseCleaner.clean
    #system("rm #{Rails.root}/db/blast_databases/test/*")
  end
  
  it 'should properly log exceptions'
  
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
        
    describe 'has_diff_exp' do
      before(:each) do @attribute = 'has_diff_exp' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'a view model-style boolean'
    end
    
    describe 'has_transcript_isoforms' do
      before(:each) do @attribute = 'has_transcript_isoforms' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'a view model-style boolean'
    end
    
    describe 'dataset_name' do
      before(:each) do @attribute = 'dataset_name' end
      
      it_should_behave_like 'a required attribute'
    end
  end
  
  
  describe 'flow control', :type => :white_box do
    before(:each) do
      @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
      #Stub all the methods since we are just testing control flow
      #@it.stub(:process_args_to_create_dataset){@it.instance_eval('@dataset = Fact)}
      @it.stub(:process_gene_differential_expression_file)
      @it.stub(:process_transcript_differential_expression_file)
      @it.stub(:process_transcript_isoforms_file)
      @it.stub(:find_and_process_go_terms)
      @it.stub(:delete_uploaded_files)
      @it.stub(:valid?).and_return(true)
      BlastUtil.stub(:makeblastdb_with_seqids)
      BlastUtil.stub(:rollback_blast_database)
      QueryAnalysisMailer.stub(:notify_user_of_upload_success)
      QueryAnalysisMailer.stub(:notify_user_of_upload_failure)
    end
    
    shared_examples_for 'all options when an exception occurs' do
      before (:each) do
        BlastUtil.stub(:makeblastdb_with_seqids){raise SeededTestException}
      end
      
      it 'should call QueryAnalysisMailer.notify_user_of_upload_failure' do
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
          BlastUtil.should_receive(:rollback_blast_database)
          @it.save
        rescue SeededTestException => ex
        end
      end
      it 'should delete the uploaded files'
#       do
#         begin 
#           @it.should_receive(:delete_uploaded_files)
#           @it.save
#         rescue SeededTestException => ex
#         end
#       end
    end
    
    shared_examples_for 'all options no matter whether an exception occurs' do
      before(:each) do
        @it.stub(:delete_uploaded_files).and_call_original
      end
      
      it 'should call valid?' do
        @it.should_receive(:valid?)
        @it.save
      end
    
#       it 'should delete transcripts_fasta_file if it exists' do
#         file_path = @it.transcripts_fasta_file.tempfile.path
#         File.should_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should not try to delete transcripts_fasta_file if it does not exist' do
#         file_path = @it.transcripts_fasta_file.tempfile.path
#         @it.transcripts_fasta_file = nil
#         File.should_not_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should delete gene_diff_exp_file if it exists' do
#         file_path = @it.gene_diff_exp_file.tempfile.path
#         File.should_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should not try to delete gene_diff_exp_file if it does not exist' do
#         file_path = @it.gene_diff_exp_file.tempfile.path
#         @it.gene_diff_exp_file = nil
#         File.should_not_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should delete transcript_diff_exp_file if it exists' do
#         file_path = @it.transcript_diff_exp_file.tempfile.path
#         File.should_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should not try to delete transcript_diff_exp_file if it does not exist' do
#         file_path = @it.transcript_diff_exp_file.tempfile.path
#         @it.transcript_diff_exp_file = nil
#         File.should_not_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should delete transcript_isoforms_file if it exists' do
#         file_path = @it.transcript_isoforms_file.tempfile.path
#         File.should_receive(:delete).with(file_path)
#         @it.save
#       end
#       it 'should not try to delete transcript_isoforms_file if it does not exist' do
#         file_path = @it.transcript_isoforms_file.tempfile.path
#         @it.transcript_isoforms_file = nil
#         File.should_not_receive(:delete).with(file_path)
#         @it.save
#       end
    end
    
    shared_examples_for 'all options when no exception occurs' do
      it 'should call process_args_to_create_dataset' do
        @it.should_receive(:process_args_to_create_dataset).and_call_original
        @it.save
      end
      it 'should call BlastUtil.makeblastdb_with_seqids' do
        BlastUtil.should_receive(:makeblastdb_with_seqids)
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
      it 'should not call BlastUtil.rollback_blast_database' do
        BlastUtil.should_not_receive(:rollback_blast_database)
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
      it 'should call find_and_process_go_terms'
#       do
#         @it.should_receive(:find_and_process_go_terms)
#         @it.save
#       end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options no matter whether an exception occurs'
    end
    
    describe 'when has_transcript_isoforms is "1" but has_diff_exp is "0" ' do
      before (:each) do
        @it.has_diff_exp = '0'
        @it.has_transcript_isoforms = '1'
      end
      
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
      it 'should call find_and_process_go_terms'
#       do
#         @it.should_receive(:find_and_process_go_terms)
#         @it.save
#       end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options no matter whether an exception occurs'
    end
    
    describe 'when has_transcript_isoforms is "0" but has_diff_exp is "1" ' do
      before (:each) do
        @it.has_diff_exp = '1'
        @it.has_transcript_isoforms = '0'
      end
      
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
      it 'should call find_and_process_go_terms'
#       do
#         @it.should_receive(:find_and_process_go_terms)
#         @it.save
#       end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options no matter whether an exception occurs'
    end
    
    describe 'when both has_transcript_isoforms and has_diff_exp are "0"' do
      before (:each) do
        @it.has_diff_exp = '0'
        @it.has_transcript_isoforms = '0'
      end
      
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
      it 'should not call find_and_process_go_terms'
#       do
#         @it.should_not_receive(:find_and_process_go_terms)
#         @it.save
#       end
      
      it_should_behave_like 'all options when an exception occurs'
      it_should_behave_like 'all options when no exception occurs'
      it_should_behave_like 'all options no matter whether an exception occurs'
    end
  end
  
  
  ########## Black Box Tests ########### 
  
  describe 'database/email/file interaction', :type => :black_box do    
    shared_examples_for 'any number of samples when ' +
                        'no differential expression tests or ' +
                        'transcript isoforms' do
                        
      it 'should add 0 transcripts to the database' do
        lambda do
          @it.save
        end.should change(Transcript,:count).by(0)
      end
      it 'should add 0 genes to the database' do
        lambda do
          @it.save
        end.should change(Gene,:count).by(0)
      end
      it 'should add 0 fpkm samples to the database' do
        lambda do
          @it.save
        end.should change(FpkmSample,:count).by(0)
      end
      it 'should add 0 samples to the database' do
        lambda do
          @it.save
        end.should change(Sample,:count).by(0)
      end
      it 'should add 0 sample comparisons to the database' do
        lambda do
          @it.save
        end.should change(SampleComparison,:count).by(0)
      end
      it 'should add 0 differential expression tests to the database' do
        lambda do
          @it.save
        end.should change(DifferentialExpressionTest,:count).by(0)
      end
      it 'should add 0 transcript has go terms to the database' 
#       do
#         lambda do
#           @it.save
#         end.should change(TranscriptHasGoTerm,:count).by(0)
#       end
      it 'should add 0 transcript fpkm tracking informations to the database' do
        lambda do
          @it.save
        end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
      end
      it 'should add 0 go terms to the database' do
        lambda do
          @it.save
        end.should change(GoTerm,:count).by(0)
      end
    end
    
    describe 'for 2 sample', :sub_type => :black_box_for_2_samples do
      before(:each) do 
        @it = FactoryGirl.build(:upload_cuffdiff_with_2_samples)
        #Stub the generate go terms method so we don't need to run blast2go
        BlastUtil.stub(:generate_go_terms){
          "#{@test_files_path}/2_samples/go_terms.annot"
        }
      end

      describe 'when it has differenntial expression tests and transcript isoforms' do
        before(:each) do
          @it.has_diff_exp = '1'
          @it.has_transcript_isoforms = '1'
        end
        
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 48 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(48)
        end
        it 'should add 2 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(2)
        end
        it 'should add 1 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(1)
        end
        it 'should add 34 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(34)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 24 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
        end
        it 'should add 88 go terms to the database' 
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if they already exist in the database'
#         do
#           @it.save
#           lambda do
#             FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has differential expression tests only' do
        before (:each) do
          @it.has_diff_exp = '1'
          @it.has_transcript_isoforms = '0'  
        end
        
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 0 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(0)
        end
        it 'should add 2 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(2)
        end
        it 'should add 1 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(1)
        end
        it 'should add 34 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(34)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 0 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
        end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if they already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it transcript isoforms only' do
        before (:each) do
          @it.has_diff_exp = '0'
          @it.has_transcript_isoforms = '1'
        end
      
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 48 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(48)
        end
        it 'should add 2 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(2)
        end
        it 'should add 0 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(0)
        end
        it 'should add 0 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(0)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 24 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
        end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if they already exist in the database'
#         do
#           @it.save
#           lambda do
#             FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has neither differenntial expression tests nor transcript isoforms' do
        before(:each) do
          @it.has_diff_exp = '0'
          @it.has_transcript_isoforms = '0'
        end
      
        it_should_behave_like 'any number of samples when ' +
                              'no differential expression tests or ' +
                              'transcript isoforms'
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
    end
    
    
    describe 'for 3 sample', :sub_type => :black_box_for_3_samples do
      before(:each) do 
        @it = FactoryGirl.build(:upload_cuffdiff_with_3_samples)
        #Stub the generate go terms method so we don't need to run blast2go
        BlastUtil.stub(:generate_go_terms){
          "#{@test_files_path}/3_samples/go_terms.annot"
        }
      end

      describe 'when it has differenntial expression tests and transcript isoforms' do
        before (:each) do
          @it.has_diff_exp = '1'
          @it.has_transcript_isoforms = '1'
        end
        
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 72 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(72)
        end
        it 'should add 3 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(3)
        end
        it 'should add 3 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(3)
        end
        it 'should add 102 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(102)
        end
        it 'should add 24 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if they already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_3_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has differenntial expression tests only' do
        before (:each) do
          @it.has_diff_exp = '1'
          @it.has_transcript_isoforms = '0'
        end
        
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 0 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(0)
        end
        it 'should add 3 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(3)
        end
        it 'should add 3 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(3)
        end
        it 'should add 102 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(102)
        end
        it 'should add 0 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if they already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_3_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has transcript isoforms only' do
        before (:each) do
          @it.has_diff_exp = '0'
          @it.has_transcript_isoforms = '1'
        end
      
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 72 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(72)
        end
        it 'should add 3 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(3)
        end
        it 'should add 0 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(0)
        end
        it 'should add 0 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(0)
        end
        it 'should add 24 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if they already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_3_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has neither differenntial expression tests nor transcript isoforms' do
        before (:each) do
          @it.has_diff_exp = '0'
          @it.has_transcript_isoforms = '0'
        end
      
        it_should_behave_like 'any number of samples when ' +
                              'no differential expression tests or ' +
                              'transcript isoforms'  
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
    end
    

    
    describe 'for 4 sample', :sub_type => :black_box_for_4_samples do
      before(:each) do 
        @it = FactoryGirl.build(:upload_cuffdiff_with_4_samples)
        #Stub the generate go terms method so we don't need to run blast2go
        BlastUtil.stub(:generate_go_terms){
          "#{@test_files_path}/4_samples/go_terms.annot"
        }
      end
      
      describe 'when it has differenntial expression tests and transcript isoforms' do
        before(:each) do
          @it.has_diff_exp = '1'
          @it.has_transcript_isoforms = '1'
        end
      
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 96 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(96)
        end
        it 'should add 4 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(4)
        end
        it 'should add 6 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(6)
        end
        it 'should add 204 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(204)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 24 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
        end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if Y already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_4_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has differenntial expression tests only' do
        before (:each) do
          @it.has_diff_exp = '1'
          @it.has_transcript_isoforms = '0'
        end
      
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 0 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(0)
        end
        it 'should add 4 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(4)
        end
        it 'should add 6 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(6)
        end
        it 'should add 204 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(204)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 0 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
        end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if Y already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_4_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it transcript isoforms only' do
        before(:each) do
          @it.has_diff_exp = '0'
          @it.has_transcript_isoforms = '1'
        end
      
        it 'should add 24 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(24)
        end
        it 'should add 10 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(10)
        end
        it 'should add 96 fpkm samples to the database' do
          lambda do
            @it.save
          end.should change(FpkmSample,:count).by(96)
        end
        it 'should add 4 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(4)
        end
        it 'should add 0 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(0)
        end
        it 'should add 0 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(0)
        end
        it 'should add 250 transcript has go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(TranscriptHasGoTerm,:count).by(250)
#         end
        it 'should add 24 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(24)
        end
        it 'should add 88 go terms to the database'
#         do
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(88)
#         end
        it 'should add 0 go terms to the database if Y already exist in the database'
#         do
#           FactoryGirl.build(:upload_cuffdiff_with_4_samples).save
#           lambda do
#             @it.save
#           end.should change(GoTerm,:count).by(0)
#         end
        
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
      
      describe 'when it has neither differenntial expression tests nor transcript isoforms' do
        before(:each) do
          @it.has_diff_exp = '0'
          @it.has_transcript_isoforms = '0'
        end
      
        it_should_behave_like 'any number of samples when ' +
                              'no differential expression tests or ' +
                              'transcript isoforms'
        it_should_behave_like 'any upload view model when an exception occurs'
        it_should_behave_like 'any upload view model when no exception occurs'
      end
    end
  end   
end
