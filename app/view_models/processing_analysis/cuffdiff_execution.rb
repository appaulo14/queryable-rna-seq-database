module Processing_Analysis
    class Cuffdiff_Execution < Processing_Analysis::Execution
    
        #Attributes taken from http://cufflinks.cbcb.umd.edu/manual.html for cufflinks 2.0.2
        attr_accessor :sample_id, #Identifies this unique sample, not a cuffdiff argument
            #Arguments
            :transcript_gtf, :sample_files,
            #Options
            :labels, :time_series, :upper_quartile_norm, :total_hits_norm,
            :compatible_hits_norm, :frag_bias_correct, :multi_read_correct,
            :min_alignment_count, :mask_file, :FDR,
            #Advanced options
            :library_type, :frag_len_mean, :frag_len_std_dev, :max_mle_iterations,
            :poisson_dispersion, :emit_count_tables, :min_isoform_fraction, 
            :max_bundle_frags, :max_frag_count_draws, :max_frag_assign_draws,
            :min_outlier_p, :min_reps_for_js_tests, 
            :no_effective_length_correction
           
    
        def initialize(attributes = {})
            #Load in any values from the form
            super(attributes)
        end
    end
end
