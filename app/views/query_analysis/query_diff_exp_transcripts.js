jQuery(document).ready(function($) {
  //Set up table sorting
  var query_results_table = $('#query_results_table').stupidtable();

    query_results_table.bind('beforetablesort', function (event, data) {
      // data.column - the index of the column sorted after a click
      // data.direction - the sorting direction (either asc or desc)
      $("#sorting_by").text("Sorting by " + data.column)
    });

//     table.bind('aftertablesort', function (event, data) {
//       var th = $(this).find("th");
//       th.find(".arrow").remove();
//       var arrow = data.direction === "asc" ? "&uarr;" : "&darr;";
//       th.eq(data.column).append('<span class="arrow">' + arrow +'</span>');
//     });
// 
//     $("tr").slice(1).click(function(){
//       $(".awesome").removeClass("awesome");
//       $(this).addClass("awesome");
//     });
  //Ensure the filter parameters are at their correct state or being 
  //    enabled or disabled by running their changed events.
  filter_by_go_names_checked_changed();
  filter_by_go_ids_checked_changed();
  filter_by_transcript_name_checked_changed();
  filter_by_transcript_length_checked_changed();
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
  //Enable/disabled the GO IDs text box based on whether
  //    the Filter by GO IDs check box is checked
  filter_by_go_ids = $('#query_diff_exp_transcripts_filter_by_go_ids');
    filter_by_go_ids.change(filter_by_go_ids_checked_changed);
  function filter_by_go_ids_checked_changed(){
    filter_by_go_ids = $('#query_diff_exp_transcripts_filter_by_go_ids');
    if (filter_by_go_ids.is(':checked')){
      $('#query_diff_exp_transcripts_go_ids').removeAttr("disabled");
    }
    else{
      $('#query_diff_exp_transcripts_go_ids').attr("disabled", "disabled");
    }
  }
  //Enable/disabled the transcript length select element and text box and 
  //    based on whether the Filter by Transcript length check box is checked
  filter_by_transcript_length = 
    $('#query_diff_exp_transcripts_filter_by_transcript_length');
    filter_by_transcript_length.change(
      filter_by_transcript_length_checked_changed
    );
  function filter_by_transcript_length_checked_changed(){
    filter_by_transcript_length = 
      $('#query_diff_exp_transcripts_filter_by_transcript_length');
    transcript_length_comparison_sign = 
      $('#query_diff_exp_transcripts_transcript_length_comparison_sign');
    transcript_length_value = 
      $('#query_diff_exp_transcripts_transcript_length_value');
    if (filter_by_transcript_length.is(':checked')){
      transcript_length_comparison_sign.removeAttr("disabled");
      transcript_length_value.removeAttr("disabled");
    }
    else{
      transcript_length_comparison_sign.attr("disabled", "disabled");
      transcript_length_value.attr("disabled", "disabled");
    }
  }
  //Enable/disabled based on whether
  //    the Filter by Transcript Name check box is checked
  filter_by_transcript_name = 
    $('#query_diff_exp_transcripts_filter_by_transcript_name');
  filter_by_transcript_name.change(filter_by_transcript_name_checked_changed);
  function filter_by_transcript_name_checked_changed(){
    filter_by_transcript_name = 
      $('#query_diff_exp_transcripts_filter_by_transcript_name');
    if (filter_by_transcript_name.is(':checked')){
      $('#query_diff_exp_transcripts_transcript_name').removeAttr("disabled");
    }
    else{
      $('#query_diff_exp_transcripts_transcript_name').attr("disabled", "disabled");
    }
  }
});
