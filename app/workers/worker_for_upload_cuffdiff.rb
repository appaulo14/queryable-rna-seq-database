###
# Worker class that runs jobs to upload a Cuffdiff dataset in a background 
# queue so that the user can continue to do other 
# things while their dataset is being uploaded.
class WorkerForUploadCuffdiff
  include SuckerPunch::Worker
  
  ###
  # The method for the worker to perform its work
  def perform(upload_cuffdiff)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_cuffdiff.save
    end
  end
end
