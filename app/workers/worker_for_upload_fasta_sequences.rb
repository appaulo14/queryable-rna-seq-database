###
# Worker class that runs jobs to upload a fasta sequences dataset in a 
# background queue so that the user can continue to do other 
# things while their dataset is being uploaded.
class WorkerForUploadFastaSequences
  include SuckerPunch::Worker
  
  ###
  # The method for the worker to perform its work
  def perform(upload_fasta_sequences)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_fasta_sequences.save
    end
  end
end
