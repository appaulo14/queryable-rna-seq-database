jQuery(document).ready(function($) {
  //Ensure the filter parameters are at their correct state or being 
  //    enabled or disabled by running their changed events.
  filter_by_go_names_checked_changed();
//   filter_by_go_ids_checked_changed();
  //Reload when a new dataset is selected 
  //    from the select element so the the samples for the
  //    newly selected dataset can be loaded.
  dataset_select = $('[name="query_diff_exp_transcripts[dataset]"]');
  dataset_select.change(selected_dataset_changed);
  function selected_dataset_changed(){
    window.location = 'query_diff_exp_transcripts?dataset_id=' + 
      dataset_select.val();
  }
  //Enable/disabled the go names text box based on whether
  //    the Filter by GO Names check box is checked
  filter_by_go_names = $('#query_diff_exp_transcripts_filter_by_go_names');
  filter_by_go_names.change(filter_by_go_names_checked_changed);
  function filter_by_go_names_checked_changed(){
    filter_by_go_names = $('#query_diff_exp_transcripts_filter_by_go_names');
    if (filter_by_go_names.is(':checked')){
      $('#query_diff_exp_transcripts_go_names').removeAttr("disabled");
    }
    else{
      $('#query_diff_exp_transcripts_go_names').attr("disabled", "disabled");
    }
  }
//   //Set the filter parameters to enable/disabled based on whether
//   //    the Filter by GO IDs check box is checked
//   filter_by_go_ids = 
//     $('#query_diff_exp_transcripts_filter_by_go_ids');
//     filter_by_go_ids.change(filter_by_go_ids_checked_changed);
//   function filter_by_go_ids_checked_changed(){
//     if (filter_by_go_ids.is(':checked')){
//       $('#query_diff_exp_transcripts_go_ids').removeAttr("disabled");
//     }
//     else{
//       $('#query_diff_exp_transcripts_go_ids').attr("disabled", "disabled");
//     }
//   }
//   //Set the filter parameters to enable/disabled based on whether
//   //    the Filter by Transcript length check box is checked
//   filter_by_go_names = 
//     $('#query_diff_exp_transcripts_filter_by_go_names');
//     filter_by_go_names.change(filter_by_go_names_checked_changed);
//   function filter_by_go_names_checked_changed(){
//     if (filter_by_go_names.is(':checked')){
//       $('#query_diff_exp_transcripts_go_names').removeAttr("disabled");
//     }
//     else{
//       $('#query_diff_exp_transcripts_go_names').attr("disabled", "disabled");
//     }
//   }
//   //Set the filter parameters to enable/disabled based on whether
//   //    the Filter by Transcript Name check box is checked
//   filter_by_go_names = 
//     $('#query_diff_exp_transcripts_filter_by_go_names');
//     filter_by_go_names.change(filter_by_go_names_checked_changed);
//   function filter_by_go_names_checked_changed(){
//     if (filter_by_go_names.is(':checked')){
//       $('#query_diff_exp_transcripts_go_names').removeAttr("disabled");
//     }
//     else{
//       $('#query_diff_exp_transcripts_go_names').attr("disabled", "disabled");
//     }
//   }
});
