#!/usr/bin/perl -w

=head1 NAME

MizComments.pl file ( create items from .miz and .xml files)

=head1 SYNOPSIS

MizComments.pl a.miz > a.cmt

=cut

use strict;
use HTML::Entities ();

my $wp = 'http://en.wikipedia.org/wiki/';

my @lines=();

print  ('<?xml version="1.0"?>', "\n", "<Comments>\n");

my $incomment = 0;
my @curr_comments = ();

my $begcomment = 0;
my $endcomment = 0;

while(<>) { s/\r\n/\n/g; push(@lines, $_); }

foreach my $i (0 .. $#lines)
{ 
    $_ = $lines[$i];
    if(m/^( *::+.*)/) # inside a comment
    {
	if($incomment != 1) # starting a new comment
	{
	    $begcomment = $i+1;
	    @curr_comments = ();
	    $incomment = 1;
	}

	$endcomment = $i+1;
	
	my $txt = $1;
	if($txt =~ m/^ *::+\$N[\t ]+(.+?) *$/) # get the name
	{
	    my ($thname,$thname1) = ($1,$1);
	    my $thname0 = HTML::Entities::encode($thname);
	    $thname1 =~ s/ +/_/g;
	    my $thname2 = HTML::Entities::encode($thname1);
	    $txt = '<CmtLink><a href="' . $wp . $thname2
		. '" title="See Wikipedia entry for ' . $thname0 . '">' .
		$thname0 . '</a></CmtLink>';
	}
	else { $txt = '<CmtLine>' . HTML::Entities::encode($txt) . '</CmtLine>';}

	push(@curr_comments, $txt . "  \n");

    }
    elsif(($incomment == 1) && (m/^ *$/)) # continuing a comment by empty line
    {
	push(@curr_comments, "  \n");
	$endcomment = $i+1;
    }
    else  # not inside a comment
    {
	if($incomment == 1) # print the previous comment if any
	{

	    print  "<Comment line=\"$begcomment\" endline=\"$endcomment\">";
	    print   join('', @curr_comments);
	    print  "</Comment>\n";

	    $incomment = 0;
	}
    }
};

# print the last comment if the article ends in a comment
if($incomment == 1)
{
    print  "<Comment line=\"$begcomment\" endline=\"$endcomment\">";
    print  join('', @curr_comments);
    print  "</Comment>\n";
}


print  ('</Comments>', "\n");



