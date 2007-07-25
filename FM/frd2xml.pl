# transform pub.frd to XML format
use strict;
my $article;
my ($kind, $symbolnr, $leftargnr, $rest);
my ($rightsymbolnr, $rightsymbolvoc);
my ($rightargnr, $argnr);
my ($symbolkind, $symbol, $rightsymbol);
my ($texmode, $bracketability, $defstyle, $opkind, $arg1, $arg2, $priority, $bracketdisab, $pattern);
my (@forsing, @contexts, @bracketdisab, @patt_str_ints);
undef $kind;  # defined by the first format line
my $line = 0; # state variable

## quote a string for xml
sub xml_quote
{
    my ($s) = @_;
    my @ch = split( //, $s);
    my $res = "";
    my $c;

    foreach $c (@ch)
    {
	if($c eq '"') { $res = $res . '&quot;'; }
	elsif($c eq '&')  { $res = $res . '&amp;'; }
	elsif($c eq '<')  { $res = $res . '&lt;'; }
	elsif($c eq '>')  { $res = $res . '&gt;'; }
	elsif(ord($c) > 127) { $res = $res . '&#' . ord($c) . ';'; }
	else { $res = $res . $c; }

    }
    return $res;
}

## print the translation patern as a series of strings and integers
sub transl_pattern
{
    my ($pattstrints) = @_;
    my $piece;

    print "<FMTranslPattern>";
    foreach $piece (@$pattstrints)
    {
	if ($piece =~ m/#(\d)/)
	{
	    print ("<Int x=\"", $1, "\"/>");
	}
	else
	{
	    print ("<Str s=\"", xml_quote($piece), "\"/>");
	}
    }
    print "</FMTranslPattern>";
}

while(<>)
{
    # the article header
    if (m/^#([A-Z].*)/)
    {
	$article = $1;
    }
    # the first format line, $kind has to be undefined here
    elsif (m/^([A-Z])([0-9]+) ([0-9]+) *(.*)/)
    {
	$line = 1;

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
    # the second (and possibly third) format line, $kind has to be defined here
    elsif ($line == 1)
    {
	$line = 2;

	m/^([A-Z])(.*)/ or die "Bad second format line: $_";
	($symbolkind, $symbol) = ($1, $2);

	# optional third line for brackets
	if ($kind eq "K")
	{
	    $_ = <>;
	    m/^L(.*)/ or die "Bad third format line: $_";
	    $rightsymbol = $1;
	}
    }
    # the third (first control header) line, most info is here
    elsif ($line == 2)
    {
	$line = 3;
	chop;
	my @chars = split(//, $_);

	# functors
	if (($kind eq "O") or ($kind eq "U")
	    or ($kind eq "G")  or ($kind eq "K")
	    or ($kind eq "J"))
	{
	    undef $arg1;
	    undef $arg2;
	    undef @forsing;
	    undef $priority;
	    undef @contexts;
	    undef @bracketdisab;
	    undef $pattern;
	    undef @patt_str_ints;
	    my ($opchar, $nrchar, $forschar, $priochar, $contextchar, $disabchar);

	    ($texmode, $bracketability, $defstyle) =
		($chars[0], $chars[1], $chars[2]);

	    # set $defstyle = "l" if normal 
	    if ($defstyle =~ m/[snp]/) { $opchar = 3; }
	    else {$defstyle = "l"; $opchar = 2; }

	    # set $opkind = "o" if other
	    $opkind = $chars[$opchar];
	    if ($opkind =~ m/[lkmrqwtbixyc]/) { $nrchar = $opchar + 1; }
	    else {$opkind= "o"; $nrchar = $opchar; }

	    # arguments given, they can be one or two digits, they can be also undefined
	    if ($chars[$nrchar] eq "(")
	    {
		$arg1 = $chars[$nrchar + 1];
		if ($chars[$nrchar + 2] eq ",")
		{
		    $arg2 = $chars[$nrchar + 3];
		    $forschar = $nrchar + 5;
		}
		else { $forschar = $nrchar + 3; }

		($chars[$forschar - 1] eq ")") or die "Bad opkind args: $_";
	    }
	    else { $forschar = $nrchar; }

	    # parse the forsing characters
	    if ($chars[$forschar] eq "{")
	    {
		$forschar++;
		while ($chars[$forschar] =~ m/[lkmrqwtbixyc]/)
		{
		    push( @forsing, $chars[$forschar] );
		    $forschar++;
		}
		($chars[$forschar] eq "}") or die "Bad forsing args: $_";
		$forschar++;
	    }

	    $priochar = $forschar;
	    # parse priority
	    if ($chars[$priochar] eq "@")
	    {
		$priochar++;
		$priority = $chars[$priochar];
		($priority =~ m/[0-9wams]/) or die "Bad priority: $_";
		$priochar++;
	    }

	    # parse additional contexts
	    $contextchar = $priochar;
	    while ($chars[$contextchar] eq "/")
	    {
		my %ch = ();
		$ch{contextnr} = $chars[++$contextchar];
		$ch{contextop} = $chars[++$contextchar];
		my $cntpriochar;

		($ch{contextnr} =~ m/[0-9]/) or die "Bad context: $_";
		if (!($ch{contextop} =~ m/[lkmrqwtbixyc]/))
		{
		    $ch{contextop} = "o";
		    $contextchar--;
		}

		# arguments given, they can be one or two digits, they can be also undefined
		if ($chars[$contextchar] eq "(")
		{
		    $ch{contextarg1} = $chars[$contextchar + 1];
		    if ($chars[$contextchar + 2] eq ",")
		    {
			$ch{contextarg2} = $chars[$contextchar + 3];
			$cntpriochar = $contextchar + 5;
		    } 
		    else { $cntpriochar = $contextchar + 3;}

		    ($chars[$cntpriochar - 1] eq ")") or die "Bad opkind args: $_";
		}
		else { $cntpriochar = $contextchar + 1; }

		# parse priority
		if ($chars[$cntpriochar] eq "@")
		{
		    $cntpriochar++;
		    $ch{priority} = $chars[$cntpriochar];
		    ($ch{priority} =~ m/[0-9wams]/) or die "Bad priority: $_";
		    $cntpriochar++;
		}
		$contextchar = $cntpriochar;
		push(@contexts, \%ch);
	    }

	    # parse List-of-bracket-disabled-arguments
	    $disabchar = $contextchar;
	    while ($chars[$disabchar] eq "#")
	    {
		push( @bracketdisab, $chars[++$disabchar]);
		$disabchar++;
	    }
	    ($chars[$disabchar] eq ";") or die "Bad control header line: $_:$disabchar:$chars[$disabchar]";

	    $pattern = substr( $_, $disabchar + 1);
	    # this (having brackets around #\d) causes the #\d strings to be included
	    # in the result array
	    @patt_str_ints = split( /(#\d)/, $pattern);
	    print ("texmode=\"", $texmode,
		   "\" bracketability=\"", $bracketability,
		   "\" defstyle=\"", $defstyle,
		   "\" opkind=\"", $opkind);
	    if (defined $arg1) { print ("\" arg1=\"", $arg1); }
	    if (defined $arg2) { print ("\" arg2=\"", $arg2); }
	    if (defined @forsing) { print ("\" forsing=\"", @forsing); }
	    if (defined $priority) { print ("\" priority=\"", $priority); }
	    if (defined @contexts) { print ("\" contexts=\"", @contexts); }
	    if (defined @bracketdisab) { print ("\" bracketdisab=\"", @bracketdisab); }
	    if (defined @patt_str_ints) { print ("\" patt_str_ints=\"", @patt_str_ints); }
	    transl_pattern( \@patt_str_ints);
	    print "\"\n";
	}
	elsif ($kind eq "R")
	{
	    
	}

    }

}
