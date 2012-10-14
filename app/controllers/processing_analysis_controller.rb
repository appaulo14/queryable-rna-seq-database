class ProcessingAnalysisController < ApplicationController
    require 'processing_analysis/execution_group.rb'
    require 'processing_analysis/tophat_execution.rb'
    include Processing_Analysis

    def main_menu
        #Do we need the main_menu form?
#         @choices = []
#         @form_target = '/processing_analysis/main_menu'
#         @submit_text = 'Next'
#         if request.post?
#             redirect_to :action => :upload_files
#                         debugger if ENV['RAILS_DEBUG'] == "true"
#                         if session[:step] == 1
#                             session[:step] = 2
#                             case params[:choice]
#                             when "differential_expression"
#                                 @title = 'Do you want to use a a reference genome for differential expression?'
#                                 @choices.push({:id=>"reference",:text=>"Use reference genome"})
#                                 @choices.push({:id=>"de_novo",:text=>"Don't use reference genome (de-novo)"})
#                                 render 'shared/radio_choices'
#                             when "novel_transcript_isoforms"
#                                 redirect_to '/processing_analysis/reference_analysis_isoforms_only'
#                             when "both"
#                                 redirect_to '/processing_analysis/reference_analysis'
#                             end
#                         elsif session[:step] == 2
#                             session[:step]=3
#                             case params[:choice]
#                             when "reference"
#                                 redirect_to '/processing_analysis/reference_analysis'
#                             else
#                                 @title = 'Would you like to use cuffdiff or edgeR for differential expression?'
#                                 @choices.push({:id=>"cuffdiff",:text=>"Cuffdiff"})
#                                 @choices.push({:id=>"edgeR",:text=>"edgeR"})
#                                 render 'shared/radio_choices'
#                             end
#                         elsif session[:step] == 3
#                             session[:step] = 4
#                             case params[:choice]
#                             when "cuffdiff"
#                                 redirect_to '/processing_analysis/de_novo_analysis_cuffdiff'
#                             when "edgeR"
#                                 redirect_to '/processing_analysis/de_novo_analysis_edgeR'
#                             end
#                         end
#                     else      #if not request.post?
#                         session[:step] = 1
#                         @title = 'What type of processing analysis would you like to do?'
#                         @choices.push({:id=>"differential_expression",:text=>"Differential expression testing"})
#                         @choices.push({:id=>"novel_transcript_isoforms",:text=>"Discover novel transcript isoforms"})
#                         @choices.push({:id=>"both",:text=>"Both of them"})
#                         render 'shared/radio_choices'
#         end
    end

    def upload_files
    end

    def quality_filtering
    end

    def reference_analysis
        #redirect_to '/processing_analysis/de_novo_analysis_cuffdiff'
        #sleep 5
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
        workflow = Workflow.find_by_id(1)
        workflow_step = Workflow_Step.where(:workflow_id => workflow.id, :step => 1)[0]
        job = Job.new(:current_job_status => Job_Status.find_by_name("not yet started"),
        :current_program_status => "configuring",
        :eid_of_owner => "nietz111",
        :workflow_step_id => workflow_step.id)
        job.save!
        @next_step_url = workflow_step.program_internal_name.to_s + "_" + job.current_program_status.to_s + "?job_id=" + job.id.to_s
        #         debugger if ENV['RAILS_DEBUG'] == "true"
        #         job_id = params[:job_id]
        #         if (request.get?)
        #             if (not job_id.nil? and not job_id.empty?)
        #                 job = Job.find_by_id(job_id)
        #                 @job_status = "Status for job #{job.id} is #{job.job_status}."
        #                 @current_program_status = "#{job.current_program} is #{job.current_program_status}"
        #                 @job_id = job_id
        #             end
        #         elsif (request.post?)
        #             sleep_interval = 15
        #             if (not job_id.nil? and not job_id.empty?)
        #                 job = Job.find_by_id(job_id)
        #                 if (job.current_program_status == "complete")
        #                     if (job.current_program == "tophat")
        #                         job.current_program = "cufflinks"
        #                         job.current_program_status = "in-progress"
        #                         job.save!()
        #                     elsif (job.current_program == "cufflinks")
        #                         job.current_program = "cuffcompare"
        #                         job.current_program_status = "in-progress"
        #                         job.save!()
        #                     elsif (job.current_program == "cuffcompare")
        #                         job.job_status = "complete"
        #                         job.save!()
        #                     else
        #                         #Do something here?
        #                     end
        #                     child_pid = fork do
        #                         sleep sleep_interval
        #                         job.current_program_status = "complete"
        #                         if (job.current_program == "cuffcompare")
        #                             job.job_status = "complete"
        #                         end
        #                         job.save!
        #                         exit
        #                     end
        #                     Process.detach(child_pid)
        #                 end
        #             else
        #                 job = Job.new()
        #                 job.eid_of_owner = "pawl"
        #                 job.job_status = "in-progess"
        #                 job.current_program = "tophat"
        #                 job.current_program_status = "in-progress"
        #                 job.save!()
        #                 child_pid = fork do
        #                     sleep sleep_interval
        #                     job.current_program_status = "complete"
        #                     job.save!
        #                     exit
        #                 end
        #                 Process.detach(child_pid)
        #             end
        #             redirect_to :action => :reference_analysis_isoforms_only, :job_id => job.id
        #         end
    end

    def tophat_configuring
        debugger if ENV['RAILS_DEBUG'] == "true"
        #This part would be done on submit most likely
        job = Job.find_by_id(params[:job_id])
        job.current_program_status = "in_progress"
        job.save!
        workflow_step = Workflow_Step.find_by_id(job.workflow_step_id)
        @next_step_url = workflow_step.program_internal_name.to_s + "_" + job.current_program_status.to_s + "?job_id=" + job.id.to_s


        if (request.get?)
            #             @execution_group = Execution_Group.new()
            #             3.times { @execution_group.tophat_executions.build }
            @tophat_executions = []
            number_of_samples = (not params[:number_of_samples].blank?) ? params[:number_of_samples] : 1
            (1..number_of_samples.to_i).each do |i|
                @tophat_executions.push(Tophat_Execution.new(:id=>i))
            end
        elsif (request.post?)
            @tophat_executions = []
            (1..params[:processing_analysis_tophat_execution].length).each do |i|
                @tophat_executions << Tophat_Execution.new(params[:processing_analysis_tophat_execution][i.to_s])
                @tophat_executions[i-1].id = i
                if @tophat_executions[i-1].valid?
                    job = Job.new()
                    job.eid_of_owner = "pawl"
                    job.current_program = "tophat"
                    job.current_program_status = "in-progess"
                    job.job_status="in-progess"
                    job.save!
                    child_pid = fork do
                        sleep 15
                        job.current_program_status = "complete"
                        job.save!
                        exit
                    end
                    Process.detach(child_pid)
                    redirect_to :action => :tophat_in_progress, :job_id => job.id
                else
                    flash[:success]="Failure"
                end
            end
        end
    end

    def params_foo
        debugger if ENV['RAILS_DEBUG'] == "true"
        if (request.get?)
            t1 = Tophat_Execution.new()
            t1.name = "tophat1"
            t2 = Tophat_Execution.new()
            t2.name = "tophat2"
            @execution_group = Execution_Group.new()
            @execution_group.name = "Execution Group Name"
            @execution_group.executions = [t1,t2]
        elsif (request.post?)
        end
    end

    def tophat_in_progress
        #This part would be done on submit most likely
        job = Job.find_by_id(params[:job_id])
        job.current_program_status = "success"
        job.save!
        workflow_step = Workflow_Step.find_by_id(job.workflow_step_id)
        @next_step_url = workflow_step.program_internal_name.to_s + "_" + job.current_program_status.to_s + "?job_id=" + job.id.to_s
    end

    def tophat_success
        job = Job.find_by_id(params[:job_id])
        workflow_step = Workflow_Step.find_by_id(job.workflow_step_id)
        next_workflow_step = Workflow_Step.where(:workflow_id => workflow_step.workflow_id, :step => workflow_step.step + 1)[0]
        if (next_workflow_step.blank?)
            #Redirect to main menu for now if this is no step after this
            redirect_to :action => :main_menu
        end
        job.current_program_status = "configuring"
        job.workflow_step_id = next_workflow_step
        job.save!
        @next_step_url = next_workflow_step.program_internal_name.to_s + "_" + job.current_program_status.to_s + "?job_id=" + job.id.to_s
    end

    def de_novo_analysis_edgeR
    end

    def de_novo_analysis_cuffdiff
    end

    private
    def redirect_to_next_page_of_workflow
        job = Job.find_by_id(params[:job_id])
        if (job.job_status == "complete")
        elsif (job.job_status == "in-progress")
            if (job.current_program == "tophat")
                if (job.current_program_status == "not started")
                elsif (job.current_program_status == "in-progress")
                elsif (job.current_program_status == "complete")
                end
            elsif (job.current_program == "cufflinks")
            end
        elsif (job.job_status == "not started")
        end
    end

    def redirect_to_next_page_of_workflow2
        job = Job.find_by_id(params[:job_id])
        if (job.job_status == "complete")
        elsif (job.job_status == "in-progress")
            if (job.current_program_status == "not started")
            elsif (job.current_program_status == "in-progress")
            elsif (job.current_program_status == "complete")
            end
        elsif (job.job_status == "not started")
        end
    end
end
