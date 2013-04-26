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
      
    
    def upload_cuffdiff
      if request.get?
        @upload_cuffdiff = UploadCuffdiff.new(current_user)
        @upload_cuffdiff.set_attributes_and_defaults()
      elsif request.post?
        @upload_cuffdiff = UploadCuffdiff.new(current_user)
        @upload_cuffdiff.set_attributes_and_defaults(params[:upload_cuffdiff])
        if (@upload_cuffdiff.valid?)
          SuckerPunch::Queue[:upload_cuffdiff_queue].async.perform(@upload_cuffdiff)
          #Reset the upload cuffdiff form
          @upload_cuffdiff = UploadCuffdiff.new(current_user)
          @upload_cuffdiff.set_attributes_and_defaults()
          flash[:notice] = I18n.t :added_to_upload_queue
        end
      end
    end
    
    def upload_fasta_sequences
      if request.get?
        @upload = UploadFastaSequences.new(current_user)
        @upload.set_attributes_and_defaults()
      elsif request.post?
        @upload = UploadFastaSequences.new(current_user)
        @upload.set_attributes_and_defaults(params[:upload_fasta_sequences])
        if (@upload.valid?)
          SuckerPunch::Queue[:upload_fasta_sequences_queue].async.perform(@upload)
          #Reset the upload cuffdiff form
          @upload = UploadFastaSequences.new(current_user)
          @upload.set_attributes_and_defaults()
          flash[:notice] = I18n.t :added_to_upload_queue
        end
      end
    end
    
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
          #Reset the upload form
          @upload = UploadTrinityWithEdgeR.new(current_user)
          @upload.set_attributes_and_defaults()
          flash[:notice] = I18n.t :added_to_upload_queue
        end
      end
    end
    
    def add_sample_cmp_for_trinity_with_edger_transcripts
      render :partial => 'trinity_with_edger_transcripts_sample_cmp'
    end
    
    def add_sample_cmp_for_trinity_with_edger_genes
      render :partial => 'trinity_with_edger_genes_sample_cmp'
    end
    
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
        @qdet.query() if @qdet.valid?
      end
    end
    
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
        @qdeg.query() if @qdeg.valid?
      end
    end
    
    def get_gene_diff_exp_samples_for_dataset
      @qdeg = QueryDiffExpGenes.new(current_user)
      dataset_id = params[:dataset_id]
      @qdeg.set_attributes_and_defaults({:dataset_id => dataset_id})
      if @qdeg.valid?
        render :partial => 'diff_exp_samples_for_dataset', 
               :locals => {:object => @qdeg}
      end
    end

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
        @qti.query() if @qti.valid?
        render :partial => 'query_transcript_isoform_table_rows', 
               :locals => {:object => @qti}
      end
    end
    
    def get_transcript_isoforms_samples_for_dataset
      @qti = QueryTranscriptIsoforms.new(current_user)
      dataset_id = params[:dataset_id]
      @qti.set_attributes_and_defaults(:dataset_id => dataset_id)
      if @qti.valid?
        render :partial => 'transcript_isoforms_samples_for_dataset', 
               :locals => {:object => @qti}
      end
    end
    
    def get_query_transcript_isoforms_piece
      @qti = QueryTranscriptIsoforms.new(current_user)
      #debugger
      @qti.set_attributes_and_defaults(params[:query_transcript_isoforms])
      @qti.query()
      render :partial => 'query_transcript_isoform_table_rows', 
             :locals => {:object => @qti}
#       if @qti.valid?
#         render :partial => 'transcript_isoforms_samples_for_dataset', 
#                :locals => {:object => @qti}
#       end
    end
    
    def query_using_blastn    #Changed after architecture design
      @sequence_type = 'nucleic acid'
      if request.get?
          @query_using_blastn = QueryUsingBlastn.new(current_user)
          @query_using_blastn.set_attributes_and_defaults()
      elsif request.post?
        @query_using_blastn = QueryUsingBlastn.new(current_user)
        @query_using_blastn.set_attributes_and_defaults(params[:query_using_blastn])
        if @query_using_blastn.valid?
            @program = :blastn
            @blast_report = @query_using_blastn.blast
            #Send the result to the user
            @dataset = Dataset.find_by_id(@query_using_blastn.dataset_id)
            render :file => 'query_analysis/blast_results'
        end
      end
    end
    
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

    def query_using_tblastn #changed after the architecture design
      @sequence_type = 'amino acid'
      if request.get?
        @query_using_tblastn = QueryUsingTblastn.new(current_user)
        @query_using_tblastn.set_attributes_and_defaults()
      elsif request.post?
        @query_using_tblastn = QueryUsingTblastn.new(current_user)
        @query_using_tblastn.set_attributes_and_defaults(params[:query_using_tblastn])
        if @query_using_tblastn.valid?
          @program = :tblastn
          #Run the blast query and get the file path of the result
          @blast_report = @query_using_tblastn.blast()
          #Send the result to the user
          @dataset = Dataset.find_by_id(@query_using_tblastn.dataset_id)
          render :file => 'query_analysis/blast_results'
        end
      end
    end
    
    def get_tblastn_gap_costs_for_matrix
      #Calculate the new gap costs from the match and mismatch scores 
      @query_using_blastn = QueryUsingTblastn.new(current_user)
      matrix = params[:matrix]
      @query_using_blastn.set_attributes_and_defaults(:matrix => matrix)
      #Render the new gap costs
      render :partial => 'gap_costs', :locals => {:object => @query_using_blastn}
    end
    
  def query_using_tblastx  #changed after the architecture design
    @sequence_type = 'nucleic acid'
    if request.get?
      @query_using_tblastx = QueryUsingTblastx.new(current_user)
      @query_using_tblastx.set_attributes_and_defaults()
    elsif request.post?
      @query_using_tblastx = QueryUsingTblastx.new(current_user)
      @query_using_tblastx.set_attributes_and_defaults(params[:query_using_tblastx])
      if @query_using_tblastx.valid?
        @program = :tblastx
        #Run the blast query and get the file path of the result
        @blast_report = @query_using_tblastx.blast()
        #Send the result to the user
        @dataset = Dataset.find_by_id(@query_using_tblastx.dataset_id)
        render :file => 'query_analysis/blast_results'
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
