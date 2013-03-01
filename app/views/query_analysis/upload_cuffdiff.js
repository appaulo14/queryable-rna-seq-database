jQuery(document).ready(function($) {
  set_up_events_for_enable_or_disable_upload_sections();
});

function set_up_events_for_enable_or_disable_upload_sections(){
  //Ensure the sections are at their correct state or being 
  //    enabled or disabled by running their changed events.
  has_diff_exp_checked_changed();
  has_transcript_isoforms_checked_changed();
  //Bind the events 
  has_diff_exp = $('#upload_cuffdiff_has_diff_exp');
  has_diff_exp.change(has_diff_exp_checked_changed);
  has_transcript_isoforms = $('#upload_cuffdiff_has_transcript_isoforms');
  has_transcript_isoforms.change(has_transcript_isoforms_checked_changed);
}

//Enable/disable the section for uploading differential expression files 
//      based on whether or not the box is checked
function has_diff_exp_checked_changed(){
  has_diff_exp = $('#upload_cuffdiff_has_diff_exp');
  if (has_diff_exp.is(':checked')){
    $('#upload_cuffdiff_gene_diff_exp_file').removeAttr("disabled");
    $('#upload_cuffdiff_transcript_diff_exp_file').removeAttr("disabled");
  }
  else{
    $('#upload_cuffdiff_gene_diff_exp_file').attr("disabled", "disabled");
    $('#upload_cuffdiff_transcript_diff_exp_file').attr("disabled", "disabled");
  }
}

//Enable/disable the section for uploading the transcript isoforms file 
//      based on whether or not the box is checked
function has_transcript_isoforms_checked_changed(){
  has_transcript_isoforms = $('#upload_cuffdiff_has_transcript_isoforms');
  if (has_transcript_isoforms.is(':checked')){
    $('#upload_cuffdiff_transcript_isoform_file').removeAttr("disabled");
  }
  else{
    $('#upload_cuffdiff_transcript_isoform_file').attr("disabled", "disabled");
  }
}
