#!/usr/bin/perl -w

=head1 NAME

mkxmlhead.pl file ( Create a XML file describing the header of a Mizar article)

=head1 SYNOPSIS

mkxmlhead.pl abcmiz_0.miz > abcmiz_0.hdr

 Options:
   --soft,     -s

=head1 OPTIONS

=over 8

=item B<<< --soft, -s >>>

Do not complain when some of the expected header fields are missing.
Try hard to discover what is there, and display it. Used for incomplete
articles.

=back

=head1 DESCRIPTION

Create a XML file describing the header of a Mizar article.
This is later used for inserting the header into the HTML file.

NOTE: This really sucks, but I have tried and failed many many times to 
convince Andrzej that we need keywords/pragmas for this in Mizar. So 
I am making shaky assumptions about where the info is in the .miz file.
If it fails, complain loudly to Andrzej.

=head1 CONTACT

Josef Urban firstname.lastname(at)gmail.com

=head1 LICENCE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

=cut

use strict;
use Getopt::Long;
use HTML::Entities ();

my $gsoft;

Getopt::Long::Configure ("bundling");

GetOptions('soft|s'    => \$gsoft);

my ($title, $authors, $date, $copyright);
$title = "";

my $ltime = localtime;
my $addtotitle = 1;

sub PrintIt
{
    die "Something missing: $title, $authors, $date, $copyright" 
	if(!($gsoft) && (!(defined $authors) or !(defined $date) or !(defined $copyright) or (length($title)==0)));
    print '<?xml version="1.0"?>', "\n", '<Header xmlns:dc="http://purl.org/dc/elements/1.1/">', "\n";
    print ('<dc:title>', ((length($title)>0)? HTML::Entities::encode($title) : "Unknown title"), '</dc:title>', "\n");
    print ('<dc:creator>', ($authors ? HTML::Entities::encode($authors) : "Unknown authors" ), '</dc:creator>', "\n");
    print ('<dc:date>', ($date ? HTML::Entities::encode($date) : $ltime ), '</dc:date>', "\n");
    print ('<dc:rights>', ($copyright ? HTML::Entities::encode($copyright) : "Unknown" ), '</dc:rights>', "\n");
    print '</Header>', "\n";
    exit;
}

while(<>)
{
  m/^::+ *(.*)$/ or PrintIt(); ## print and exit when the initial comment ends
  my $content = $1;
  if($content =~ m/^[bB]y +(.*)/) { $authors = $1; $addtotitle = 0;}
  elsif($content =~ m/^[rR]eceived +(.*)/) { $date = $1; $addtotitle = 0;}
  elsif($content =~ m/^[cC]opyright +(.*)/) { $copyright = $1; $addtotitle = 0; }
  elsif(($addtotitle == 1) && !($content eq "")) { $title = $title . " " . $content; }
}
