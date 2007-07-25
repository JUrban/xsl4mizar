# transform pub.frd to XML format
use strict;
my $article;
my ($kind, $symbolnr, $leftargnr, $rest);
my ($rightsymbolnr, $rightsymbolvoc);
my ($rightargnr, $argnr);
while(<>)
{
    if (m/^#([A-Z].*)/)
    {
	$article = $1;
    }
    elsif (m/^([A-Z])([0-9]+) ([0-9]+) *(.*)/)
    {
	undef $rightsymbolnr;
	undef $rightsymbolvoc;
	undef $rightargnr;

	($kind, $symbolnr, $leftargnr, $rest) =
	    ($1,$2,$3,$4);
	print ("<Format",
	       " kind=\"", $kind,
	       "\" symbolnr=\"", $symbolnr,
               "\" aid=\"", $article,
	       "\"");
	if ($kind eq "K")
	{
	    $rest =~ m/L([0-9]+) v([A-Z0-9_]+)/ or
		die "Bad bracket functor info: $_";
	    ($rightsymbolnr, $rightsymbolvoc) = ($1,$2);
	    $argnr = $leftargnr;
	    print (
		   " argnr=\"", $argnr,
		   "\" rightsymbolnr=\"", $rightsymbolnr,
		   "\" rightsymbolvoc=\"", $rightsymbolvoc,
		   "\"");
	}
	elsif (($kind eq "G") or ($kind eq "M") or ($kind eq "J")
	       or ($kind eq "V") or ($kind eq "L") or ($kind eq "U"))
	{
	    $rest eq "" or die "Bad symbol info: $_";
	    $argnr = $leftargnr;
	    print (" argnr=\"", $argnr, "\"");
	}
	elsif (($kind eq "O") or ($kind eq "R"))
	{
	    $rest =~ m/([0-9]+)/ or 
		die "Bad symbol info: $_";
	    $rightargnr = $1;
	    $argnr = $leftargnr + $rightargnr;
	    print (" argnr=\"", $argnr, 
		   "\" leftargnr=\"",$leftargnr,
		   "\"");
	}
	else { die "Unknown symbol: $_"; }
	print ">\n";
    }
}
