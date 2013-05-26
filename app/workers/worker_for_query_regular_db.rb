###
# Worker class that runs jobs to email regular database query results to a 
# user as a text file. It does this in a background queue so that the user 
# can continue to do other things while the go terms for their dataset 
# are being found.
class WorkerForQueryRegularDb
  include SuckerPunch::Worker
  
  ###
  # The method for the worker to perform its work
  def perform(query_regular_db)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      query_regular_db.query()
    end
  end
end
