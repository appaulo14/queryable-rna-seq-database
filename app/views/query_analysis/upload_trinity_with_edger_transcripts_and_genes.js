SAMPLE_CMP_COUNT = 0;

$(document).ready(function()
{
  request_sample_cmp();
  $('#btn_add_sample_cmp').click(request_sample_cmp);
  $('#btn_remove_sample_cmp').click(remove_sample_cmp);
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

function request_sample_cmp(){
  SAMPLE_CMP_COUNT += 1;
  var request_str = 'add_sample_cmp_for_trinity_with_edger_transcripts_and_genes' +
                    '?sample_cmp_count=' + SAMPLE_CMP_COUNT;
  $.get(request_str,add_sample_cmp)
}

function add_sample_cmp(sample_cmp_html){
  $('#sample_comparisons_div').append(sample_cmp_html);
}

function remove_sample_cmp(){
  SAMPLE_CMP_COUNT -= 1;
  $('#sample_comparisons_div').children().last().remove();
}
