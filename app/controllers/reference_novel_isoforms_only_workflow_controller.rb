class ReferenceNovelIsoformsOnlyWorkflowController < ApplicationController
    require 'processing_analysis/execution_group.rb'
    require 'processing_analysis/tophat_execution.rb'
    require 'processing_analysis/cufflinks_execution.rb'
    require 'processing_analysis/cuffcompare_execution.rb'
    require 'processing_analysis/cuffdiff_execution.rb'
    include Processing_Analysis
    
    WORKFLOW = "reference_novel_isoforms_only_workflow"

    def tophat_configure_old
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
    
    def tophat_configure
        debugger if ENV['RAILS_DEBUG'] == 'true'
        @next_step_url = "#"
        if (request.post?)
            #Declare some variables
            @tophat_executions = []
            number_of_samples = params[:processing_analysis_tophat_execution].length
            all_executions_are_valid = true
            #Check that all the tophat executions are valid
            (1..number_of_samples).each do |i|
                tophat_execution = Tophat_Execution.new(params[:processing_analysis_tophat_execution][i.to_s])
                tophat_execution.sample_id = i
                if not tophat_execution.valid?
                    all_executions_are_valid = false
                end
                @tophat_executions << tophat_execution
            end
            if (all_executions_are_valid)
                #Create a new job
                job = Job2.new()
                job.number_of_samples = number_of_samples
                job.eid_of_owner = "pawl"
                job.current_program_display_name = "Tophat"
                job.workflow = "reference_novel_isoforms_only_workflow"
                job.current_step = "in_progress"
                job.next_step="tophat_success"
                job.save!
                read_pipes = {}
                write_pipes = {}
                samples = {}
                @tophat_executions.each do |tophat_execution|
                    sample_id = tophat_execution.sample_id
                    read_pipes[sample_id], write_pipes[sample_id] = IO.pipe
                    sample = Sample.new()
                    sample.sample_id = sample_id
                    sample.job_id = job.id
                    sample.status = "in_progess"
                    sample.save!
                    samples[sample_id] = sample
                end
                #debugger if ENV['RAILS_DEBUG'] == 'true'
                child_pid = fork do
                    logger.warn "Main loop"
                    Sample.establish_connection
                    while (true)
                        sleep 5
                        if (Process.ppid == 1)
                            logger.warn "Parent process is missing. exiting..."
                            exit
                        end
                        logger.warn "Samples count = #{samples.count}"
                        all_samples_complete = true
                        samples.each do |sample_id,sample|
                            rp = read_pipes[sample_id]
                            if rp.closed? == false
                                all_samples_complete = false
                                #See if there is a message yet from the sample process
                                begin
                                    msg = rp.read_nonblock(20)
                                    rp.close
                                    logger.warn "Message from sample #{sample_id} received"
                                    debugger if ENV['RAILS_DEBUG'] == 'true'
                                    if (msg == "success")
                                        sample.status="success"
                                        sample.save!
                                        logger.warn "Sample #{sample_id} saved successfully"
                                    end
                                    #samples.delete(sample_id)
                                rescue Errno::EAGAIN
                                    #logger.warn "Sample #{sample_id} is not yet finished"
                                rescue EOFError
                                end
                            end
                        end
                        if all_samples_complete == true
                            Job2.establish_connection
                            job = Job2.find_by_id(job.id)
                            job.current_step = job.next_step
                            job.next_step = "cufflinks_configure"
                            job.save!
                            logger.warn "job saved"
                            exit
                        end
                    end
                    exit
                end
                Process.detach(child_pid)
                @tophat_executions.each do |tophat_execution|
                    sample_id = tophat_execution.sample_id
                    child_pid = fork do
                        logger.warn "Sample #{sample_id} waiting 15 seconds"
                        sleep 15
                        logger.warn "Sample #{sample_id} slept for 15 seconds"
                        write_pipes[sample_id].write "success"
                        write_pipes[sample_id].close
                        exit
                    end
                    Process.detach(child_pid) 
                end
                redirect_to :action => job.current_step.to_s, :job_id => job.id
            else
                flash[:success] = "Success"
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
        job = Job2.find_by_id!(job_id)
        @next_step_url = job.next_step + "?job_id=#{job_id}"
    end

    def cufflinks_configure
        #In the final version, by sure the user actually has permission for the given job
        job = Job2.find_by_id!(params[:job_id])
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
            @job_id = job.id
            number_of_samples = job.number_of_samples
            (1..number_of_samples.to_i).each do |i|
                @cufflinks_executions.push(Cufflinks_Execution.new(:sample_id=>i))
            end
        end
    end

    def cufflinks_success
        job_id = params[:job_id]
        job = Job2.find_by_id(job_id)
        @next_step_url = "#{job.next_step}?job_id=#{job_id}"
    end

    def cuffcompare_configure
        #In the final version, by sure the user actually has permission for the given job
        job = Job2.find_by_id!(params[:job_id])
        if (request.post?)
            @cuffcompare_executions = []
            (1..params[:processing_analysis_cuffcompare_execution].length).each do |i|
                @cuffcompare_executions << Cuffcompare_Execution.new(params[:processing_analysis_cuffcompare_execution][i.to_s])
                @cuffcompare_executions[i-1].sample_id = i
                if @cuffcompare_executions[i-1].valid?
                    job.current_program_display_name = "Cuffcompare"
                    job.current_step = "in_progress"
                    job.next_step="cuffcompare_success"
                    job.save!
                    child_pid = fork do
                        sleep 15
                        job.current_step = job.next_step
                        job.next_step = "job_success"
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
            @cuffcompare_executions = []
            @job_id = job.id
            number_of_samples = job.number_of_samples
            (1..number_of_samples.to_i).each do |i|
                @cuffcompare_executions.push(Cuffcompare_Execution.new(:sample_id=>i))
            end
        end
    end

    def cuffcompare_success
        job_id = params[:job_id]
        job = Job2.find_by_id!(job_id)
        @next_step_url = "#{job.next_step}?job_id=#{job_id}"
    end
    
    def job_success
    end
    
    def express
        if (request.get?)
            @number_of_samples = params[:number_of_samples]
            @tophat_executions = []
            @cufflinks_executions = []
            @cuffcompare_execution = Cuffcompare_Execution.new()
            (1..@number_of_samples.to_i).each do |i|
                @tophat_executions.push(Tophat_Execution.new(:sample_id=>i))
                @cufflinks_executions.push(Cufflinks_Execution.new(:sample_id=>i))
            end
            return
        end
        if (request.post?)
             #Declare some variables
            @tophat_executions = []
            @cufflinks_executions = []
            @number_of_samples = params[:number_of_samples].to_i
            all_executions_are_valid = true
            #Check that all the tophat parameters for all the samples are valid
            (1..@number_of_samples).each do |i|
                tophat_execution = Tophat_Execution.new(params[:processing_analysis_tophat_execution][i.to_s])
                tophat_execution.sample_id = i
                if not tophat_execution.valid?
                    all_executions_are_valid = false
                end
                @tophat_executions << tophat_execution
            end
            #Check that all the cufflinks parameters for all the samples are valid
            (1..@number_of_samples).each do |i|
                cufflinks_execution = Cufflinks_Execution.new(params[:processing_analysis_cufflinks_execution][i.to_s])
                cufflinks_execution.sample_id = i
                if not cufflinks_execution.valid?
                    all_executions_are_valid = false
                end
                @cufflinks_executions << cufflinks_execution
            end
            #Check that all the cuffcompare samples are valid
            @cuffcompare_execution = Cuffcompare_Execution.new(params[:processing_analysis_cuffcompare_execution])
            if not @cuffcompare_execution.valid?
                all_executions_are_valid = false
            end
            debugger if ENV['RAILS_DEBUG'] == 'true'
            if (all_executions_are_valid)
                #Create a new job
                job = Job2.new()
                job.number_of_samples = @number_of_samples
                job.eid_of_owner = "pawl"
                job.current_program_display_name = "Tophat"
                job.workflow = WORKFLOW
                job.current_step = "in_progress"
                job.next_step="tophat_success"
                job.save!
                read_pipes, write_pipes, samples = {}, {}, {}
                @tophat_executions.each do |tophat_execution|
                    sample_id = tophat_execution.sample_id
                    read_pipes[sample_id], write_pipes[sample_id] = IO.pipe
                    sample = Sample.new()
                    sample.sample_id = sample_id
                    sample.job_id = job.id
                    sample.status = "in_progess"
                    sample.save!
                    samples[sample_id] = sample
                end
                #debugger if ENV['RAILS_DEBUG'] == 'true'
                child_pid = fork do
                    logger.warn "Main loop"
                    Sample.establish_connection
                    while (true)
                        sleep 5
                        if (Process.ppid == 1)
                            logger.warn "Parent process is missing. exiting..."
                            exit
                        end
                        logger.warn "Samples count = #{samples.count}"
                        all_samples_complete = true
                        samples.each do |sample_id,sample|
                            rp = read_pipes[sample_id]
                            if rp.closed? == false
                                all_samples_complete = false
                                #See if there is a message yet from the sample process
                                begin
                                    msg = rp.read_nonblock(20)
                                    rp.close
                                    logger.warn "Message from sample #{sample_id} received"
                                    debugger if ENV['RAILS_DEBUG'] == 'true'
                                    if (msg == "success")
                                        sample.status="success"
                                        sample.save!
                                        logger.warn "Sample #{sample_id} saved successfully"
                                    end
                                    #samples.delete(sample_id)
                                rescue Errno::EAGAIN
                                    #logger.warn "Sample #{sample_id} is not yet finished"
                                rescue EOFError
                                end
                            end
                        end
                        if all_samples_complete == true
                            Job2.establish_connection
                            job = Job2.find_by_id(job.id)
                            job.current_step = job.next_step
                            job.next_step = "cufflinks_configure"
                            job.save!
                            logger.warn "job saved"
                            exit
                        end
                    end
                    exit
                end
                Process.detach(child_pid)
                @tophat_executions.each do |tophat_execution|
                    sample_id = tophat_execution.sample_id
                    child_pid = fork do
                        logger.warn "Sample #{sample_id} waiting 15 seconds"
                        sleep 15
                        logger.warn "Sample #{sample_id} slept for 15 seconds"
                        write_pipes[sample_id].write "success"
                        write_pipes[sample_id].close
                        exit
                    end
                    Process.detach(child_pid) 
                end
                redirect_to :action => job.current_step.to_s, :job_id => job.id
            else
                flash[:success] = "Errors"
            end
            return
        end
    end

    def in_progress
        job_id = params[:job_id]
        job = Job2.find_by_id(job_id)
        if (job.current_step != "in_progress")
            redirect_to :action => job.current_step.to_s, :job_id => job.id
            return
        end
        @current_program_display_name = job.current_program_display_name
        @samples=Sample.find_all_by_job_id(job.id)
    end
end
