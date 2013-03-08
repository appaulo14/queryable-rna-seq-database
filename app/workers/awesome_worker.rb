class AwesomeWorker
  include SuckerPunch::Worker

  def perform(upload_cuffdiff)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      ActiveRecord::Base.transaction do   #Transactions work with sub-methods
        sleep 20
        puts 'AWESOME WORKER'
        puts 'PAWL'
        puts 'PAWL'
        puts 'PAWL'
        puts 'PAWL'
        
#         dataset = process_args_to_create_dataset(upload_cuffdiff)
#         process_gene_differential_expression_file(upload_cuffdiff, dataset)
#         process_transcript_differential_expression_file(upload_cuffdiff, dataset)
#         process_transcript_isoforms_file(upload_cuffdiff, dataset)
      end
    end
  end
  
  private
  def process_args_to_create_dataset(upload_cuffdiff)
    dataset = Dataset.new(:user => upload_cuffdiff.current_user,
                          :name => upload_cuffdiff.dataset_name,
                          :program_used => :cuffdiff)
    if upload_cuffdiff.has_diff_exp == '1'
      dataset.has_transcript_diff_exp = true
      dataset.has_gene_diff_exp = true
    else
      dataset.has_transcript_diff_exp = false
      dataset.has_gene_diff_exp = false
    end
    if upload_cuffdiff.has_transcript_isoforms == '1'
      dataset.has_transcript_isoforms = true
    else
      dataset.has_transcript_isoforms = false
    end
    dataset.blast_db_location = "db/blast_databases/#{Rails.env}/"
    dataset.save!
    dataset.blast_db_location = "db/blast_databases/#{Rails.env}/#{dataset.id}"
    dataset.save!
    return dataset
  end
  
  def process_gene_differential_expression_file(upload_cuffdiff, dataset)
    upload_cuffdiff.gene_diff_exp_file.tempfile.readline #skip the header line
    while not upload_cuffdiff.gene_diff_exp_file.tempfile.eof?
      line = upload_cuffdiff.gene_diff_exp_file.tempfile.readline
      next if line.blank?
      cells = line.split("\t")
      #Create the genes
      gene = Gene.create!(:dataset => dataset, 
                          :name_from_program => cells[0])
      #Create sample 1 if not already created
      sample_1_name = cells[4]
      sample_1 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_1_name)[0]
      if sample_1.nil?
        sample_1 = Sample.create!(:name => sample_1_name, 
                                  :dataset => dataset)
      end
      #Create sample 2 if not already created
      sample_2_name = cells[5]
      sample_2 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_2_name)[0]
      if sample_2.nil?
        sample_2 = Sample.create!(:name => sample_2_name, 
                                  :dataset => dataset)
      end
      #Create the sample comparison if not already created
      sample_comparison = 
          SampleComparison.where(:sample_1_id => sample_1.id, 
                                :sample_2_id => sample_2.id)[0]
      if sample_comparison.nil?
        sample_comparison = 
            SampleComparison.create!(:sample_1 => sample_1, 
                                    :sample_2 => sample_2)
      end
      #Create the differential expression test
      DifferentialExpressionTest.create!(:gene => gene,
                                          :test_status => cells[6],
                                          :sample_1_fpkm => cells[7],
                                          :sample_2_fpkm => cells[8],
                                          :log_fold_change => cells[9],
                                          :test_statistic => cells[10],
                                          :p_value => cells[11],
                                          :fdr => cells[12],
                                          :sample_comparison => sample_comparison)
    end
  end
  
  def process_transcript_differential_expression_file(upload_cuffdiff, dataset)
    upload_cuffdiff.transcript_diff_exp_file.tempfile.readline #skip the header line
    while not upload_cuffdiff.transcript_diff_exp_file.tempfile.eof?
      line = upload_cuffdiff.transcript_diff_exp_file.tempfile.readline
      next if line.blank?
      cells = line.split("\t")
      next if cells.blank?
      gene = Gene.where(:dataset_id => dataset.id,
                        :name_from_program => cells[1])[0]
      transcript = Transcript.create!(:dataset => dataset, 
                                      :name_from_program => cells[0],
                                      :gene => gene)
      #Create sample 1 if not already created
      sample_1_name = cells[4]
      sample_1 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_1_name)[0]
      if sample_1.nil?
        sample_1 = Sample.create!(:name => sample_1_name, 
                                  :dataset => dataset)
      end
      #Create sample 2 if not already created
      sample_2_name = cells[5]
      sample_2 = Sample.where(:dataset_id => dataset.id, 
                              :name => sample_2_name)[0]
      if sample_2.nil?
        sample_2 = Sample.create!(:name => sample_2_name, 
                                  :dataset => dataset)
      end
      #Create the sample comparison if not already created
      sample_comparison = 
          SampleComparison.where(:sample_1_id => sample_1.id, 
                                  :sample_2_id => sample_2.id)[0]
      if sample_comparison.nil?
        sample_comparison = 
            SampleComparison.create!(:sample_1 => sample_1, 
                                      :sample_2 => sample_2)
      end
      #Create the differential expression test
      debugger if cells[6].blank?
      DifferentialExpressionTest.create!(:transcript => transcript,
                                          :test_status => cells[6],
                                          :sample_1_fpkm => cells[7],
                                          :sample_2_fpkm => cells[8],
                                          :log_fold_change => cells[9],
                                          :test_statistic => cells[10],
                                          :p_value => cells[11],
                                          :fdr => cells[12],
                                          :sample_comparison => sample_comparison)
    end
  end
  
  def process_transcript_isoforms_file(upload_cuffdiff, dataset)
    headers = upload_cuffdiff.transcript_isoforms_file.tempfile.readline.split("\t")
    samples = []
    next_index = 9
    while (next_index < headers.count)
      sample_name = headers[next_index].match(/(.+)_FPKM/).captures[0]
      samples << Sample.where(:dataset_id => dataset.id,
                              :name => sample_name)[0]
      next_index = next_index + 4
    end
    while not upload_cuffdiff.transcript_isoforms_file.tempfile.eof?
      line = upload_cuffdiff.transcript_isoforms_file.tempfile.readline
      next if line.blank?
      cells = line.split("\t")
      transcript = Transcript.where(:dataset_id => dataset.id,
                                    :name_from_program => cells[0])[0]
      TranscriptFpkmTrackingInformation.create!(:transcript => transcript,
                                                :class_code => cells[1],
                                                :length => cells[7],
                                                :coverage => cells[8])
      if transcript.gene.nil?
        gene = Gene.where(:dataset_id => dataset.id,
                          :name_from_program => cells[3])[0]
        transcript.gene = gene
      end
      (0..samples.count-1).each do |i|
        sample = samples[i]
        FpkmSample.create!(:transcript => transcript,
                          :sample => sample,
                          :fpkm => cells[9+(3*i)],
                          :fpkm_lo => cells[10+(3*i)],
                          :fpkm_hi => cells[11+(3*i)],
                          :status => cells[12+(3*i)])
      end
    end
  end
end