class ProcessingAnalysisController < ApplicationController
  
  def initialize
    puts "INITIALIZING"
    super
  end
    
  def main_menu
      #Do we need the main_menu form?
      @choices = []
      @form_target = '/processing_analysis/main_menu'
      @submit_text = 'Next'
      if request.post?
           debugger if ENV['RAILS_DEBUG'] == "true"
           if session[:step] == 1
             session[:step] = 2
             case params[:choice]
             when "differential_expression"
                @title = 'Do you want to use a a reference genome for differential expression?'
                @choices.push({:id=>"reference",:text=>"Use reference genome"})
                @choices.push({:id=>"de_novo",:text=>"Don't use reference genome (de-novo)"})
                render 'shared/radio_choices'
             when "novel_transcript_isoforms"
                redirect_to '/processing_analysis/reference_analysis_isoforms_only'
             when "both"
                 redirect_to '/processing_analysis/reference_analysis'
             end
           elsif session[:step] == 2
               session[:step]=3
               case params[:choice]
               when "reference"
                   redirect_to '/processing_analysis/reference_analysis'
               else
                   @title = 'Would you like to use cuffdiff or edgeR for differential expression?'
                   @choices.push({:id=>"cuffdiff",:text=>"Cuffdiff"})
                   @choices.push({:id=>"edgeR",:text=>"edgeR"})
                   render 'shared/radio_choices'
               end
           elsif session[:step] == 3
              session[:step] = 4
              case params[:choice]
              when "cuffdiff"
                  redirect_to '/processing_analysis/de_novo_analysis_cuffdiff'
              when "edgeR"
                  redirect_to '/processing_analysis/de_novo_analysis_edgeR'
              end
           end
      else      #if not request.post?
         session[:step] = 1
         @title = 'What type of processing analysis would you like to do?'
         @choices.push({:id=>"differential_expression",:text=>"Differential expression testing"})
         @choices.push({:id=>"novel_transcript_isoforms",:text=>"Discover novel transcript isoforms"})
         @choices.push({:id=>"both",:text=>"Both of them"})
         render 'shared/radio_choices'
      end
  end

  def quality_filtering
  end

  def reference_analysis
      redirect_to '/processing_analysis/de_novo_analysis_cuffdiff'
      sleep 5
      #redirect_to '/processing_analysis/de_novo_analysis_edgeR'
#       if request.post?
#         case session[:reference_analysis_step]
#         when 'tophat'
#             render 'tophat'
#         when 'cufflinks'
#             render 'cufflinks'
#         when 'cuffcompare'
#             render 'cuffcompare'
#         when 'cuffdiff'
#             render 'cuffdiff'
#         end
#       end
  end

  def reference_analysis_isoforms_only
      if (request.get?)
          job_id = params[:job_id]
          return if job_id.nil?
          job = Job.find_by_id(job_id)
          if (job.status == "complete")
              @message = "job complete"
          else
              @message = "Incomplete"
          end
      elsif (request.post?)
        job = Job.new()
        job.status = "incomplete"
        job.save()
        child_pid = fork do
            sleep 30
            job.status = "complete"
            job.save()
            exit
        end
        Process.detach(child_pid)
     end
  end

  def de_novo_analysis_edgeR
  end

  def de_novo_analysis_cuffdiff
  end
end
