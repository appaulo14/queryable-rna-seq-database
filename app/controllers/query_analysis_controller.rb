class QueryAnalysisController < ApplicationController
    require 'bio'
    require 'query_analysis/upload_cuffdiff.rb'
    require 'query_analysis/upload_trinity_with_edger_transcripts_and_genes.rb'
    require 'query_analysis/query_diff_exp_transcripts.rb'
    require 'query_analysis/query_transcript_isoforms.rb'
    require 'query_analysis/query_diff_exp_genes.rb'
    require 'query_analysis/get_gene_fastas.rb'
    require 'query_analysis/get_transcript_fasta.rb'
    require 'query_analysis/query_using_blastn.rb'
    require 'query_analysis/query_using_tblastn.rb'
    require 'query_analysis/query_using_tblastx.rb'
    
    before_filter :authenticate_user!

    def upload_main_menu
    end

    def welcome
      #flash[:notice] = "Success"
    end

#     def upload_reference_cuffdiff
#     end
# 
#     def upload_de_novo_cuffdiff
#     end
    
#     def ajax_test
# #       @name = params[:name]
# #       @goats = ['tom','dick','harry'] if @goats.nil?
# #       if (request.post?)
# #         @goats << params[:add_goat]
# #       end
#       render :json => QueryUsingBlastn.new(current_user)
#       #render :text => open('/media/sf_MSE_Project/Workshop_Of_Paul/BLAST/outputs/Query_1.png', "rb").read
#     end
    
    def upload_cuffdiff
      if request.get?
        @upload_cuffdiff = UploadCuffdiff.new(current_user)
        @upload_cuffdiff.set_attributes_and_defaults()
      elsif request.post?
        redirect_to('/')
        @upload_cuffdiff = UploadCuffdiff.new(current_user)
        @upload_cuffdiff.set_attributes_and_defaults(params[:upload_cuffdiff])
        if (@upload_cuffdiff.valid?)
          SuckerPunch::Queue[:upload_cuffdiff_queue].async.perform(@upload_cuffdiff)
          #@upload_cuffdiff.save!
        else
          flash[:alert] = 'Validation failed'
        end
      end
    end
    
    def upload_trinity_with_edger_transcripts
      if (request.get?)
        @upload_files = Upload_Trinity_With_EdgeR_Transcripts.new(current_user)
        @upload_files.set_attributes_and_defaults({})
      elsif (request.post?)
        debugger
        @upload_files = Upload_Trinity_With_EdgeR_Transcripts.new(current_user)
        @upload_files.set_attributes_and_defaults(params[:upload_trinity_with_edger_transcripts])
        @upload_files.save!
      end
    end
    
    def upload_trinity_with_edger_transcripts_and_genes
      if (request.get?)
        @upload_files = Upload_Trinity_With_EdgeR_Transcripts_And_Genes.new(current_user)
        @upload_files.set_attributes_and_defaults({})
      elsif (request.post?)
        debugger
        @upload_files = Upload_Trinity_With_EdgeR_Transcripts_And_Genes.new(current_user)
        @upload_files.set_attributes_and_defaults(params[:upload_trinity_with_edger_transcripts_and_genes])
        @upload_files.save!
      end
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
          @qdet.query!()
          flash[:success] = "Success"
        else
          flash[:success] = "Failure"
        end
      end
    end
    
#     def get_diff_exp_transcripts_file
# #       text = ''
# #       100_000.times do |n|
# #         text += "Good morning!\n"
# #       end
# #       render :text => text, :content_type => 'text/plain'
#       render :file => '/media/sf_MSE_Project/Workshop_Of_Paul/BLAST/outputs/searchio.html'
#     end
    
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
      @qdeg = QueryDiff_ExpGenes.new(current_user)
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
          flash[:notice] = "Success"
        else
          flash[:notice]="Failure"
        end
      end
    end
    
    def query_using_blastn    #Changed after architecture design
      if request.get?
          @query_using_blastn = QueryUsingBlastn.new(current_user)
          @query_using_blastn.set_attributes_and_defaults()
      elsif request.post?
        @query_using_blastn = QueryUsingBlastn.new(current_user)
        @query_using_blastn.set_attributes_and_defaults(params[:query_using_blastn])
        debugger if ENV['RAILS_DEBUG'] == "true"
        #TODO: Move this code back into the view model
        if @query_using_blastn.valid?
            flash[:success] = "Success"
            #Run the blast query and get the file path of the result
            blast_results_file_path = @query_using_blastn.blast!
            #Parse the xml into Blast reports
            f = File.open(blast_results_file_path)
            xml_string = ''
            while not f.eof?
              xml_string += f.readline
            end
            f.close()
            @program = :blastn
            @blast_report = Bio::Blast::Report.new(xml_string,'xmlparser')
            #Send the result to the user
            render :file => 'query_analysis/blast_results'
            #Delete the result file since it is no longer needed
            #File.delete(blast_results_file_path)
        else
            flash[:success]="Failure"
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
        if request.get?
            @query_using_blastn = QueryUsingTblastn.new(current_user)
            @query_using_blastn.set_attributes_and_defaults()
        elsif request.post?
            @query_using_blastn = QueryUsingTblastn.new(current_user)
            @query_using_blastn.set_attributes_and_defaults(params[:query_using_blastn])
            debugger if ENV['RAILS_DEBUG'] == "true"
            if @query_using_blastn.valid?
              flash[:success] = "Success"
              #Run the blast query and get the file path of the result
              blast_results_file_path = @query_using_blastn.blast!
              #Parse the xml into Blast reports
              f = File.open(blast_results_file_path)
              xml_string = ''
              while not f.eof?
                xml_string += f.readline
              end
              f.close()
              @program = :tblastn
              @blast_report = Bio::Blast::Report.new(xml_string,'xmlparser')
              #Send the result to the user
              render :file => 'query_analysis/blast_results'
              #Delete the result file since it is no longer needed
              #File.delete(blast_results_file_path)
            else
                flash[:success]="Failure"
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
      if request.get?
            @query_using_tblastx = QueryUsingTblastx.new(current_user)
            @query_using_tblastx.set_attributes_and_defaults()
      elsif request.post?
          @query_using_tblastx = QueryUsingTblastx.new(current_user)
          @query_using_tblastx.set_attributes_and_defaults(params[:query_using_tblastx])
          debugger if ENV['RAILS_DEBUG'] == "true"
          if @query_using_tblastx.valid?
            flash[:success] = "Success"
            #Run the blast query and get the file path of the result
            blast_results_file_path = @query_using_tblastx.blast!
            #Parse the xml into Blast reports
            f = File.open(blast_results_file_path)
            xml_string = ''
            while not f.eof?
              xml_string += f.readline
            end
            f.close()
            @program = :tblastx
            @blast_report = Bio::Blast::Report.new(xml_string,'xmlparser')
            #Send the result to the user
            render :file => 'query_analysis/blast_results'
            #Delete the result file since it is no longer needed
            #File.delete(blast_results_file_path)
          else
              flash[:success]="Failure"
          end
      end
  end
end
