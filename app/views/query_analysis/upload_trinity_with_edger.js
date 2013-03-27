gene_sample_cmp_count = 0;
transcript_sample_cmp_count = 0;

$(document).ready(function()
{
  request_gene_sample_cmp();
  request_transcript_sample_cmp();
  $('#btn_add_transcript_sample_cmp').click(request_transcript_sample_cmp);
  $('#btn_remove_transcript_sample_cmp').click(remove_transcript_sample_cmp);
  $('#btn_add_gene_sample_cmp').click(request_gene_sample_cmp);
  $('#btn_remove_gene_sample_cmp').click(remove_gene_sample_cmp);
  has_gene_diff_exp = $('#upload_trinity_with_edge_r_has_gene_diff_exp');
  has_gene_diff_exp.change(has_gene_diff_exp_checked_changed);
  create_tooltips();
}); 

function create_tooltips(){
  //Declare variables
  var elements = [];
  var titles = [];
  var texts = [];
  //Tooltip for Trinity fasta file
  elements[0] = 'trinity_fasta_tooltip';
  titles[0] = 'Trinity.fasta file';
  texts[0] = 'Trinity.pl produces a fasta file called Trinity.fasta ' +
    'which contains the assembled transcripts. It is located in your ' +
    'Trinity output directory.';
  //Tooltip for Differential expression files
  elements[1] = 'differential_expression_tooltip';
  titles[1] = 'Differential Expression File(s)';
  texts[1] = 'run_edgeR.pl produces a file called ' + 
    'all_diff_expression_results.txt, which contains all the ' +
    'differential expression test results. ' +
    'It can be found in your edgeR output directory.'
  //Tooltip for FPKM files
  elements[2] = 'fpkm_tooltip';
  titles[2] = 'FPKM Tracking File(s)';
  texts[2] = 'run_edgeR.pl produces an FPKM tracking file. ' +
    'It is the file in your edgeR output folder that ends in ".FPKM".'  
    
  for (var i = 0; i < elements.length; i++){
    $('#' + elements[i])
          .removeData('qtip') 
          .qtip({
                  content: {
                          text: texts[i], 
                          title: {
                                  text: titles[i],
                                  button: true
                          }
                  },
                  position: {
                          my: 'left center',
                          at: 'right center' 
                  },
                  show: {
                          event: 'click', 
                          ready: false
                  },
                  hide: false,
                  style: {
                          classes: 'qtip-shadow qtip-' + 'dark'
                  }
          });
  }
}

function has_gene_diff_exp_checked_changed(){
//  children = $('#gene_section').children();
  
  if ($('#upload_trinity_with_edge_r_has_gene_diff_exp').is(':checked')){
    file_inputs = $('#gene_section').find('input:file');
    for(var i = 0; i < file_inputs.length; i++){
      $(file_inputs[i]).removeAttr("disabled");
    }
    $('#btn_add_gene_sample_cmp').removeAttr("disabled");
    $('#btn_remove_gene_sample_cmp').removeAttr("disabled");
    
  }
  else{
    file_inputs = $('#gene_section').find('input:file');
    for(var i = 0; i < file_inputs.length; i++){
      $(file_inputs[i]).attr("disabled", "disabled");
    }
    $('#btn_add_gene_sample_cmp').attr("disabled", "disabled");
    $('#btn_remove_gene_sample_cmp').attr("disabled", "disabled");
  }
}

function request_transcript_sample_cmp(){
  transcript_sample_cmp_count += 1;
  var request_str = 'add_sample_cmp_for_trinity_with_edger_transcripts' +
                    '?sample_cmp_count=' + transcript_sample_cmp_count;
  $.get(request_str,add_transcript_sample_cmp)
}

function add_transcript_sample_cmp(sample_cmp_html){
  $('#transcript_sample_comparisons_div').append(sample_cmp_html);
}

function remove_transcript_sample_cmp(){
  transcript_sample_cmp_count -= 1;
  $('#transcript_sample_comparisons_div').children().last().remove();
}

function request_gene_sample_cmp(){
  gene_sample_cmp_count += 1;
  var request_str = 'add_sample_cmp_for_trinity_with_edger_genes' +
                    '?sample_cmp_count=' + gene_sample_cmp_count;
  $.get(request_str,add_gene_sample_cmp)
}

function add_gene_sample_cmp(sample_cmp_html){
  $('#gene_sample_comparisons_div').append(sample_cmp_html);
  has_gene_diff_exp_checked_changed();
}

function remove_gene_sample_cmp(){
  gene_sample_cmp_count -= 1;
  $('#gene_sample_comparisons_div').children().last().remove();
}