#!/usr/bin/perl

# put each exported Mizar item into a separate file - this
# is done to overcome the current eXist indexing bug described 
# at http://wiki.exist-db.org/space/Roadmap

# these XML modules are now used for processing XML-format of 
# the Mizar internal database, they should be available for any
# major Perl distribution
use XML::XQL;
use XML::XQL::DOM;
use strict;

# xquery for exported elements
my @exported = ('RCluster','CCluster','FCluster','Constructor',
		'Definiens','Pattern','Scheme','Theorem');

ONE: foreach my $f1 (@ARGV)
{
    next ONE unless (-e $f1);
    print "$f1\n";


    my $parser = new XML::DOM::Parser;
    my $doc = $parser->parsefile ($f1);
    my $i = 0;

    foreach my $exp_item (@exported)
    {
	my @result = $doc->xql ('/*/'.$exp_item);
	foreach my $node (@result) {
	    $node->printToFile ($f1."__".++$i);
	}
    }
    $doc->dispose(); 
}
