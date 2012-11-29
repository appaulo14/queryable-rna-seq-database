$(document).ready(function()
{
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
    texts[1] = 'run_edgeR.pl produces an FPKM tracking file. ' +
      'It is the file in your edgeR output folder that ends in ".FPKM".'
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
                            my: 'left center', // Use the corner...
                            at: 'right center' // ...and opposite corner
                    },
                    show: {
                            event: 'click', // Don't specify a show event...
                            ready: false // ... but show the tooltip when ready
                    },
                    hide: false, // Don't specify a hide event either!
                    style: {
                            classes: 'qtip-shadow qtip-' + 'dark'
                    }
            });
    }
}); 
