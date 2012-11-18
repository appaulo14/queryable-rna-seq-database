class QueryAnalysisController < ApplicationController
    include Blast_Query

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

    def upload_de_novo_edgeR
        @number_of_samples = 
            params[:number_of_samples] ? params[:number_of_samples] : 2
        debugger if ENV['RAILS_DEBUG'] == "true"
        if (request.post?)
            params.keys.each do |key|
                if params[key].kind_of? ActionDispatch::Http::UploadedFile
                    uploaded_file = params[key].tempfile
                    #file_to_write = Rails.root.join('tmp/file_uploads', uploaded_file.original_filename)
                    #File.open(file_to_write, 'wb') do |file|
                    #file.write(uploaded_file.read)
                    #TODO: Be sure to delete these files when finished
                    #end
                end
            end
        end
    end

    def query_diff_exp_transcripts
        if (request.post?)
            @samples = ['Sample 1','Sample 2', 'Sample 3']
            #<th>Transcript</th><th>Transcript description</th><th>GO terms</th><th>P-value</th><th>FDR</th>
            @search_results =
            [
                {
                    :transcript => "transcript name",
                    :transcript_description => "transcript description",
                    :go_terms => "go terms",
                    :p_value  => "p value",
                    :fdr      => "fdr",
                    :sample_1 => "sample 1",
                    :sample_2 => "sample 2",
                    :sample_3 => "sample 3"
                }
            ]
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
