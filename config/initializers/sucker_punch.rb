SuckerPunch.config do
  #queue name: :log_queue, worker: LogWorker, size: 10
  queue name: :upload_cuffdiff_queue, worker: UploadCuffdiffWorker, size: 25
  #queue name: :trinity_with_edger_transcripts_and_genes_queue, worker: AwesomeWorker, size: 25
  #queue name: :trinity_with_edger_transcripts_queue, worker: AwesomeWorker, size: 25
  #queue name: :fasta_sequences_onlu_queue, worker: AwesomeWorker, size: 25
end