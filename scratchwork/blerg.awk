#!/usr/bin/awk -f

BEGIN { print "Here we go! From " high " to " low "!" }

NF == 3 && $3 >= low {
  print $3 * high "\t" $2
}

END { print "All done!" }
