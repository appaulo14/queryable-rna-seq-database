require 'bio'
require 'query_analysis/upload_cuffdiff.rb'
require 'query_analysis/upload_fasta_sequences.rb'
require 'query_analysis/upload_trinity_with_edger.rb'
require 'query_analysis/find_go_terms_for_dataset.rb'
require 'query_analysis/query_diff_exp_transcripts.rb'
require 'query_analysis/query_transcript_isoforms.rb'
require 'query_analysis/query_diff_exp_genes.rb'
require 'query_analysis/get_gene_fastas.rb'
require 'query_analysis/get_transcript_fasta.rb'
require 'query_analysis/query_using_blastn.rb'
require 'query_analysis/query_using_tblastn.rb'
require 'query_analysis/query_using_tblastx.rb'

###
# Handles all actions related to querying the Postgresql database, blast 
# databases, uploading data for querying, and finding Gene Ontology (GO) 
# terms for uploaded data. 
class QueryAnalysisController < ApplicationController
    
    before_filter :authenticate_user!
    
    before_filter :confirm_datasets_available, 
      :only => [
        :query_diff_exp_transcripts, 
        :get_transcript_diff_exp_samples_for_dataset, 
        :query_diff_exp_genes, 
        :get_gene_diff_exp_samples_for_dataset,
        :query_transcript_isoforms, 
        :get_transcript_isoforms_samples_for_dataset,
        :get_transcript_fasta, :get_gene_fastas,
        :query_using_blastn, :query_using_tblastn, :query_using_tblastx,
        :get_blastn_gap_costs_for_match_and_mismatch_scores,
        :get_tblastn_gap_costs_for_matrix
      ]
    before_filter :confirm_transcript_isoform_datasets_available,
      :only => [
        :query_transcript_isoforms,
        :get_transcript_isoforms_samples_for_dataset
      ]
    before_filter :confirm_transcript_diff_exp_datasets_available, 
      :only => [
        :query_diff_exp_transcripts,
        :get_transcript_diff_exp_samples_for_dataset
      ]
    before_filter :confirm_gene_diff_exp_datasets_available, 
      :only => [
        :query_diff_exp_genes,
        :get_gene_diff_exp_samples_for_dataset
      ]
    before_filter :confirm_datasets_without_go_terms_available,
      :only => [:find_go_terms_for_dataset]
    
    ###  
    # Handles both GET and POST requests for the upload Cuffdiff page
    #
    # <b>Associated ViewModel:</b> UploadCuffdiff
    def upload_cuffdiff
      if request.get?
        @upload_cuffdiff = UploadCuffdiff.new(current_user)
        @upload_cuffdiff.set_attributes_and_defaults()
      elsif request.post?
        @upload_cuffdiff = UploadCuffdiff.new(current_user)
        @upload_cuffdiff.set_attributes_and_defaults(params[:upload_cuffdiff])
        if (@upload_cuffdiff.valid?)
          SuckerPunch::Queue[:upload_cuffdiff_queue].async.perform(@upload_cuffdiff)
          flash[:notice] = I18n.t :added_to_upload_queue, 
                                  :name => @upload_cuffdiff.dataset_name
          #Reset the upload cuffdiff form
          @upload_cuffdiff = UploadCuffdiff.new(current_user)
          @upload_cuffdiff.set_attributes_and_defaults()
        end
      end
    end
    
    ###
    # Handles both GET and POST requests for the upload fasta sequences page. 
    #
    # <b>Associated ViewModel:</b> UploadFastaSequences
    def upload_fasta_sequences
      if request.get?
        @upload = UploadFastaSequences.new(current_user)
        @upload.set_attributes_and_defaults()
      elsif request.post?
        @upload = UploadFastaSequences.new(current_user)
        @upload.set_attributes_and_defaults(params[:upload_fasta_sequences])
        if (@upload.valid?)
          SuckerPunch::Queue[:upload_fasta_sequences_queue].async.perform(@upload)
          flash[:notice] = I18n.t :added_to_upload_queue, 
                                   :name => @upload.dataset_name
          #Reset the upload cuffdiff form
          @upload = UploadFastaSequences.new(current_user)
          @upload.set_attributes_and_defaults()
        end
      end
    end
    
    ###
    # Handles both GET and POST requests for the upload Trinity with EdgeR 
    # page.
    #
    # <b>Associated ViewModel:</b> UploadTrinityWithEdgeR
    def upload_trinity_with_edger
      if (request.get?)
        @upload = UploadTrinityWithEdgeR.new(current_user)
        @upload.set_attributes_and_defaults()
      elsif (request.post?)
        @upload = UploadTrinityWithEdgeR.new(current_user)
        upload_params = params[:upload_trinity_with_edge_r]
        @upload.set_attributes_and_defaults(upload_params)
        if @upload.valid?
          queue_name = :upload_trinity_with_edger_queue
          SuckerPunch::Queue[queue_name].async.perform(@upload)
          flash[:notice] = I18n.t :added_to_upload_queue, 
                                   :name => @upload.dataset_name
          #Reset the upload form
          @upload = UploadTrinityWithEdgeR.new(current_user)
          @upload.set_attributes_and_defaults()
        end
      end
    end
    
    ###
    # For the upload Trinity with EdgeR page, ajax request to add html to the 
    # form to upload an additional transcript differential expression file.
    #
    # <b>Associated ViewModel:</b> None
    def add_sample_cmp_for_trinity_with_edger_transcripts
      render :partial => 'trinity_with_edger_transcripts_sample_cmp'
    end
    
    # For the upload Trinity with EdgeR page, ajax request to add html to the 
    # form to upload an additional gene differential expression file.
    #
    # <b>Associated ViewModel:</b> None
    def add_sample_cmp_for_trinity_with_edger_genes
      render :partial => 'trinity_with_edger_genes_sample_cmp'
    end
    
    ###
    # Handles both GET and POST requests for the find go terms for dataset page.
    #
    # <b>Associated ViewModel:</b> FindGoTermsForDataset
    def find_go_terms_for_dataset
      if request.get?
        @finder = FindGoTermsForDataset.new(current_user)
        @finder.set_attributes_and_defaults()
      elsif request.post?
        @finder = FindGoTermsForDataset.new(current_user)
        @finder.set_attributes_and_defaults(params[:find_go_terms_for_dataset])
        if @finder.valid?
          queue_name = :find_go_terms_for_dataset_queue
          SuckerPunch::Queue[queue_name].async.perform(@finder)
          #Make sure the dataset is set to in-progress before the page reloads
          @dataset = Dataset.find_by_id(@finder.dataset_id)
          @dataset.go_terms_status = 'in-progress'
          @dataset.save!
          #Make sure there are still datasets left to display
          if current_user.datasets.where(:go_terms_status => 'not-started').empty?
            @datasets_in_progress = 
                current_user.datasets.where(:go_terms_status => 'in-progress')
            render :no_datasets_without_go_terms
          else
            #Reset the form
            @finder = FindGoTermsForDataset.new(current_user)
            @finder.set_attributes_and_defaults()
          end
          flash[:notice] = I18n.t :added_to_go_terms_queue, :name => @dataset.name
        end
      end
    end
    
    ###
    # Handles both GET and POST requests for the query differentially expressed 
    # transcripts page.
    #
    # <b>Associated ViewModel:</b> QueryDiffExpTranscripts
    def query_diff_exp_transcripts
      #Create the view model, giving the current user
      @qdet = QueryDiffExpTranscripts.new(current_user)
      #Which type of request was received?
      if request.get?
        @qdet.set_attributes_and_defaults()
      elsif request.post?
        #Fill in the inputs from the view
        @qdet.set_attributes_and_defaults(params[:query_diff_exp_transcripts])
        # If valid, query and return results; otherwise return failure
        if @qdet.valid?
          if @qdet.results_display_method == 'email'
            SuckerPunch::Queue[:query_regular_db_queue].async.perform(@qdet)
            
            dataset = Dataset.find_by_id(@qdet.dataset_id)
            flash[:notice] = I18n.t(:added_to_query_regular_db_queue,
                                    :name => dataset.name)
            # Reset the form before rendering
            @qdet = QueryDiffExpTranscripts.new(current_user)
            @qdet.set_attributes_and_defaults()
          else
            @qdet.query()
          end
        end
      end
    end
    
    ###
    # When a new dataset is selected on the query differentially expressed 
    # transcripts page, handles ajax requests to get the sample comparisons
    # for the newly selected dataset.
    #
    # <b>Associated ViewModel:</b> QueryDiffExpTranscripts
    def get_transcript_diff_exp_samples_for_dataset
      @qdet = QueryDiffExpTranscripts.new(current_user)
      dataset_id = params[:dataset_id]
      @qdet.set_attributes_and_defaults({:dataset_id => dataset_id})
      if @qdet.valid?
        render :partial => 'diff_exp_samples_for_dataset', 
               :locals => {:object => @qdet}
      else
        render :no_datasets
      end
    end
    
    ###
    # Handles requests to display the fasta sequence for a given transcript.
    #
    # <b>Associated ViewModel:</b> GetTranscriptFasta
    def get_transcript_fasta
      #Create/fill in the view model
      get_transcript_fasta = GetTranscriptFasta.new(current_user)
      get_transcript_fasta.set_attributes(params)
      #Output based on whether the view model is valid
      if get_transcript_fasta.valid?
        
        render :text => get_transcript_fasta.query, 
               :content_type => 'text/plain'
      else
        error_messages_string = "Error(s) found:\n"
        get_transcript_fasta.errors.full_messages.each do |error_msg|
          error_messages_string += "#{error_msg}\n"
        end
        render :text => error_messages_string, 
               :content_type => 'text/plain'
      end
    end
    
    ###
    # Handles requests to display the fasta sequences for the transcripts 
    # associated with a given gene.
    #
    # <b>Associated ViewModel:</b> GetGeneFastas
    def get_gene_fastas
      #Create/fill in the view model
      get_gene_fastas = GetGeneFastas.new(current_user)
      get_gene_fastas.set_attributes(params)
      #Output based on whether the view model is valid
      if get_gene_fastas.valid?
        render :text => get_gene_fastas.query, 
               :content_type => 'text/plain'
      else
        error_messages_string = "Error(s) found:\n"
        get_gene_fastas.errors.full_messages.each do |error_msg|
          error_messages_string += "#{error_msg}\n"
        end
        render :text => error_messages_string, 
               :content_type => 'text/plain'
      end
    end
    
    ###
    # Handles ajax requests asking whether a dataset has go terms. Returns a 
    # boolean value or an error message.
    #
    # <b>Associated ViewModel:</b> None
    def get_if_dataset_has_go_terms
      dataset = Dataset.find_by_id(params[:dataset_id])
      if dataset.user != current_user
        msg = "not authorized"
      else
        if dataset.go_terms_status == 'found'
          msg = true
        else
          msg = false
        end
      end
      render :text => msg, 
             :content_type => 'text/plain'
    end
    
    ###
    # Handles both GET and POST requests for the query differentially expressed 
    # genes page.
    #
    # <b>Associated ViewModel:</b> QueryDiffExpGenes
    def query_diff_exp_genes
      #Create the view model, giving the current user
      @qdeg = QueryDiffExpGenes.new(current_user)
      #Which type of request was received?
      if request.get?
        @qdeg.set_attributes_and_defaults()
      elsif request.post?
        #Fill in the inputs from the view
        @qdeg.set_attributes_and_defaults(params[:query_diff_exp_genes])
        # If valid, query and return results; otherwise return failure
        if @qdeg.valid?
          if @qdeg.results_display_method == 'email'
            SuckerPunch::Queue[:query_regular_db_queue].async.perform(@qdeg)
            
            dataset = Dataset.find_by_id(@qdeg.dataset_id)
            flash[:notice] = I18n.t(:added_to_query_regular_db_queue,
                                    :name => dataset.name)
            # Reset the form before rendering
            @qdeg = QueryDiffExpGenes.new(current_user)
            @qdeg.set_attributes_and_defaults()
          else
            @qdeg.query()
          end
        end
      end
    end
    
     ###
    # When a new dataset is selected on the query differentially expressed page, 
    # handles ajax requests to get the sample comparisons for the newly 
    # selected dataset.
    #
    # <b>Associated ViewModel:</b> QueryDiffExpGenes
    def get_gene_diff_exp_samples_for_dataset
      @qdeg = QueryDiffExpGenes.new(current_user)
      dataset_id = params[:dataset_id]
      @qdeg.set_attributes_and_defaults({:dataset_id => dataset_id})
      if @qdeg.valid?
        render :partial => 'diff_exp_samples_for_dataset', 
               :locals => {:object => @qdeg}
      end
    end
    
    ###
    # Handles both GET and POST requests for the query transcript isoforms page.
    #
    # <b>Associated ViewModel:</b> QueryTranscriptIsoforms
    def query_transcript_isoforms
      #Create the view model, giving the current user
      @qti = QueryTranscriptIsoforms.new(current_user)
      #Which type of request was received?
      if request.get?
        @qti.set_attributes_and_defaults()
      elsif request.post?
        #Fill in the inputs from the view
        @qti.set_attributes_and_defaults(params[:query_transcript_isoforms])
        # If valid, query and return results; otherwise return failure
        if @qti.valid?
          if @qti.results_display_method == 'email'
            dataset = Dataset.find_by_id(@qti.dataset_id)
            SuckerPunch::Queue[:query_regular_db_queue].async.perform(@qti)
            flash[:notice] = I18n.t(:added_to_query_regular_db_queue,
                                    :name => dataset.name)
            # Reset the form before rendering
            @qti = QueryTranscriptIsoforms.new(current_user)
            @qti.set_attributes_and_defaults()
          else
            @qti.query()
          end
        end
      end
    end
    
    ###
    # When a new dataset is selected on the query transcript isoforms page, 
    # handles ajax requests to get the samples for the newly selected dataset.
    #
    # <b>Associated ViewModel:</b> QueryTranscriptIsoforms
    def get_transcript_isoforms_samples_for_dataset
      @qti = QueryTranscriptIsoforms.new(current_user)
      dataset_id = params[:dataset_id]
      @qti.set_attributes_and_defaults(:dataset_id => dataset_id)
      if @qti.valid?
        render :partial => 'transcript_isoforms_samples_for_dataset', 
               :locals => {:object => @qti}
      end
    end
    
    ###
    # Handles both GET and POST requests for the query using blastn page.
    #
    # <b>Associated ViewModel:</b> QueryUsingBlastn
    def query_using_blastn    #Changed after architecture design
      @sequence_type = 'nucleic acid'
      if request.get?
          @query_using_blastn = QueryUsingBlastn.new(current_user)
          @query_using_blastn.set_attributes_and_defaults()
      elsif request.post?
        @query_using_blastn = QueryUsingBlastn.new(current_user)
        @query_using_blastn.set_attributes_and_defaults(params[:query_using_blastn])
        if @query_using_blastn.valid?
            @dataset = Dataset.find_by_id(@query_using_blastn.dataset_id)
            if @query_using_blastn.results_display_method == 'email'
              q_name = :query_using_blast_queue
              SuckerPunch::Queue[q_name].async.perform(@query_using_blastn)
              flash[:notice] = I18n.t(:added_to_query_using_blast_queue,
                                      :name => @dataset.name)
              # Reset the form before rendering
              @query_using_blastn = QueryUsingBlastn.new(current_user)
              @query_using_blastn.set_attributes_and_defaults(params[:query_using_blastn])
            else
              #Run the blast query and get the file path of the result
              @blast_report = @query_using_blastn.blast()
              #Send the result to the user
              render :file => 'query_analysis/blast_results'
            end
        end
      end
    end
    
    ###
    # When a new set of match/mismatch scores is selected on the query using 
    # blastn page, handles ajax requests to get the gap costs for the newly 
    # selected match/mismatch scores.
    #
    # <b>Associated ViewModel:</b> QueryUsingBlastn
    def get_blastn_gap_costs_for_match_and_mismatch_scores
      #Calculate the new gap costs from the match and mismatch scores 
      @query_using_blastn = QueryUsingBlastn.new(current_user)
      match_and_mismatch_scores = params[:match_and_mismatch_scores]
      @query_using_blastn.set_attributes_and_defaults(
        :match_and_mismatch_scores => match_and_mismatch_scores
      )
      #Render the new gap costs
      render :partial => 'gap_costs', :locals => {:object => @query_using_blastn}
    end
    
    ###
    # Handles both GET and POST requests for the query using tblastn page.
    #
    # <b>Associated ViewModel:</b> QueryUsingTblastn
    def query_using_tblastn
      @sequence_type = 'amino acid'
      if request.get?
        @query_using_tblastn = QueryUsingTblastn.new(current_user)
        @query_using_tblastn.set_attributes_and_defaults()
      elsif request.post?
        @query_using_tblastn = QueryUsingTblastn.new(current_user)
        @query_using_tblastn.set_attributes_and_defaults(params[:query_using_tblastn])
        if @query_using_tblastn.valid?
          @dataset = Dataset.find_by_id(@query_using_tblastn.dataset_id)
          if @query_using_tblastn.results_display_method == 'email'
            q_name = :query_using_blast_queue
            SuckerPunch::Queue[q_name].async.perform(@query_using_tblastn)
            flash[:notice] = I18n.t(:added_to_query_using_blast_queue,
                                    :name => @dataset.name)
            # Reset the form before rendering
            @query_using_tblastn = QueryUsingTblastn.new(current_user)
            @query_using_tblastn.set_attributes_and_defaults(params[:query_using_tblastn])
          else
            #Run the blast query and get the file path of the result
            @blast_report = @query_using_tblastn.blast()
            #Send the result to the user
            render :file => 'query_analysis/blast_results'
          end
        end
      end
    end
    
    ###
    # When a new matrix is selected on the query using Tblastn page, 
    # handles ajax requests to get the gap costs for the newly selected matrix.
    #
    # <b>Associated ViewModel:</b> QueryUsingTblastn
    def get_tblastn_gap_costs_for_matrix
      #Calculate the new gap costs from the match and mismatch scores 
      @query_using_tblastn = QueryUsingTblastn.new(current_user)
      matrix = params[:matrix]
      @query_using_tblastn.set_attributes_and_defaults(:matrix => matrix)
      #Render the new gap costs
      render :partial => 'gap_costs', :locals => {:object => @query_using_tblastn}
    end
  
  ###
  # Handles both GET and POST requests for the query using Tblastx page.
  #
  # <b>Associated ViewModel:</b> QueryUsingTblastx
  def query_using_tblastx
    @sequence_type = 'nucleic acid'
    if request.get?
      @query_using_tblastx = QueryUsingTblastx.new(current_user)
      @query_using_tblastx.set_attributes_and_defaults()
    elsif request.post?
      @query_using_tblastx = QueryUsingTblastx.new(current_user)
      @query_using_tblastx.set_attributes_and_defaults(params[:query_using_tblastx])
      if @query_using_tblastx.valid?
        @dataset = Dataset.find_by_id(@query_using_tblastx.dataset_id)
        if @query_using_tblastx.results_display_method == 'email'
          q_name = :query_using_blast_queue
          SuckerPunch::Queue[q_name].async.perform(@query_using_tblastx)
          flash[:notice] = I18n.t(:added_to_query_using_blast_queue,
                                  :name => @dataset.name)
          # Reset the form before rendering
          @query_using_tblastx = QueryUsingTblastx.new(current_user)
          @query_using_tblastx.set_attributes_and_defaults(params[:query_using_tblastx])
        else
          #Run the blast query and get the file path of the result
          @blast_report = @query_using_tblastx.blast()
          #Send the result to the user
          render :file => 'query_analysis/blast_results'
        end
      end
    end
  end
  
  private 
  
  def confirm_datasets_available
    if current_user.datasets.where(:finished_uploading => true).empty?
      render :no_datasets
    end
  end
  
  def confirm_transcript_isoform_datasets_available
    if current_user.datasets.where(:has_transcript_isoforms => true, 
                                   :finished_uploading => true).empty?
      render :no_transcript_isoforms
    end
  end
  
  def confirm_transcript_diff_exp_datasets_available
    if current_user.datasets.where(:has_transcript_diff_exp => true, 
                                   :finished_uploading => true).empty?
      render :no_diff_exp_transcripts
    end
  end
  
  def confirm_gene_diff_exp_datasets_available
    if current_user.datasets.where(:has_gene_diff_exp => true, 
                                   :finished_uploading => true).empty?
      render :no_diff_exp_genes
    end
  end
  
  def confirm_datasets_without_go_terms_available
    if current_user.datasets.where(:go_terms_status => 'not-started', 
                                   :finished_uploading => true).empty?
      @datasets_in_progress = 
          current_user.datasets.where(:go_terms_status => 'in-progress', 
                                      :finished_uploading => true)
      render :no_datasets_without_go_terms
    end
  end
end
