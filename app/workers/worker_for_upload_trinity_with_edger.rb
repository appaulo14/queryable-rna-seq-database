###
# Worker class that runs jobs to upload a Trinity with EdgeR dataset in 
# a background queue so that the user can continue to do other 
# things while their dataset is being uploaded.
class WorkerForUploadTrinityWithEdger
  include SuckerPunch::Worker
  
  ###
  # The method for the worker to perform its work
  def perform(upload_trinity_with_edger)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_trinity_with_edger.save
    end
  end
end
