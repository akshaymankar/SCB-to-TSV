#!/bin/bash

[ -z "$DEBUG" ] || set -x

set -euo pipefail

pdfToTxt() {
  mkdir txt
  for f in `ls pdf | gsed -r 's|(.*).pdf|\1|'`; do
    gs -sDEVICE=txtwrite -q -o txt/$f.txt pdf/$f.pdf
  done
}

cleanupTxt() {
  rm -rf 1-nohead 2-nofoot 3-nopage 4-onefile 5-nocrap 6-noheader 7-fix-date 8-no-step-on-snek 9-separate-transactions 10-fix-line-ending 11-oneline
  rm -rf 12-no-leading-spaces 13-dates-everywhere 14-nozerocheque 15-fix-first-line 16-extract-balance 17-only-balance 18-partitions 19-whitespace
  rm -rf 20-fix-date-format
  mkdir 1-nohead 2-nofoot 3-nopage

  for f in `ls txt`     ; do gsed '1,14d' txt/$f                                                                      > 1-nohead/$f; done
  for f in `ls 1-nohead`; do gsed '/TOTAL/,$d' 1-nohead/$f                                                            > 2-nofoot/$f; done
  for f in `ls 2-nofoot`; do gsed -r '/^\s+Page.*of/d' 2-nofoot/$f                                                    > 3-nopage/$f; done
  cat 3-nopage/*                                                                                                      > 4-onefile
  gsed '/^         [^ 0-9]/d' 4-onefile                                                                               > 5-nocrap
  gsed -r '/^\s+Date/d' 5-nocrap                                                                                      > 6-noheader
  gsed -r 's|^(\s+)([0-9]{2} [A-Z][a-z]{2} [0-9]{2}) ?[0-9]{2} [A-Z][a-z]{2} [0-9]{2}|\1\2\|         |' 6-noheader    > 7-fix-date
                                                                                                                      # 8-Too lazy to change all the numbers
  gsed -r 's|(.{61}.*[0-9]\.[0-9].*)|--------\n\1|' 7-fix-date                                                        > 9-separate-transactions
  echo '--------'                                                                                                    >> 9-separate-transactions
  gsed -r 's|||g'  9-separate-transactions                                                                          > 10-fix-line-ending
  gsed -r ':loop;/---$/!{N;/--$/!b loop;};s|\n||g;s|--------||g' 10-fix-line-ending                                   > 11-oneline
  gsed -r 's/^\s+//' 11-oneline                                                                                       > 12-no-leading-spaces
  gsed -nr '/^[0-9]{2} [A-Z][a-z]{2} [0-9]{2}/!{x;G;s/\n//}
  {h;s#^([0-9]{2} [A-Z][a-z]{2} [0-9]{2}).*$#\1| #;x;p}'  12-no-leading-spaces                                        > 13-dates-everywhere
  gsed -r 's|  0  |     |' 13-dates-everywhere                                                                        > 14-nozerocheque
  perl -pe 's#\|([ ]+)(.*?)(  )#\3\2\1 #' 14-nozerocheque                                                             > 15-fix-first-line
  gsed -r 's|(.*) ([0-9]{1,3},[0-9]{3}\.[0-9]{2})(.*)|\2  \1\3|' 15-fix-first-line                                    > 16-extract-balance
  gsed -r 's|^([0-9]{1,3},[0-9]{3}\.[0-9]{2})  (.*)  (.*) \s+[0-9,]{1,6}\.[0-9]{2}|\1  \2|' 16-extract-balance        > 17-only-balance
  gsed -r 's|^([0-9]{1,3},[0-9]{3}\.[0-9]{2})  ([0-9]{2} [A-Z][a-z]{2} [0-9]{2})  (.*)|\1 ~ \2 ~ \3|' 17-only-balance > 18-partitions
  gsed -r 's| +| |g' 18-partitions                                                                                    > 19-whitespace
  cat 19-whitespace | \
    gsed -r 's|(.* ~ [0-9]{2}) Jan ([0-9]{2} ~ .*)|\1/01/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Feb ([0-9]{2} ~ .*)|\1/02/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Mar ([0-9]{2} ~ .*)|\1/03/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Apr ([0-9]{2} ~ .*)|\1/04/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) May ([0-9]{2} ~ .*)|\1/05/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Jun ([0-9]{2} ~ .*)|\1/06/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Jul ([0-9]{2} ~ .*)|\1/07/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Aug ([0-9]{2} ~ .*)|\1/08/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Sep ([0-9]{2} ~ .*)|\1/09/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Oct ([0-9]{2} ~ .*)|\1/10/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Nov ([0-9]{2} ~ .*)|\1/11/\2|' | \
    gsed -r 's|(.* ~ [0-9]{2}) Dec ([0-9]{2} ~ .*)|\1/12/\2|'                                                        > 20-fix-date-format

  rm -rf 1-nohead 2-nofoot 3-nopage 4-onefile 5-nocrap 6-noheader 7-fix-date 8-no-step-on-snek 9-separate-transactions 10-fix-line-ending 11-oneline
  rm -rf 12-no-leading-spaces 13-dates-everywhere 14-nozerocheque 15-fix-first-line 16-extract-balance 17-only-balance 18-partitions 19-whitespace
  rm -rf txt/
  mv 20-fix-date-format final
}

main() {
  pdfToTxt
  cleanupTxt
}

main
