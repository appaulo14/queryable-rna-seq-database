#!/usr/bin/perl
use strict;
use warnings;
use autodie qw(:all);

use Bio::Tools::Run::StandAloneBlastPlus;

if (scalar(@ARGV) != 2){
  die "USAGE: query_sequence_file blast_output_file";
}

my $fac = Bio::Tools::Run::StandAloneBlastPlus->new(
    -db_name => 'nr',
    -remote  => 1
);

my $query_sequence_file = $ARGV[0];
my $blast_output_file   = $ARGV[1];

#Blast
my $result = $fac->blastx(
    -query     => $query_sequence_file,
    -outfile   => $blast_output_file,
    -outformat => 5,
    -method_args => ['evalue' => 1e-6,]);
$fac->cleanup();


