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
  queue name: :query_using_blast_queue, 
                worker: WorkerForQueryUsingBlast, size: 100
  queue name: :query_regular_db_queue, 
                worker: WorkerForQueryRegularDb, size: 100
end
