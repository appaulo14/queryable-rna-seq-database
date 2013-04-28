RnaSeqAnalysisPipeline::Application.routes.draw do
  ###########################################################################
  ##########          Configure routes for home controller     ###############
  ###########################################################################
  get 'admin/view_confirmed_users'

  get 'admin/add_new_user_to_system'

  get 'admin/delete_datasets_from_database'
  
  get 'admin/view_unconfirmed_users'
  
  get  'admin/confirm_user'
  post 'admin/confirm_user'
  
  get  'admin/delete_unconfirmed_user'
  post 'admin/delete_unconfirmed_user'

  devise_for :users, :controllers => {
      :registrations => 'registrations', :confirmations => 'confirmations'
  } 

  ###########################################################################
  ##########          Configure routes for home controller     ###############
  ###########################################################################
  #Set the root page
  root :to => 'home#welcome'
  
  match 'home', :to => 'home#welcome'
  get 'home/welcome'
  
  get 'home/report_issue'
  post 'home/report_issue'

  ###########################################################################
  ##########     Configure routes for query analysis controller   ###########
  ###########################################################################
  get  'query_analysis/upload_cuffdiff'
  post 'query_analysis/upload_cuffdiff'
  
  get  'query_analysis/upload_fasta_sequences'
  post 'query_analysis/upload_fasta_sequences'
  
  get  'query_analysis/upload_trinity_with_edger'
  post 'query_analysis/upload_trinity_with_edger'
  
  get 'query_analysis/add_sample_cmp_for_trinity_with_edger_transcripts'
  
  get 'query_analysis/add_sample_cmp_for_trinity_with_edger_genes'
  
  get  'query_analysis/find_go_terms_for_dataset'
  post 'query_analysis/find_go_terms_for_dataset'
  
  get 'query_analysis/query_diff_exp_transcripts'
  post 'query_analysis/query_diff_exp_transcripts'
  
  get 'query_analysis/get_transcript_diff_exp_samples_for_dataset'

  get  'query_analysis/query_diff_exp_genes'
  post 'query_analysis/query_diff_exp_genes'
  
  get 'query_analysis/get_gene_diff_exp_samples_for_dataset'

  get  'query_analysis/query_transcript_isoforms'
  post 'query_analysis/query_transcript_isoforms'
  
  get 'query_analysis/get_transcript_isoforms_samples_for_dataset'

  get  'query_analysis/query_using_blastn'
  post 'query_analysis/query_using_blastn'

  get  'query_analysis/query_using_tblastn'
  post 'query_analysis/query_using_tblastn'
  
  get 'query_analysis/get_transcript_fasta'
  
  get 'query_analysis/get_gene_fastas'
  
  get 'query_analysis/get_if_dataset_has_go_terms'
  
  get 'query_analysis/get_blastn_gap_costs_for_match_and_mismatch_scores'
  
  get 'query_analysis/get_tblastn_gap_costs_for_matrix'
  
  get 'query_analysis/query_using_tblastx'
  post 'query_analysis/query_using_tblastx'


    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products

    # Sample resource route with options:
    #   resources :products do
    #     member do
    #       get 'short'
    #       post 'toggle'
    #     end
    #
    #     collection do
    #       get 'sold'
    #     end
    #   end

    # Sample resource route with sub-resources:
    #   resources :products do
    #     resources :comments, :sales
    #     resource :seller
    #   end

    # Sample resource route with more complex sub-resources
    #   resources :products do
    #     resources :comments
    #     resources :sales do
    #       get 'recent', :on => :collection
    #     end
    #   end

    # Sample resource route within a namespace:
    #   namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    #     resources :products
    #   end

    # You can have the root of your site routed with 'root'
    # just remember to delete public/index.html.
    # root :to => 'welcome#index'

    # See how all your routes lay out with 'rake routes'

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id))(.:format)'
end
