;;; xsltxt.el --- Xsltxt major mode

;; $Revision: 1.1 $

;; Copyright (C) 2005  Josef Urban (urban AT kti mff cuni cz)

;; Author: Josef Urban
;; Keywords: xsltxt

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Simple syntax-highliting mode for the XSLTXT compact
;; syntax for XSL stylesheets - see https://xsltxt.dev.java.net/ .
;; XSL is produced by the follwing compile command:
;; java -jar xsltxt.jar toXSL foo.xsltxt > foo.xsl

;;; Code:

(defvar xsltxt-mode-map
  (let ((map (make-sparse-keymap)))
;;    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for `xsltxt-mode'.")

(defvar xsltxt-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/ ". 12" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?\' "\""  st)
    st)
  "Syntax table for `xsltxt-mode'.")

(defvar xsltxt-font-lock-keywords
  (list
;;   (cons "\\<\\(tpl\\)\\>" ; \\(\\s[^{]*\\)\\)\\>"
;;	 font-lock-function-name-face)
   '("\\btpl *\\([^{(]*\\)" (1 font-lock-function-name-face))
   (cons (concat "\\<\\(" (regexp-opt '( "apply" "apply-imports" "choose" 
       "copy" "copy-of" "else"
       "encoding" "exclude-result-prefixes" "extension-element-prefixes" 
       "fallback" "for-each" "format" "from" "grouping-separator" 
       "grouping-size" "id" "if" "import" "include" "indent" "infinity" 
       "key" "lang" "letter-value" "level" "media-type" "method" "mode" 
       "name" "namespace" "namespace-alias" "number" "omit-xml-declaration" 
       "order" "otherwise" "output" "pattern-separator" "preserve-space" 
       "priority" "sort" "standalone" "strip-space" "stylesheet"
       "terminate" "tpl" "use-attribute-set" "use-attribute-sets" "value" 
       "version" "when")) "\\)\\>")  font-lock-keyword-face))
  "Keyword highlighting specification for `xsltxt-mode'.")

;; (defvar xsltxt-imenu-generic-expression
;;  ...)

;; (defvar xsltxt-outline-regexp
;;   ...)

;;;###autoload
(define-derived-mode xsltxt-mode fundamental-mode "Xsltxt"
  "A major mode for editing Xsltxt files."
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-start-skip) "//+\\s-*")
  (set (make-local-variable 'font-lock-defaults)
       '(xsltxt-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'xsltxt-indent-line)
;;  (set (make-local-variable 'imenu-generic-expression)
;;       xsltxt-imenu-generic-expression)
;;  (set (make-local-variable 'outline-regexp) xsltxt-outline-regexp)
  )

;;; Indentation

(defun xsltxt-indent-line ()
  "Indent current line of Xsltxt code."
  (interactive)
  (indent-relative))


(provide 'xsltxt)
;;; xsltxt.el ends here
