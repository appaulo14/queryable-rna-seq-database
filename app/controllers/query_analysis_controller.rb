class QueryAnalysisController < ApplicationController
  def upload_main_menu
      if defined? Rails.debugger and Rails.debugger == 1
        puts "DEBUGGER"
        debugger
      else
          puts "NOT DEBUGGER"
      end
      if request.post? and not params[:data_type].nil?
          debugger if not Rails.debugger.nil?
          redirect_to :action => params[:data_type]
      end
  end

  def upload_reference_cuffdiff
  end

  def upload_de_novo_cuffdiff
  end

  def upload_de_novo_edgeR
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
    