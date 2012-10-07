namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    make_users
    make_programs
    make_program_statuses
    make_job_statuses
    make_workflows_and_workflow_steps
  end
end

def make_users
    User.create!(:eid   => "nietz111",
                 :email => "nietz111@ksu.edu")
end

def make_programs
    Program.create!(:internal_name => "tophat", :display_name => "Tophat")
    Program.create!(:internal_name => "cufflinks", :display_name => "Cufflinks")
    Program.create!(:internal_name => "cuffcompare",:display_name => "Cuffcompare")
end

def make_program_statuses
    Program_Status.create!(:internal_name => "configuring", :display_name => "Configuring parameters")
    Program_Status.create!(:internal_name => "in_progress", :display_name => "Execution in progress")
    Program_Status.create!(:internal_name=> "success", :display_name => "Execution successful")
    Program_Status.create!(:internal_name => "failure", :display_name => "Execution successful")
end

def make_job_statuses
    Job_Status.create!(:name => "not yet started", 
                       :description => "Files have been uploaded and the job created, but no programs have yet executed.")
    Job_Status.create!(:name => "in-progress", 
                       :description => "The programs in the job's workflow are in the process of running")
    Job_Status.create!(:name => "succeeded", 
                       :description => "All programs in the job's workflow have completed successfully")
    Job_Status.create!(:name => "failed", 
                       :description => "The job has failed and cannot continue for some reason")
end

def make_workflows_and_workflow_steps
    reference_novel_isoforms_only_workflow = Workflow.create!(:display_name => "Reference Workflow Novel Isoforms Only")
    Workflow_Step.create!(:workflow_id => reference_novel_isoforms_only_workflow.id,
                          :program_internal_name => "tophat",
                          :step => 1)
    Workflow_Step.create!(:workflow_id => reference_novel_isoforms_only_workflow.id,
                          :program_internal_name => "cufflinks",
                          :step => 2)
    Workflow_Step.create!(:workflow_id => reference_novel_isoforms_only_workflow.id,
                          :program_internal_name => "cuffcompare",
                          :step => 3)
end
