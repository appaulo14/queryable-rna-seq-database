$(document).ready(function()
{
    var text = 'run_edgeR.pl produces an FPKM tracking file. ' +
      'It is the file in your edgeR output folder that ends in ".FPKM".'
    $('#fpkm_tooltip')
            .removeData('qtip') 
            .qtip({
                    content: {
                            text: text, 
                            title: {
                                    text: "FPKM Tracking Files",
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
}); 
