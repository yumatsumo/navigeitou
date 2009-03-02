#!/usr/local/bin/perl

use utf8;
use strict;
use warnings;

use Encode;
use File::Path qw(mkpath);
use FindBin qw($Bin);
use File::Find;
use Fatal qw(open close);
use YAML;
use Carp::Clan qw(verbose);

our $INDEX_DIR = "index";
our $MASTER_DIR = "$Bin/master/";

sub create_dir($@) {
    my $category = shift;
    my @index = @_;
    pop @index;
    my @hex = map { unpack "H*", $_ } @index;
    my $dir = sprintf "$Bin/%s/%s/%s", $INDEX_DIR, $category, join("/", @hex);
    unless (-d $dir) {
        return mkpath($dir);
    }
    return 1;
}

sub create_path($@) {
    my $category = shift;
    my @index = @_;
    create_dir $category, @index;
    my @hex = map { unpack "H*", $_ } @index;
    my $path = sprintf "$Bin/%s/%s/%s.idx", $INDEX_DIR, $category, join("/", @hex);
    return $path;
}

sub open_index_file($) {
    my $path = shift;
    if (-f $path) {
        open my $fh, ">>:utf8", $path;
        return $fh;
    }
    open my $fh, ">:utf8", $path;
    return $fh;
}

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+|\s+$//g;
    return $string;
}

sub process() {
    find(sub {
	my $fname = $File::Find::name;
	unless (-f $fname) {
	    return;
	}
	unless ($fname =~ /\.txt$/) {
	    return;
	}
	my ($category) = ($fname =~ /(\w+)\.txt/);
	open my $fh, "<:utf8", "$fname";
	my @row = <$fh>;
	close $fh;
	for my $row (sort @row) {
	    chomp $row;
	    my ($kana, $kanji) = map { trim $_ } split /\s+/, $row;
	    my @kana = split //, $kana;
	    my @index = ();
	    for (my $i = 0; $i < @kana; $i++) {
		push @index, [@kana[0 .. $i]];
	    }
	    for my $i (@index) {
		my $path = create_path $category, @$i;
		my $index_fh = open_index_file $path;
		print $index_fh "$kanji\n";
		close $index_fh;
	    }
	}
    }, "$Bin/master/");
}

process;
