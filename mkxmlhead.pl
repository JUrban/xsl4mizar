#!/usr/bin/perl -w

## Create a XML file describing the header of a Mizar article.
## This is later used for inserting the header into the HTML file.

## SYNOPSIS:
## mkxmlhead.pl abcmiz_0.miz > abcmiz_0.hdr

## ###NOTE: This really sucks, but I have tried and failed many many times to 
##      convince Andrzej that we need keywords/pragmas for this in Mizar. So 
##      I am making shaky assumptions about where the info is in the .miz file.
##      If it fails, complain loudly to Andrzej.

use strict;

my ($title, $authors, $date, $copyright);
$title = "";

sub PrintIt
{
    die "Something missing: $title, $authors, $date, $copyright" 
	if (!(defined $authors) or !(defined $date) or !(defined $copyright));
    print '<?xml version="1.0"?>', "\n", '<Header xmlns:dc="http://purl.org/dc/elements/1.1/">', "\n";
    print '<dc:title>', $title, '</dc:title>', "\n";
    print '<dc:creator>', $authors, '</dc:creator>', "\n";
    print '<dc:date>', $date, '</dc:date>', "\n";
    print '<dc:rights>', $copyright, '</dc:rights>', "\n";
    print '</Header>', "\n";
    exit;
}

while(<>)
{
  m/^::+ *(.*)$/ or PrintIt(); ## print and exit when the initial comment ends
  my $content = $1;
  if($content =~ m/^[bB]y +(.*)/) { $authors = $1; }
  elsif($content =~ m/^[rR]eceived +(.*)/) { $date = $1; }
  elsif($content =~ m/^[cC]opyright +(.*)/) { $copyright = $1; }
  elsif(!($content eq "")) { $title = $title . $content; }
}
