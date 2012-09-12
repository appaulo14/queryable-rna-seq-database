class QueryAnalysisController < ApplicationController
  def upload_main_menu
      debugger if ENV['RAILS_DEBUG'] == "true"
      if request.post? and not params[:data_type].nil?
          redirect_to :action => params[:data_type]
      end
  end

  def upload_reference_cuffdiff
  end

  def upload_de_novo_cuffdiff
  end

  def upload_de_novo_edgeR
      debugger if ENV['RAILS_DEBUG'] == "true"
      if (request.post?)
          params.keys.each do |key|
            if params[key].kind_of? ActionDispatch::Http::UploadedFile
                uploaded_file = params[key]
                File.open(Rails.root.join('file_uploads', uploaded_file.original_filename), 'wb') do |file|
                    file.write(uploaded_file.read)
                end
            end
          end
      end
  end

  def query_diff_exp_transcripts
  end

  def query_diff_exp_genes
  end

  def query_transcript_isoforms
  end

  def query_gene_isoforms
  end

  def query_blast_db
  end
end
    