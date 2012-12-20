#!/usr/bin/perl

# This is code example 4 in the Graphics-HOWTO from
#       http://www.bioperl.org/wiki/HOWTO:Graphics
use strict;

use Bio::Graphics;
use Bio::SearchIO;
use Bio::SeqFeature::Generic;
use Bio::SearchIO::Writer::HTMLResultWriter;
my $input_file_path = shift or die "Usage: render_blast4.pl <blast file> <output_file> <basename>\n";
my $output_file_path = shift or die "Usage: render_blast4.pl <blast file> <output_file> <basename>\n";
my $basename = shift or die "Usage: render_blast4.pl <blast file> <output_file> <basename>\n";

my $searchio = Bio::SearchIO->new(
    -file   => $input_file_path,
    -format => 'blastxml'
) or die "parse failed";

my $writerhtml = new Bio::SearchIO::Writer::HTMLResultWriter();
my $outhtml    = new Bio::SearchIO(
    -writer => $writerhtml,
    -file   => ">$output_file_path"
);

#Loop through all the search results
my $result = $searchio->next_result() or die "no result";
do {
    my $panel = Bio::Graphics::Panel->new(
        -length    => $result->query_length,
        -width     => 800,
        -pad_left  => 10,
        -pad_right => 10,
    );

    my $full_length = Bio::SeqFeature::Generic->new(
        -start        => 1,
        -end          => $result->query_length,
        -display_name => $result->query_name,
    );
    $panel->add_track(
        -glyph   => 'arrow',
        -fgcolor => 'wheat',
        -key     => "Darker blue = higher score",
        -bgcolor => "wheat",
        -tkcolor => "wheat",
    );
    $panel->add_track(
        $full_length,
        -glyph   => 'arrow',
        -tick    => 2,
        -fgcolor => 'black',
        -double  => 1,
        -label   => 1,

    );

    #Save all the hits in an array and find the maximum score among them
    my $maximum_score = 0;
    my @hits;
    while ( my $hit = $result->next_hit ) {
        $maximum_score = $hit->raw_score if $hit->raw_score > $maximum_score;
        push( @hits, $hit );
    }

    my $track = $panel->add_track(
        -glyph       => 'graded_segments',
        -label       => 1,
        -connector   => 'dashed',
        -bgcolor     => 'blue',
        -min_score   => 0,
        -max_score   => $maximum_score,
        -font2color  => 'red',
        -sort_order  => 'high_score',
        -description => sub {
            my $feature = shift;
            return unless $feature->has_tag('description');
            my ($description) = $feature->each_tag_value('description');
            my $score = $feature->score;
            "$description, score=$score";
        },
    );

    #Add the hits to the track
    foreach my $hit (@hits) {
        my $feature = Bio::SeqFeature::Generic->new(
            -score        => $hit->raw_score,
            -display_name => $hit->name,
            -tag          => { description => $hit->description },
        );
        while ( my $hsp = $hit->next_hsp ) {
            $feature->add_sub_SeqFeature( $hsp, 'EXPAND' );
        }
        $track->add_feature($feature);
    }
    
    #Write the graphical summary for the query to a .png file
    my $query_name = $result->query_name;
    open my $fh, ">", "$output_file_path" + "_" + "$query_name.png" or die;
    print $fh $panel->png;
    close $fh;
    
    #Add the HTML to insert the graphical summary into the results page, 
    #   along with the HTML for the image map
    my @boxes          = $panel->boxes();
    my $image_map_html = '<map name="' . $query_name . 'map' . '">';
    foreach my $box (@boxes) {
        ( my $feature, my $x1, my $y1, my $x2, my $y2, my $track ) = @{$box};
        if ( scalar( grep { $_->name eq $feature->display_name } @hits ) ) {
            my $display_name = $feature->display_name;
            print "display name = $display_name\n";
            $image_map_html .=
                '<area shape="rect" coords="'
              . "$x1,$y1,$x2,$y2"
              . '" alt="'
              . $display_name
              . '" href="#'
              . $display_name . '">' . "\n";
        }
    }
    $image_map_html .= '</map>';
    $panel->finished();    #prevents memory leaks
    my $graphical_summary_html =
        '<h3 style="text-align:center">Graphical Summary</h3>'
      . '<p style="text-align:center"><img src="'
      . "get_blast_graphical_summary&basename=$basename&image_name=$query_name"
      . '" usemap="'
      . $query_name . 'map'
      . '" /></p>';
    
    #Add the HTML for the grahpical summary and it's image map into the HTML writer
    $writerhtml->introduction(
        sub { return $image_map_html . $graphical_summary_html; } );

    #Write the HTML for this result
    $outhtml->write_report($result);
} while ( $result = $searchio->next_result() );

