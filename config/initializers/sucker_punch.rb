SuckerPunch.config do
  queue name: :query_regular_db_queue, 
                worker: WorkerForQueryRegularDb, size: 10
end
