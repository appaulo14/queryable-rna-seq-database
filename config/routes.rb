RnaSeqAnalysisPipeline::Application.routes.draw do
  ###########################################################################
  ##########          Configure routes for home controller     ###############
  ###########################################################################
  get 'admin/view_user_information'

  get 'admin/add_new_user_to_system'

  get 'admin/delete_datasets_from_database'
  
  get 'admin/view_unconfirmed_users'
  
  get  'admin/confirm_user'
  post 'admin/confirm_user'
  
  get  'admin/delete_unconfirmed_user'
  post 'admin/delete_unconfirmed_user'
  
  get 'admin/welcome'
  
  match 'admin', :to => 'admin#welcome'

  devise_for :users, :controllers => {:registrations => 'registrations'}#{ :sessions => "user" }
      #:controllers => { :sessions => "devise/sessions" }

  ###########################################################################
  ##########          Configure routes for home controller     ###############
  ###########################################################################
  #Set the root page
  root :to => 'home#welcome'
  
  match 'home', :to => 'home#welcome'
  get 'home/welcome'

  ###########################################################################
  ##########     Configure routes for query analysis controller   ###########
  ###########################################################################
  match 'query_analysis', :to => 'query_analysis#welcome'
  get  'query_analysis/welcome'

  get  'query_analysis/upload_main_menu'

  get 'query_analysis/upload_cuffdiff'

  get 'query_analysis/upload_trinity_with_edger_transcripts_and_genes'
  post 'query_analysis/upload_trinity_with_edger_transcripts_and_genes'
  
  get 'query_analysis/upload_trinity_with_edger_transcripts'
  post 'query_analysis/upload_trinity_with_edger_transcripts'

  get 'query_analysis/diff_exp_main_menu'
  
  get 'query_analysis/query_diff_exp_transcripts'
  post 'query_analysis/query_diff_exp_transcripts'

  get  'query_analysis/query_diff_exp_genes'
  post 'query_analysis/query_diff_exp_genes'

  get  'query_analysis/query_transcript_isoforms'
  post 'query_analysis/query_transcript_isoforms'
  
  get 'query_analysis/blast_main_menu'

  get  'query_analysis/blastn'
  post 'query_analysis/blastn'

  get  'query_analysis/tblastn'
  post 'query_analysis/tblastn'
  
  get 'query_analysis/get_transcript_fasta'
  
  get 'query_analysis/get_gene_fastas'
  
  get 'query_analysis/get_blastn_gap_costs_for_match_and_mismatch_scores'
  
  get 'query_analysis/get_tblastn_gap_costs_for_matrix'
  
  get 'query_analysis/tblastx'
  post 'query_analysis/tblastx'

#     SequenceServer::App.init
#     #match '/sequenceserver' => SequenceServer::App, :anchor => false
#     #match '/sequenceserver(/*other_params)' => SequenceServer::App, :anchor => false
#     mount SequenceServer::App => 'sequenceserver'
#     #ApiApp.init
#     mount ApiApp => 'api'
#     #   SequenceServer::App.routes do
    #     get 'get_sequence'# => 'sequenceserver/get_sequence'
    #     get 'sequenceserver/get_sequence'
    #     get '/sequenceserver/get_sequence'
    #     match 'get_sequence', :to => SequenceServer::App
    #     match '/sequenceserver/get_sequence', :to => SequenceServer::App
    #     match 'sequenceserver/get_sequence', :to => SequenceServer::App
    #     match 'get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #     match '/get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #     match '/sequenceserver/get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #     match 'sequenceserver/get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #   end
    #   match 'get_sequence', :to => SequenceServer::App
    #   match '/sequenceserver/get_sequence', :to => SequenceServer::App
    #   match 'sequenceserver/get_sequence', :to => SequenceServer::App
    #   match 'get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #   match '/get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #   match '/sequenceserver/get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}
    #   match 'sequenceserver/get_sequence', :to => 'get_sequence', :constraints => {:subdomain => 'sequenceserver'}

    # class HomeApp < Sinatra::Base
    #     get '/' do
    #     'Hello World!'
    #     end
    # end

    # Basecamp::Application.routes do
    #   match '/home', :to => HomeApp
    # end


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
