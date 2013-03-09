require 'spec_helper'

describe UploadCuffdiff do
  before(:all) do
    DatabaseCleaner.clean
    @current_user = FactoryGirl.create(:user, :email => 'nietz111@ksu.edu')
  end
  
  after(:all) do
    DatabaseCleaner.clean
    #@current_user.destroy
  end
  
  before(:each) do 
    #Change to the directory of this spec
    Dir.chdir("#{Rails.root}/spec/view_models/query_analysis")
    #Make copies of the test files
    FileUtils.copy('test_files/cuffdiff/transcripts.fasta','cuffdiff_fasta_file')
    FileUtils.copy('test_files/cuffdiff/isoform_exp.diff','transcript_diff_exp_file')
    FileUtils.copy('test_files/cuffdiff/gene_exp.diff', 'gene_diff_exp_file')
    FileUtils.copy('test_files/cuffdiff/isoforms.fpkm_tracking','transcript_isoform_file')
    #Open the test files
    cuffdiff_fasta_file = File.new('cuffdiff_fasta_file','r')
    transcript_diff_exp_file = File.new('transcript_diff_exp_file','r')
    gene_diff_exp_file = File.new('gene_diff_exp_file','r')
    transcript_isoform_file = File.new('transcript_isoform_file','r')
    #Create the uploaded file objects
    uploaded_fasta_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>cuffdiff_fasta_file})
    uploaded_transcript_diff_exp_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>transcript_diff_exp_file})
    uploaded_gene_diff_exp_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>gene_diff_exp_file})
    uploaded_transcript_isoform_file = 
      ActionDispatch::Http::UploadedFile.new({:tempfile=>transcript_isoform_file})
    #Create and fill in the class
    @it = UploadCuffdiff.new(@current_user)
    @it.set_attributes_and_defaults()
    @it.dataset_name = 'Test Dataset'
    @it.has_diff_exp = true
    @it.has_transcript_isoforms = true
    @it.transcripts_fasta_file = uploaded_fasta_file
    @it.transcript_diff_exp_file = uploaded_transcript_diff_exp_file
    @it.gene_diff_exp_file = uploaded_gene_diff_exp_file 
    @it.transcript_isoforms_file = uploaded_transcript_isoform_file
    #@it.delay.save!
    #UploadUtil.stub(:create_blast_database){puts 'STUB OF BLAST DATABASE'}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  describe '2 samples' do
    describe 'when valid' do
    end
    
    describe 'when an exception occurs' do
    end
  end
  
  describe '3 samples' do
    describe 'when valid' do
    end
    
    describe 'when an exception occurs' do
    end
  end
  
  describe '4 samples' do 
    describe 'when valid' do
    end
    
    describe 'when an exception occurs' do
    end
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
  
  it 'should create a blast database' do
    #@it.save
#     ds = double("Dataset")
#     ds.should_receive(:name)
#     ds.name
    #ds.should_receive(:name)
#     UploadUtil.create_blast_databas("",FactoryGirl.create(:dataset))
    UploadUtil.should_receive(:create_blast_database).with(kind_of(String),kind_of(Dataset))
    #UploadUtil.create_blast_database("",FactoryGirl.create(:dataset))
    @it.save
  end
  
  it 'should delete the blast database on rollback if it was created'
  
  it 'should put the blast database it the right place'
  #blastdbcmd -info -db db/blast_databases/dev/1_db
  
  it 'should work for 4 samples'
  
  it 'should if successful email the user an email announcing success' do
    @it.save
    ActionMailer::Base.deliveries.count.should eq(1)
    ActionMailer::Base.deliveries.last.to.should eq([@current_user.email])
    ActionMailer::Base.deliveries.last.subject.should match('Success')
  end
  
  it 'should if unsuccessful email the user announcing failure' do
    #Seed an error
   lambda do
    UploadUtil.stub(:create_blast_database){raise Exception, 'Seeded exception'}
    @it.save
   end.should raise_error(Exception, 'Seeded exception')
    ActionMailer::Base.deliveries.count.should eq(1)
    ActionMailer::Base.deliveries.last.to.should eq([@current_user.email])
    ActionMailer::Base.deliveries.last.subject.should match('Fail')
  end
  
  it 'should be transactional, writing either all the data or none at all'
  
#   it 'should link the dataset to the user' do
#     @it.save
#     @it.dataset.user.id.should eq(@current_user.id)
#   end
#   
#   it 'should add 0 users to the database' do
#     lambda do
#       @it.save
#     end.should change(User, :count).by(0)
#   end
#   
#   it 'should add 1 dataset to the database' do
#     lambda do
#       @it.save
#     end.should change(Dataset, :count).by(1)
#   end
#   
#   it 'should add 10 transcripts to the database' do
#     Transcript.count.should eq(10)
#   end
#   
#   it 'should add 10 genes to the database' do
#     Gene.count.should eq(10)
#   end
#   
#   it 'should add 10 sets of transcript fpkm tracking information to the database' do
#     TranscriptFpkmTrackingInformation.count.should eq(10)
#   end
#   
#   it 'should add 20 fpkm samples to the database' do
#     FpkmSample.count.should eq(20)
#   end
  
#   it 'should add 2 samples to the database' do
#     lambda do
#       @it.save
#     end.should change(Sample, :count).by(2)
#   end
#   
#   it 'should add 1 sample comparison to the database' do
#     lambda do
#       @it.save
#     end.should change(SampleComparison, :count).by(1)
#   end
  
#   it 'should add 20 differential expression tests to the database' do
#     DifferentialExpressionTest.count.should eq(20)
#   end
#   
#   it 'should add 55 go terms to the database' do
#     GoTerm.count.should eq(55)
#   end
#   
#   it 'should add 76 transcript has go terms to the database' do
#     TranscriptHasGoTerm.count.should eq(76)
#   end
  
#   it 'should delete the uploaded files when done' do
#     File.exists?(@it.transcripts_fasta_file.tempfile.path).should be_false
#     File.exists?(@it.transcript_diff_exp_file.tempfile.path).should be_false
#     File.exists?(@it.gene_diff_exp_file.tempfile.path).should be_false
#     File.exists?(@it.transcript_isoforms_file.tempfile.path).should be_false
#   end
end
