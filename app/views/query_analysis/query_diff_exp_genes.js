jQuery(document).ready(function($) {
  create_helptips();
  set_up_reload_on_dataset_changed();
  set_table_table_sorting();
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

/*
 *   Set up table sorting using Stupid Table: 
 *   https://github.com/joequery/Stupid-Table-Plugin
 */
function set_table_table_sorting(){
  var query_results_table = $('#query_results_table').stupidtable();
  query_results_table.bind('aftertablesort', aftertablesort);
  function aftertablesort(event, data) {
    var th = $(this).find("th");
    //Set all to neutral sort arrows first
    th.find(".sort_arrow").remove();
    th.append('<%= j neutral_sort_arrow %>');
    //Use an up or down arrow to show the sorting column, depending on
    //  whether it is sorted in ascending order or descending order
    if (data.direction == 'asc'){
      th.find('.sort_arrow').get(data.column).outerHTML = '';
      th.get(data.column).innerHTML += '<%= j ascending_sort_arrow %>';
    }
    else{
      th.find('.sort_arrow').get(data.column).outerHTML = '';
      th.get(data.column).innerHTML += '<%= j descending_sort_arrow %>';
    }
  }
}
  
/*
 *   Set up Downloadify to allow the user to download their table results 
 *   as a text file.
 */
function set_up_downloadify_for_query_results_downloading(){
  Downloadify.create('downloadify',{
    filename: function(){return 'query_diff_exp_genes.txt';},
    data: get_downloable_file_text,
    onComplete: function(){ alert('Your File Has Been Saved!'); },
    onCancel: function(){ alert('You have cancelled the saving of this file.'); },
    onError: function(){ alert('Error!'); },
    swf: "<%= j asset_path 'downloadify/downloadify.swf' %>",
    downloadImage: "<%= j asset_path 'downloadify/download.png' %>",
    width: 100,
    height: 30,
    transparent: true,
    append: false
  });
}

function get_downloable_file_text(){
  output_string = '';
  //Get the table rows
  var query_results_table = $('#query_results_table');
  var rows = query_results_table.find('tr');
  //Get the header cells and write them to the output string
  header_row = $(rows[0]);
  header_cells = header_row.find('th');
  for (var i=0;i<header_cells.length;i++){
    header_cell = $(header_cells[i]);
    output_string+=header_cell.text().trim();
    //Add a tab to the output string if another header is after this one
    if (i<header_cells.length-1){
      output_string+="\t";
    }
  }
  output_string+="\n";
  //Write all the table cells to the output string.
  //Loop through the rows
  for (var i=1;i<rows.length;i++){
    row = $(rows[i]);
    table_cells = row.find('td');
    //Loop through the cells within a row
    for (var ii=0;ii<table_cells.length;ii++){
      table_cell = $(table_cells[ii]);
      //Add to the output string, removing any excessive spaces
      output_string += table_cell.text().trim().replace(/\s{2,}/gi,'; ');
      //Add a tab to the output string if another cell is after this one
      if (ii<table_cells.length-1){
        output_string+="\t";
      }
    }
    output_string+="\n";
  }
  //Return the final output string
  return output_string;
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
  //Tooltip for Differential expression files
  elements[1] = 'go_terms_helptip';
  titles[1] = 'Filter By Go Terms';
  texts[1] = '<p>Enter more than one term separated by ' +
    'a semicolon to find results than have any of the terms listed.</p> ' +
    '<p>For example, "RNA;hair folicle" will find any genes with GO terms ' +
    'containg the text "RNA" or "hair folicle".</p>'  
    
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
