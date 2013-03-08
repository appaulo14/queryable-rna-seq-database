class LogWorker
  include SuckerPunch::Worker

  def perform(event)
    Log.new(event).track
  end
end