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
