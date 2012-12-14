class QueryAnalysisController < ApplicationController
    include Blast_Query
    require 'query_analysis/upload_trinity_with_edger_transcripts_and_genes.rb'
    require 'query_analysis/query_diff_exp_transcripts.rb'
    
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
      @name = params[:name]
      @goats = ['tom','dick','harry'] if @goats.nil?
      if (request.post?)
        @goats << params[:add_goat]
      end
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
      render :text => "Good morning!\n"*10_000, :content_type => 'text/plain'
    end
    
    def get_transcript_fastas
      #Get the parameters
      dataset_id = params[:dataset_id]
      transcript_names = params[:transcript_names].split(',')
      #TODO: Validate user
      #TODO: MAYBE create version for genes
      #TODO: MAYBE make this singular?
      #Get the transcripts from the parameters
      transcripts = Transcript.where(:dataset_id => dataset_id, 
                                     :name_from_program => transcript_names)
      #Create the fasta string
      fastas_string = ''
      transcripts.each do |t|
        fastas_string += ">#{t.fasta_description}\n#{t.fasta_sequence}\n"
      end
      #Render to the user
      if fastas_string.blank?
        render :text => 'No transcripts found', :content_type => 'text/plain'
      else
        render :text => fastas_string, :content_type => 'text/plain'
      end
    end

    def query_diff_exp_genes
    end

    def query_transcript_isoforms
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
            @blastn_query = Blast_Query::Blastn_Query.new()
        elsif request.post?
            @blastn_query = Blast_Query::Blastn_Query.new(params[:blastn_query])
            debugger if ENV['RAILS_DEBUG'] == "true"
            if @blastn_query.valid?
                flash[:success] = "Success"
            else
                flash[:success]="Failure"
            end
        end
    end

    def tblastn
        if request.get?
            @tblastn_query = Blast_Query::Tblastn_Query.new()
        elsif request.post?
            @tblastn_query = Blast_Query::Tblastn_Query.new(params[:tblastn_query])
            debugger if ENV['RAILS_DEBUG'] == "true"
            if @tblastn_query.valid?
                flash[:success] = "Success"
            else
                flash[:success]="Failure"
            end
        end
    end
end
