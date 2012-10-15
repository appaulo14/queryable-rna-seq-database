class ReferenceNovelIsoformsOnlyWorkflowController < ApplicationController
    require 'processing_analysis/execution_group.rb'
    require 'processing_analysis/tophat_execution.rb'
    require 'processing_analysis/cufflinks_execution.rb'
    require 'processing_analysis/cuffcompare_execution.rb'
    require 'processing_analysis/cuffdiff_execution.rb'
    include Processing_Analysis

    def tophat_configure
        if (request.post?)
        else
            debugger if ENV['RAILS_DEBUG'] == 'true'
            @next_step_url = "#"
            @tophat_executions = []
            number_of_samples = params[:number_of_samples]
            (1..number_of_samples.to_i).each do |i|
                @tophat_executions.push(Tophat_Execution.new(:sample_id=>i))
        end
    end

    def tophat_success
    end

    def cufflinks_configure
    end

    def cufflinks_success
    end

    def cuffcompare_configure
    end

    def cuffcompare_success
    end

    def in_progress
    end
end
