class WorkerForUploadTrinityWithEdgerTranscriptsAndGenes
  include SuckerPunch::Worker
  
  def perform(upload_trinity_with_edger_transcripts_and_genes)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_trinity_with_edger_transcripts_and_genes.save
    end
  end
end
