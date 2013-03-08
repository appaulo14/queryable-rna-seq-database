SuckerPunch.config do
  queue name: :log_queue, worker: LogWorker, size: 10
  queue name: :awesome_queue, worker: AwesomeWorker, size: 10
end