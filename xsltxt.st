/**
 * Name: xsltxt
 * Description: XSLTXT language
 * Author: Josef Urban <urban@kti.ms.mff.cuni.cz>
 */


/* keywords:
(make-regexp  '("apply" "apply-imports" "choose" 
       "copy" "copy-of" "else"
       "encoding" "exclude-result-prefixes" "extension-element-prefixes" 
       "fallback" "for-each" "format" "from" "grouping-separator" 
       "grouping-size" "id" "if" "import" "include" "indent" "infinity" 
       "key" "lang" "letter-value" "level" "media-type" "method" "mode" 
       "name" "namespace" "namespace-alias" "number" "omit-xml-declaration" 
       "order" "otherwise" "output" "pattern-separator" "preserve-space" 
       "priority" "sort" "standalone" "strip-space" "stylesheet"
       "terminate" "tpl" "use-attribute-set" "use-attribute-sets" "value" 
       "version" "when"))
*/

xsltxt_keyword_re=
/\b(apply(|-imports)|c(hoose|opy(|-of))\
|e(lse|ncoding|x(clude-result-prefixes|tension-element-prefixes))\
|f(allback|or(-each|mat)|rom)|grouping-s(eparator|ize)\
|i([df]|mport|n(clude|dent|finity))|key|l(ang|e(tter-value|vel))\
|m(e(dia-type|thod)|ode)|n(ame(|space(|-alias))|umber)\
|o(mit-xml-declaration|rder|therwise|utput)|p(attern-separator\
|r(eserve-space|iority))|s(ort|t(andalone|rip-space|ylesheet))\
|t(erminate|pl)|use-attribute-sets?|v(alue|ersion)|when)\b/;

state xsltxt extends Highlight
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /[\/][\/]/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  xsltxt_keyword_re {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

/* String constants. */
   /\"[^\"]*\"/ {
     string_face (true);
     language_print ($0);
     string_face (false);
   }

/* String constants. */
   /'[^']*'/ {
     string_face (true);
     language_print ($0);
     string_face (false);
   }


  /\b(tpl *)([^{(]*)/ {
    keyword_face (true);
    language_print ($1);
    keyword_face (false);
    function_name_face (true);
    language_print ($2);
    function_name_face (false);
  }


  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

