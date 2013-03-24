class WorkerForUploadFastaSequences
  include SuckerPunch::Worker
  
  def perform(upload_fasta_sequences)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_fasta_sequences.save
    end
  end
end
