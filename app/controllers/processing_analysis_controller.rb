class ProcessingAnalysisController < ApplicationController
  
  def main_menu
      #Do we need the main_menu form?
       if request.get?
          @@step = 1
          @title = 'What type of processing analysis would you like to do?'
          @form_target = '/processing_analysis/main_menu'
          @submit_text = 'Next'
          @choices=[]
          @choices.push({:id=>"differential_expression",:text=>"Differential expression testing"})
          @choices.push({:id=>"novel_transcript_isoforms",:text=>"Discover novel transcript isoforms"})
          render 'shared/radio_choices'
       else request.post?
           debugger if ENV['RAILS_DEBUG'] == "true"
           if @@step == 1
             redirect_to('http://www.microsoft.com')
           end
           #render 'main_menu_step_2'
       end
  end

  def quality_filtering
  end

  def reference_analysis
  end

  def reference_analysis_isoforms_only
  end

  def de_novo_analysis_edgeR
  end

  def de_novo_analysis_cuffdiff
  end
end
