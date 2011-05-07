#!/usr/bin/perl
use warnings;
use strict;

use WWW::Wikipedia;
use Data::Dumper;

my $wiki = WWW::Wikipedia->new();

my $result = $wiki->search( 'perl' );

#Deal with redirects
if ($result -> text() =~ m/#redirect/){
	my $newquery = $result-> text();
	$newquery =~ s/#redirect//;
	print "N=$newquery\n";
	$result = $wiki->search($newquery);
}

#if ( $result -> text() ) {
#	print $result->text();

#}

print Dumper($result->text());
#print join ( "\n" , $result -> related() );
