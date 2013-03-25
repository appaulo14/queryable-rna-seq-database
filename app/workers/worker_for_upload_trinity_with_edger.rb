class WorkerForUploadTrinityWithEdger
  include SuckerPunch::Worker
  
  def perform(upload_trinity_with_edger)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_trinity_with_edger.save
    end
  end
end
