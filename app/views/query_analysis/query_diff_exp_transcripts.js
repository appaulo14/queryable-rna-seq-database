jQuery(document).ready(function($) {
  dataset_select = $('[name="query_diff_exp_transcripts[dataset]"]');
  dataset_select.change(selected_dataset_changed);
  function selected_dataset_changed(){
    window.location = 'query_diff_exp_transcripts?dataset=' + 
      dataset_select.val();
  }
});
