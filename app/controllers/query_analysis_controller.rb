require 'bio'
require 'query_analysis/upload_cuffdiff.rb'
require 'query_analysis/upload_fasta_sequences.rb'
require 'query_analysis/upload_trinity_with_edger.rb'
require 'query_analysis/upload_trinity_with_edger_transcripts_and_genes.rb'
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
        :query_diff_exp_transcripts, :query_diff_exp_genes, 
        :query_transcript_isoforms, 
        :query_using_blastn, :query_using_tblastn, :query_using_tblastx
      ]
    before_filter :confirm_transcript_isoform_datasets_available,
      :only => [:query_transcript_isoforms]
    before_filter :confirm_transcript_diff_exp_datasets_available, 
      :only => [:query_diff_exp_transcripts]
    before_filter :confirm_gene_diff_exp_datasets_available, 
      :only => [:query_diff_exp_genes]
    
   
    def upload_main_menu
    end

    def welcome
    end
    
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
      @sample_cmp_count = params[:sample_cmp_count]
      render :partial => 'trinity_with_edger_transcripts_sample_cmp', 
             :locals  => {:object => @sample_cmp_count}
    end
    
    def add_sample_cmp_for_trinity_with_edger_genes
      @sample_cmp_count = params[:sample_cmp_count]
      render :partial => 'trinity_with_edger_genes_sample_cmp', 
             :locals  => {:object => @sample_cmp_count}
    end
    
    def upload_trinity_with_edger_transcripts
      if (request.get?)
        @upload_files = UploadTrinityWithEdgeRTranscripts.new(current_user)
        @upload_files.set_attributes_and_defaults()
      elsif (request.post?)
        @upload_files = UploadTrinityWithEdgeRTranscripts.new(current_user)
        @upload_files.set_attributes_and_defaults(params[:upload_trinity_with_edger_transcripts])
        @upload_files.save!
      end
    end
    
    def upload_trinity_with_edger_transcripts_and_genes
      if (request.get?)
        @upload_files = UploadTrinityWithEdgeRTranscriptsAndGenes.new(current_user)
        @upload_files.set_attributes_and_defaults()
      elsif (request.post?)
        @upload_files = UploadTrinityWithEdgeRTranscriptsAndGenes.new(current_user)
        upload_params = params[:upload_trinity_with_edge_r_transcripts_and_genes]
        @upload_files.set_attributes_and_defaults(upload_params)
        if @upload_files.valid?
          queue_name = :upload_trinity_with_edger_transcripts_and_genes_queue
          SuckerPunch::Queue[queue_name].async.perform(@upload_files)
          #Reset the upload form
          @upload_files = UploadTrinityWithEdgeRTranscriptsAndGenes.new(current_user)
          @upload_files.set_attributes_and_defaults()
          flash[:notice] = I18n.t :added_to_upload_queue
        end
      end
    end
    
    def add_sample_cmp_for_trinity_with_edger_transcripts_and_genes
      @sample_cmp_count = params[:sample_cmp_count]
      render :partial => 'trinity_with_edger_transcript_and_gene_sample_cmp', 
             :locals  => {:object => @sample_cmp_count}
    end
    
    def query_diff_exp_transcripts
      #Create the view model, giving the current user
      @qdet = QueryDiffExpTranscripts.new(current_user)
      #Which type of request was received?
      if request.get?
        #If the dataset_id parameter makes the view model invalid, 
        #    don't use the dataset_id parameter
        @qdet.set_attributes_and_defaults(:dataset_id => params[:dataset_id])
        if not @qdet.valid?
          @qdet.set_attributes_and_defaults(:dataset_id => nil)
        end
      elsif request.post?
        #Fill in the inputs from the view
        @qdet.set_attributes_and_defaults(params[:query_diff_exp_transcripts])
        # If valid, query and return results; otherwise return failure
        if @qdet.valid?
          @qdet.query()
          flash[:success] = "Success"
        else
          flash[:success] = "Failure"
        end
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
        #If the dataset_id parameter makes the view model invalid, 
        #    ignore the dataset_id parameter
        @qdeg.set_attributes_and_defaults(:dataset_id => params[:dataset_id])
        if not @qdeg.valid?
          @qdeg.set_attributes_and_defaults(:dataset_id => nil)
        end
      elsif request.post?
        #Fill in the inputs from the view
        @qdeg.set_attributes_and_defaults(params[:query_diff_exp_genes])
        # If valid, query and return results; otherwise return failure
        if @qdeg.valid?
          @qdeg.query()
        end
      end
    end

    def query_transcript_isoforms
      #Create the view model, giving the current user
      @qti = QueryTranscriptIsoforms.new(current_user)
      #Which type of request was received?
      if request.get?
        #If the dataset_id parameter makes the view model invalid, 
        #    don't use the dataset_id parameter
        @qti.set_attributes_and_defaults(:dataset_id => params[:dataset_id])
        if not @qti.valid?
          @qti.set_attributes_and_defaults(:dataset_id => nil)
        end
      elsif request.post?
        #Fill in the inputs from the view
        @qti.set_attributes_and_defaults(params[:query_transcript_isoforms])
        # If valid, query and return results; otherwise return failure
        if @qti.valid?
          @qti.query()
        end
      end
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
    if current_user.datasets.empty?
      render :no_datasets
    end
  end
  
  def confirm_transcript_isoform_datasets_available
    if current_user.datasets.where(:has_transcript_isoforms => true).empty?
      render :no_transcript_isoforms
    end
  end
  
  def confirm_transcript_diff_exp_datasets_available
    if current_user.datasets.where(:has_transcript_diff_exp => true).empty?
      render :no_diff_exp_transcripts
    end
  end
  
  def confirm_gene_diff_exp_datasets_available
    if current_user.datasets.where(:has_gene_diff_exp => true).empty?
      render :no_diff_exp_genes
    end
  end
end
