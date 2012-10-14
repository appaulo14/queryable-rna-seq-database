module Processing_Analysis
    class Tophat_Execution < Processing_Analysis::Execution
    
        #Attributes taken from http://tophat.cbcb.umd.edu/manual.html for Tophat 2.0.5
        attr_accessor 
            #Identifier for rails
            :sample_id,
            #Arugments
            :aligned_reads,
            #General options
            :GTF, :GTF_guide, :mask_file, :frag_bias_correct,
            :multi_read_correct, :library_type,
            #Advanced Abundance Estimation Options
            :frag_len_mean, :frag_len_std_dev, :upper_quartile_norm,
            :total_hits_norm, :compatible_hits_norm, :max_mle_iterations,
            :max_bundle_frags, :no_effective_length_correction,
            #Advanced Assembly Options
            :min_isoform_fraction, :pre_mrna_fraction, :max_intron_length,
            :junc_alpha, :small_anchor_fraction, :min_frags_per_transfrag,
            :overhang_tolerance, :max_bundle_length, :min_intron_length,
            :trim_3_avgcov_thresh, :trim_3_dropoff_frac, :max_multiread_fraction,
            :overlap_radius,
            #Advanced Reference Annotation Based Transcript (RABT) Assembly Options
            :three_overhang_tolerance, :intron_overhang_tolerance, :no_faux_reads
           
    
        def initialize(attributes = {})
            #Load in any values from the form
            super(attributes)
        end
    end
end
