class WorkerForUploadCuffdiff
  include SuckerPunch::Worker
  
  def perform(upload_cuffdiff)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_cuffdiff.save
    end
  end
end