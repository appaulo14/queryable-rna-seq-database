###
# Worker class that runs jobs to find the Gene Ontology (GO) terms for a 
# dataset in a background queue so that the user can continue to do other 
# things while the go terms for their dataset are being found.
class WorkerForFindGoTermsForDataset
  include SuckerPunch::Worker
  
  ###
  # The method for the worker to perform its work
  def perform(find_go_terms_for_dataset)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      find_go_terms_for_dataset.find_and_save()
    end
  end
end
