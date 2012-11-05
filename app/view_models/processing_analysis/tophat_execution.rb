module Processing_Analysis
    class Tophat_Execution < Processing_Analysis::Execution
    
        #Attributes taken from http://tophat.cbcb.umd.edu/manual.html for Tophat 2.0.5
        attr_accessor :sample_id, #Identifies this unique sample, not a tophat argument
            #Arugments
            :ebwt_base, :reference_fasta, :reads_fastq, 
            #Argument helpers, which will be used which arguments to pass to Tophat
            :ebwt_base_or_reference_fasta,
            #Options
            :read_mismatches, 
            :read_gap_length, :read_edit_dist, :read_realign_edit_dist,
            :bowtie1, :mate_inner_distance, :mate_std_dev, :min_anchor_length,
            :splice_mismatches, :min_intron_length, :max_intron_length,
            :max_insertion_length, :max_deletion_length, :solexa_quals,
            :solexa1point3_quals, :quals, :integer_quals, :color, :max_multihits,
            :report_secondary_alignments, :no_discordant, :no_mixed, 
            :no_coverage_search, :microexon_search, :library_type,
            #Option helpers, which will be used which arguments to pass to Tophat
            :default_options_or_custom_options,
            #Advanced options
            :bowtie_n, :segment_mismatches, :segment_length, :min_segment_intron,
            :max_segment_intron, :min_coverage_intron, :max_coverage_intron,
            #Bowtie 2 specific options
            ##Bowtie 2 preset options
            :b2_very_fast, :b2_fast, :b2_sensitive, :b2_very_sensitive,
            ##Bowtie 2 alignment options
            :b2_N, :b2_L, :b2_i, :b2_n_ceil, :b2_gbar,
            ##Bowtie 2 scoring options
            :b2_mp, :b2_np, :b2_rdg, :b2_rfg, :b2_score_min,
            ##Bowtie 2 effort options
            :b2_D, :b2_R,
            #Fusion mapping options
            :fusion_search, :fusion_anchor_length, :fusion_min_dist, 
            :fusion_read_mismatches, :fusion_multireads, :fusion_multipairs,
            :fusion_ignore_chromosomes,
            #Supplying your own transcript annotation data
            :raw_juncs, :no_novel_juncs, :GTF, :transcriptome_index,
            #Options only used with :GTF or :transcriptome_index
            :transcriptomes_only, :transcriptome_max_hits, :prefilter_multihits,
            #Supplying your own insertions/deletions
            :insertions, :deletions, :no_novel_indels
        
        validates :read_mismatches, :numericality => {:only_integer => true}
        validates :read_gap_length, :numericality => {:only_integer => true}
        
        def initialize(attributes = {})
            #Load in any values from the form
            super(attributes)
            if (self.ebwt_base_or_reference_fasta.blank?)
                self.ebwt_base_or_reference_fasta = "ebwt_base"
            end
            if (self.default_options_or_custom_options.blank?)
                self.default_options_or_custom_options = "default_options"
            end
            if (self.read_mismatches.blank?)
                self.read_mismatches = 2
            end
            if (self.read_gap_length.blank?)
                self.read_gap_length = 2
            end
        end
    end
end
