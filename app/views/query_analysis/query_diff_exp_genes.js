jQuery(document).ready(function($) {
  create_helptips();
  set_up_reload_on_dataset_changed();
  set_table_sorting();
  set_up_downloadify_for_query_results_downloading(); 
});

/*
 *    Reload when a new dataset is selected 
 *    from the select element so the the samples for the
 *    newly selected dataset can be loaded.
 */
function set_up_reload_on_dataset_changed(){
  dataset_select = $('#query_diff_exp_genes_dataset_id');
  dataset_select.change(selected_dataset_changed);
  function selected_dataset_changed(){
    window.location = 'query_diff_exp_genes?dataset_id=' + 
      dataset_select.val();
  }
}

function create_helptips(){
  //Declare variables
  var elements = [];
  var titles = [];
  var texts = [];
  //Tooltip for Filter P-Value or FDR Cutoff
  elements[0] = 'cutoff_helptip';
  titles[0] = 'P-Value or FDR Cutoff';
  texts[0] = 'The p-value measures the statistical significance of a ' +
    "differential expression test. The FDR is a more stringent version of the " +
    "p-value.";
  //Tooltip for go terms
  elements[1] = 'go_terms_helptip';
  titles[1] = 'Filter By Go Terms';
  texts[1] = '<p>Enter more than one term separated by ' +
    'a semicolon to find results than have any of the terms listed.</p> ' +
    '<p>For example, "RNA;hair folicle" will find any genes with GO terms ' +
    'containg the text "RNA" or "hair folicle".</p>'
  //Tooltip for go ids
  elements[2] = 'go_ids_helptip';
  titles[2] = 'Filter By Go IDs';
  texts[2] = '<p>Enter more than one term separated by ' +
    'a semicolon to find results than have any of the go ids listed.</p> ' +
    '<p>For example, "GO:0000836;GO:0001063" will find any genes with ' +
    'either GO:0000836 or GO:0001063".</p>';   
    
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
                          classes: 'qtip-shadow qtip-' + 'light'
                  }
          });
  }
}
