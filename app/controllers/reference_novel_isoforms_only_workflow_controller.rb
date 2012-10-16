class ReferenceNovelIsoformsOnlyWorkflowController < ApplicationController
    require 'processing_analysis/execution_group.rb'
    require 'processing_analysis/tophat_execution.rb'
    require 'processing_analysis/cufflinks_execution.rb'
    require 'processing_analysis/cuffcompare_execution.rb'
    require 'processing_analysis/cuffdiff_execution.rb'
    include Processing_Analysis

    def tophat_configure
        debugger if ENV['RAILS_DEBUG'] == 'true'
        @next_step_url = "#"
        if (request.post?)
            @tophat_executions = []
            number_of_samples = params[:processing_analysis_tophat_execution].length
            (1..number_of_samples).each do |i|
                @tophat_executions << Tophat_Execution.new(params[:processing_analysis_tophat_execution][i.to_s])
                @tophat_executions[i-1].sample_id = i
                if @tophat_executions[i-1].valid?
                    job = Job2.new()
                    job.number_of_samples = number_of_samples
                    job.eid_of_owner = "pawl"
                    job.current_program_display_name = "Tophat"
                    job.workflow = "reference_novel_isoforms_only_workflow"
                    job.current_step = "in_progress"
                    job.next_step="tophat_success"
                    job.save!
                    child_pid = fork do
                        sleep 15
                        job.current_step = job.next_step
                        job.next_step = "cufflinks_configure"
                        job.save!
                        exit
                    end
                    Process.detach(child_pid)
                    redirect_to :action => job.current_step.to_s, :job_id => job.id
                else
                    flash[:success]="Failure"
                end
            end
        else
            @tophat_executions = []
            number_of_samples = params[:number_of_samples]
            (1..number_of_samples.to_i).each do |i|
                @tophat_executions.push(Tophat_Execution.new(:sample_id=>i))
            end
        end
    end

    def tophat_success
        job_id = params[:job_id]
        job = Job2.find_by_id(job_id)
        @next_step_url = job.next_step + "?job_id=#{job_id}"
    end

    def cufflinks_configure
        job = Job2.find_by_id(params[:job_id])
        if (request.post?)
            @cufflinks_executions = []
            (1..params[:processing_analysis_cufflinks_execution].length).each do |i|
                @cufflinks_executions << Cufflinks_Execution.new(params[:processing_analysis_cufflinks_execution][i.to_s])
                @cufflinks_executions[i-1].sample_id = i
                if @cufflinks_executions[i-1].valid?
                    job.current_program_display_name = "Cufflinks"
                    job.current_step = "in_progress"
                    job.next_step="cufflinks_success"
                    job.save!
                    child_pid = fork do
                        sleep 15
                        job.current_step = job.next_step
                        job.next_step = "cuffcompare_configure"
                        job.save!
                        exit
                    end
                    Process.detach(child_pid)
                    redirect_to :action => job.current_step.to_s, :job_id => job.id
                else
                    flash[:success]="Failure"
                end
            end
        else
            @cufflinks_executions = []
            number_of_samples = job.number_of_samples
            (1..number_of_samples.to_i).each do |i|
                @cufflinks_executions.push(Cufflinks_Execution.new(:sample_id=>i))
            end
        end
    end

    def cufflinks_success
        job_id = params[:job_id]
        job = Job2.find_by_id(job_id)
        @next_step_url = job.next_step
    end

    def cuffcompare_configure
    end

    def cuffcompare_success
    end

    def in_progress
        job_id = params[:job_id]
        job = Job2.find_by_id(job_id)
        if (job.current_step != "in_progress")
            redirect_to :action => job.current_step.to_s, :job_id => job.id
        end
        @current_program_display_name = job.current_program_display_name
    end
end
