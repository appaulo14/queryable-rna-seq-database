SuckerPunch.config do
  queue name: :upload_cuffdiff_queue, 
                worker: WorkerForUploadCuffdiff, size: 25
  queue name: :upload_trinity_with_edger_queue, 
                worker: WorkerForUploadTrinityWithEdger, 
                size: 25
  queue name: :upload_fasta_sequences_queue, 
                worker: WorkerForUploadFastaSequences, size: 25
  queue name: :find_go_terms_for_dataset_queue, 
                worker: WorkerForFindGoTermsForDataset, size: 25 
end
