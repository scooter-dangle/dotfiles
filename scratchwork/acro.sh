#!/bin/sh
# assign shells $1 to awk search variable
awk -F\	 '$1 == search { print $1 " => " $2 }' search=$1 < acronyms
