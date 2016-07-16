#!/usr/bin/awk -f

{
    print "{"
    for (i = 1; i <= NF; i += 1)
        print "    " $i " = $" i
    print "}"
}
