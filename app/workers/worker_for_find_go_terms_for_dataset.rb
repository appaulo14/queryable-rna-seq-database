class WorkerForFindGoTermsForDataset
  include SuckerPunch::Worker
  
  def perform(find_go_terms_for_dataset)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      find_go_terms_for_dataset.find_and_save()
    end
  end
end
