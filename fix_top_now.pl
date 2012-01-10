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

$oldart=""; $oldlinenr=0; @l = @newlines=(); 
while (<>)
{

  m/(.*).xml:.*line=.(\d+)/ or die;
  ($article,$linenr)=($1,$2);

  # read the new article, finish the old if exists
  if($oldart ne $article)
  {
      if($#l > 0) { open(F1,">new2/$oldart.miz"); print F1 (@newlines, @l[$oldlinenr .. $#l]); close(F1);}
      @newlines=(); $oldlinenr=0; $oldart = $article;
      open(F,"$article.miz") or die "$article"; @l=<F>; close F;
  }

  ($l[$linenr-1] =~ m/^(.*)\bnow(.*)/) or die $l[$linenr-1];
  my ($before,$rest) = ($1,$2);

  if($before =~ m/^ *([\w]+): */) {$label=$1; $bound = $linenr-2;}
  elsif($l[$linenr-2] =~ m/^ *([\w]+): */) { $label=$1; $bound = $linenr-3;}
  else { die "$article:$linenr:$l[$linenr-2]"; }
  my $new = `grep -m1 "$label\\b" $article.htmla1 |sed -e "s/<[/]*a[^>]*>//g;" | sed -e "s/[&]amp;/\\&/g" |html2text`;
  $new =~ s/.*thesis://;
  push(@newlines,(@l[$oldlinenr .. $bound], $label, ":", $new, "proof ", $rest));
  $oldlinenr = $linenr;
}

open(F1,">new2/$oldart.miz"); print F1 (@newlines, @l[$oldlinenr .. $#l]); close(F1);
