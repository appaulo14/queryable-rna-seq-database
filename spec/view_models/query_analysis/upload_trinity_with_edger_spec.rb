require 'spec_helper'
require 'view_models/shared_examples.rb'
require 'upload/blast_util.rb'

describe UploadTrinityWithEdgeR do
  before(:all) do
    DatabaseCleaner.clean
  end
  
  before(:each) do
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    before(:each) do
      test_vm = :upload_trinity_with_edger_with_2_samples
      @it = FactoryGirl.build(test_vm)
    end
    
    it 'should be valid when all field are valid' do
      @it.should be_valid
    end
    
    it 'should not be valid if the transcript_diff_exp_files and ' +
       'gene_diff_exp_files are different lengths' do
      uploaded_files = []
      uploaded_files << to_cuffdiff_uploaded_file(2,'transcripts.fasta')
      uploaded_files << to_cuffdiff_uploaded_file(2,'transcripts.fasta')
      @it.gene_diff_exp_files = uploaded_files
      @it.transcript_diff_exp_files = uploaded_files[0..0]
      @it.should_not be_valid
    end
    
    describe 'transcripts_fasta_file' do
      before(:each) do @attribute = 'transcripts_fasta_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'gene_diff_exp_files' do
      before(:each) do @attribute = 'gene_diff_exp_files' end
      
      it_should_behave_like 'an array of uploaded files'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'gene_fpkm_file' do
      before(:each) do @attribute = 'gene_fpkm_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'transcript_diff_exp_files' do
      before(:each) do @attribute = 'transcript_diff_exp_files' end
      
      it_should_behave_like 'an array of uploaded files'
      it_should_behave_like 'a required attribute'
    end
    
    describe 'transcript_fpkm_file' do
      before(:each) do @attribute = 'transcript_fpkm_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'dataset_name' do
      before(:each) do @attribute = 'dataset_name' end
      
      it_should_behave_like 'a required attribute'
    end
  end
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
    
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    describe 'for 2 samples' do
      before(:each) do
        test_vm=:upload_trinity_with_edger_with_2_samples
        @it = FactoryGirl.build(test_vm)
      end
      
      describe 'when it has genes and transcripts' do
        before(:each) do @it.has_gene_diff_exp = '1' end
        
        it 'should add 6 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(6)
        end
        it 'should add 4 genes to the database' do
          lambda do
            @it.save
          end.should change(Gene,:count).by(4)
        end
        it 'should have 4 transripts with associated genes' do
          @it.save
          associated_genes_count = 0
          Transcript.all.each do |transcript|
            associated_genes_count += 1 if not transcript.gene.nil?
          end
          associated_genes_count.should eq(4)
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
        it 'should add 2 samples with a type of gene to the database' do
          lambda do
            @it.save
          end.should change(Sample.where(:sample_type => 'gene'),:count).by(2)
        end
        it 'should add 2 samples with a type of transcript to the database' do
          lambda do
            @it.save
          end.should change(Sample.where(:sample_type => :transcript),:count).by(2)
        end
        it 'should add 2 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(2)
        end
        it 'should add 10 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(10)
        end
        it 'should have no differential expression tests with null fpkms' do
          @it.save
          DifferentialExpressionTest.all.each do |det|
            debugger if det.sample_1_fpkm.nil? or det.sample_2_fpkm.nil?
            det.sample_1_fpkm.should_not be_nil
            det.sample_2_fpkm.should_not be_nil
          end
        end
        it 'should add 250 transcript has go terms to the database' 
  #       do
  #         lambda do
  #           @it.save
  #         end.should change(TranscriptHasGoTerm,:count).by(250)
  #       end
        it 'should add 0 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
        end
        it 'should add 88 go terms to the database'
  #       do
  #         lambda do
  #           @it.save
  #         end.should change(GoTerm,:count).by(88)
  #       end
        it 'should add 0 go terms to the database if they already exist in the database'
  #       do
  #         @it.save
  #         lambda do
  #           FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
  #         end.should change(GoTerm,:count).by(0)
  #       end
        
        it_should_behave_like 'any upload view model when no exception occurs'
        it_should_behave_like 'any upload view model when an exception occurs' 
      end
      
      describe 'when it has transcripts only' do
        before(:each) do @it.has_gene_diff_exp = '0' end
      
        it 'should add 6 transcripts to the database' do
          lambda do
            @it.save
          end.should change(Transcript,:count).by(6)
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
        it 'should add 2 samples to the database' do
          lambda do
            @it.save
          end.should change(Sample,:count).by(2)
        end
        it 'should add 2 samples with a type of transcript to the database' do
          lambda do
            @it.save
          end.should change(Sample.where(:sample_type => 'transcript'),:count).by(2)
        end
        it 'should add 1 sample comparisons to the database' do
          lambda do
            @it.save
          end.should change(SampleComparison,:count).by(1)
        end
        it 'should add 6 differential expression tests to the database' do
          lambda do
            @it.save
          end.should change(DifferentialExpressionTest,:count).by(6)
        end
        it 'should have no differential expression tests with null fpkms' do
          @it.save
          DifferentialExpressionTest.all.each do |det|
            det.sample_1_fpkm.should_not be_nil
            det.sample_2_fpkm.should_not be_nil
          end
        end
        it 'should add 26 transcript has go terms to the database' 
  #       do
  #         lambda do
  #           @it.save
  #         end.should change(TranscriptHasGoTerm,:count).by(250)
  #       end
        it 'should add 0 transcript fpkm tracking informations to the database' do
          lambda do
            @it.save
          end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
        end
        it 'should add 88 go terms to the database'
  #       do
  #         lambda do
  #           @it.save
  #         end.should change(GoTerm,:count).by(88)
  #       end
        it 'should add 0 go terms to the database if they already exist in the database'
  #       do
  #         @it.save
  #         lambda do
  #           FactoryGirl.build(:upload_cuffdiff_with_2_samples).save
  #         end.should change(GoTerm,:count).by(0)
  #       end
        
        it_should_behave_like 'any upload view model when no exception occurs'
        it_should_behave_like 'any upload view model when an exception occurs' 
      end
    end
  end
end
