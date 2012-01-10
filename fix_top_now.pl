# This is still a very broken script attempting to fix toplevel Now by
# scraping the thesis from the html. Run like:
#
# cat 00N1 | perl -F fix_top_now.pl
#
# where 00N1 contains lines like:
#
# afvect01.xml:<Now nr="16" vid="65" line="299" col="9">
# algstr_1.xml:<Now nr="26" vid="68" line="564" col="9">
# ...
#
# These are created by running: 
#
# grep -B1 '<Now ' *.xml | grep -A1 'l\-$' | grep Now> 00N1
#

$told=""; $kold=0; @n=(); while (<>) { m/(.*).xml:.*line=.(\d+)/ or die;

($t,$k)=($1,$2);
if($told ne $t)
{
    if($#l > 0) { open(F1,">new/$told.miz"); print F1 (@n, @l[$kold .. $#l]); close(F1);}
    @n=(); $kold=0; $told = $t;
    open(F,"$t.miz") or die "$t"; @l=<F>; close F;
}
($l[$k-1] =~ m/^(.*)\bnow(.*)/) or die $l[$k-1];
($b,$o) = ($1,$2);
if($b =~ m/^ *([\w]+): */) {$c=$1; $bound = $k-2;}
elsif($l[$k-2] =~ m/^ *([\w]+): */) { $c=$1; $bound = $k-3;}
else { die "$t:$k:$l[$k-2]"; }

if($l[$k-1] =~ m/^ *([\w]+): *now(.*)/)
{
($c,$o)=($1,$2); $new=`grep "$c" $t.htmla1 |sed -e "s/<[/]*a[^>]*>//g;" | sed -e "s/[&]amp;/\\&/g" |html2text`;
$new =~ s/.*thesis://;
push(@n,(@l[$kold .. $bound], $c, ":", $new, "proof ", $o));
$kold = $k;
}}
open(F1,">new/$told.miz"); print F1 (@n, @l[$kold .. $#l]); close(F1);
