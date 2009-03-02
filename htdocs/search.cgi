#!/usr/local/bin/perl

use utf8;
use strict;
use warnings;

use CGI::Carp qw(fatalsToBrowser); 
use Fatal qw(open close);
use FindBin qw($Bin);
use CGI;
use Data::Dumper;

use lib "$Bin/lib/Unicode-Japanese-0.46/lib/";
use Unicode::Japanese;
use Encode;

binmode STDIN, ":utf8";

sub index_dir($) {
    my $search_category = shift;
    $search_category =~ s/^search_menu_//;
    return $search_category;
}

our $INDEX_DIR = "index";

my $cgi = CGI->new();
my $name = $cgi->param('hero_name');
my $uj = Unicode::Japanese->new($name);
$uj->hira2kata();
my @hex = map { unpack "H*", $_ } split //, decode_utf8($uj->utf8);
my $path = sprintf "$Bin/%s/%s/%s.idx", $INDEX_DIR, index_dir $cgi->param('category'), join("/", @hex);
warn $path;
print $uj->utf8;

my @hero;
if (-f $path) {
    open my $fh, "<:utf8", $path;
    while (my $row = <$fh>) {
	chomp $row;
	push @hero, encode_utf8($row);
    }
    close $fh;
}
print "Content-Type: text/html\n\n";
print sprintf '[%s]', (join ',', map { "'$_'" } @hero );

