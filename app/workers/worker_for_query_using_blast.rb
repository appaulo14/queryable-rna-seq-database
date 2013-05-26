###
# Worker class that runs jobs to email blast results to a user as an html file. 
# It does this in a background queue so that the user 
# can continue to do other things while the go terms for their dataset 
# are being found.
class WorkerForQueryUsingBlast
  include SuckerPunch::Worker
  
  ###
  # The method for the worker to perform its work
  def perform(query_using_blast)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      query_using_blast.blast()
    end
  end
end
