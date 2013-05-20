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
