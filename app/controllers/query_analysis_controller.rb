class QueryAnalysisController < ApplicationController
    include Blast_Query
    require 'query_analysis/upload_trinity_with_edger_transcripts_and_genes.rb'
    require 'query_analysis/query_diff_exp_transcripts.rb'
    require 'query_analysis/query_transcript_isoforms.rb'
    require 'query_analysis/query_diff_exp_genes.rb'
    require 'query_analysis/get_gene_fastas.rb'
    require 'query_analysis/get_transcript_fasta.rb'
    require 'query_analysis/blastn_query.rb'
    require 'query_analysis/tblastn_query.rb'
    
    before_filter :authenticate_user!

    def upload_main_menu
        debugger if ENV['RAILS_DEBUG'] == "true"
        if request.post? and not params[:type_of_files].nil?
            #Would redirecting like this be a security issue because it uses browser response data?
            redirect_to :action => params[:type_of_files]
        end
    end

    def welcome
    end

    def upload_reference_cuffdiff
    end

    def upload_de_novo_cuffdiff
    end
    
    def ajax_test
#       @name = params[:name]
#       @goats = ['tom','dick','harry'] if @goats.nil?
#       if (request.post?)
#         @goats << params[:add_goat]
#       end
      render :json => Blastn_Query.new(current_user)
      #render :text => open('/media/sf_MSE_Project/Workshop_Of_Paul/BLAST/outputs/Query_1.png', "rb").read
    end
    
    def upload_trinity_with_edger_genes_and_transcripts
      if (request.get?)
          @upload_files = Upload_Trinity_With_EdgeR_Transcripts_And_Genes.new()
        elsif (request.post?)
#           debugger if ENV['RAILS_DEBUG'] == 'true'
#           @upload_edgeR = Upload_EdgeR.new(params[:upload_edge_r])
#           if @upload_edgeR.valid?
#              @upload_edgeR.save!
#              flash[:success] = "Success"
#           else
#               flash[:success]="Failure"
#           end
        end
    end

    def upload_edgeR
        if (request.get?)
          @upload_edgeR = Upload_EdgeR.new
        elsif (request.post?)
          debugger if ENV['RAILS_DEBUG'] == 'true'
          @upload_edgeR = Upload_EdgeR.new(params[:upload_edge_r])
          if @upload_edgeR.valid?
             @upload_edgeR.save!
             flash[:success] = "Success"
          else
              flash[:success]="Failure"
          end
#           params.keys.each do |key|
#               if params[key].kind_of? ActionDispatch::Http::UploadedFile
#                   uploaded_file = params[key].tempfile
#                   #file_to_write = Rails.root.join('tmp/file_uploads', uploaded_file.original_filename)
#                   #File.open(file_to_write, 'wb') do |file|
#                   #file.write(uploaded_file.read)
#                   #TODO: Be sure to delete these files when finished
#                   #end
#               end
#           end
        end
    end

    def query_diff_exp_transcripts
      #Create the view model, giving the current user
      @qdet = Query_Diff_Exp_Transcripts.new(current_user)
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
          @qdet.query!()
          flash[:success] = "Success"
        else
          flash[:success]="Failure"
        end
      end
    end
    
    def get_diff_exp_transcripts_file
#       text = ''
#       100_000.times do |n|
#         text += "Good morning!\n"
#       end
#       render :text => text, :content_type => 'text/plain'
      render :file => '/media/sf_MSE_Project/Workshop_Of_Paul/BLAST/outputs/searchio.html'
    end
    
    def get_transcript_fasta
      #Create/fill in the view model
      get_transcript_fasta = Get_Transcript_Fasta.new(current_user)
      get_transcript_fasta.set_attributes(params)
      #Output based on whether the view model is valid
      if get_transcript_fasta.valid?
        get_transcript_fasta.query!
        render :text => get_transcript_fasta.fasta_string, 
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
      get_gene_fastas = Get_Gene_Fastas.new(current_user)
      get_gene_fastas.set_attributes(params)
      #Output based on whether the view model is valid
      if get_gene_fastas.valid?
        get_gene_fastas.query!
        render :text => get_gene_fastas.fastas_string, 
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
      @qdeg = Query_Diff_Exp_Genes.new(current_user)
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
          @qdeg.query!()
          flash[:success] = "Success"
        else
          flash[:success]="Failure"
        end
      end
    end

    def query_transcript_isoforms
      #Create the view model, giving the current user
      @qti = Query_Transcript_Isoforms.new(current_user)
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
          @qti.query!()
          flash[:success] = "Success"
        else
          flash[:success]="Failure"
        end
      end
    end

    def query_gene_isoforms
    end

    def query_blast_db
    end

    def query_blast_db_2
        debugger if ENV['RAILS_DEBUG'] == "true"
        if request.get?
            @blast_query = Blast_Query::Base.new()
        elsif request.post?
            @blast_query = Blast_Query::Base.new(params[:blast_query])
            debugger if ENV['RAILS_DEBUG'] == "true"
            if @blast_query.valid?
                flash[:success] = "Success"
            else
                flash[:success]="Failure"
            end
        end
    end

    def blastn
        if request.get?
            @blastn_query = Blastn_Query.new(current_user)
            @blastn_query.set_attributes_and_defaults()
        elsif request.post?
          @blastn_query = Blastn_Query.new(current_user)
          @blastn_query.set_attributes_and_defaults(params[:blastn_query])
          debugger if ENV['RAILS_DEBUG'] == "true"
          if @blastn_query.valid?
              flash[:success] = "Success"
              #Run the blast query and get the file path of the result
              blast_results_file_path = @blastn_query.blast!
              #Send the result to the user
              render :file => blast_results_file_path
              #Delete the result file since it is no longer needed
              File.delete(blast_results_file_path)
          else
              flash[:success]="Failure"
          end
        end
    end
    
    def get_blastn_gap_costs_for_match_and_match_scores
      #Calculate the new gap costs from the match and mismatch scores 
      @blastn_query = Blastn_Query.new(current_user)
      match_and_mismatch_scores = params[:match_and_mismatch_scores]
      @blastn_query.set_attributes_and_defaults(
        :match_and_mismatch_scores => match_and_mismatch_scores
      )
      #Render the new gap costs
      render :partial => 'gap_costs', :locals => {:object => @blastn_query}
    end
    
    def get_blast_graphical_summary
      #Get the parameters
      basename = params[:basename]
      graphical_summary_name = params[:graphical_summary_name]
      #Retrieve the graphical summary record using the basename
      bgsl = BlastGraphicalSummaryLocator.find_by_basename(basename)
      #Validate that the user has permission to access this graphical summary
      dataset = Dataset.find_by_id(bgsl.dataset_id)
      return if dataset.user_id != current_user.id
      #Get the path of the graphical summary
      graphical_summary_file_path = 
        "#{bgsl.html_output_file_path}_#{graphical_summary_name}.png"
      render :text => open(graphical_summary_file_path, "rb").read
      #Delete the graphical summary file
      File.delete(graphical_summary_file_path)
      #Delete the database record if no other image files are 
      # left to be retreived
      if Dir.glob("#{bgsl.html_output_file_path}_*").empty?
        bgsl.delete()
      end
    end

    def tblastn
        if request.get?
            @tblastn_query = Tblastn_Query.new(current_user)
            @tblastn_query.set_attributes_and_defaults()
        elsif request.post?
            @tblastn_query = Tblastn_Query.new(current_user)
            @tblastn_query.set_attributes_and_defaults(params[:tblastn_query])
            debugger if ENV['RAILS_DEBUG'] == "true"
            if @tblastn_query.valid?
              flash[:success] = "Success"
              #Run the blast query and get the file path of the result
              blast_results_file_path = @tblastn_query.blast!
              #Send the result to the user
              render :file => blast_results_file_path
              #Delete the result file since it is no longer needed
              File.delete(blast_results_file_path)
            else
                flash[:success]="Failure"
            end
        end
    end
    
    def get_tblastn_gap_costs_for_matrix
      #Calculate the new gap costs from the match and mismatch scores 
      @tblastn_query = Tblastn_Query.new(current_user)
      matrix = params[:matrix]
      @tblastn_query.set_attributes_and_defaults(:matrix => matrix)
      #Render the new gap costs
      render :partial => 'gap_costs', :locals => {:object => @tblastn_query}
    end
end
