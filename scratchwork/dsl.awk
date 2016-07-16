#!/usr/bin/env gawk -f

BEGIN {
  in_definitions = 1
}

in_definitions == 1 && /^@set\>/ {
  var = $2
  gsub(/^@set +\w+ +/, "")
  mappings[var] = $0
  next
}

in_definitions == 0 && /@set\>/ {
  print "WARN (line " NR "): Lines can't start with @set beyond definition section. Ignoring definition: @" $2 > "/dev/stderr"
  next
}

in_definitions == 1 { in_definitions = 0 }

/@\w+\>/ {
  # Boring version
  # for ( variable in mappings )
  #   gsub("@" variable "\\>", mappings[variable])

  while ( match($0, /@\w+\>/) ) {
    var = substr($0, RSTART + 1, RLENGTH - 1)
    if (! mappings[var]) {
      print "ERR (line " NR "): Undefined variable: @" var > "/dev/stderr"
      exit
    }
    gsub("@" var "\\>", mappings[var])
  }

  print $0
  next
}

{ print $0 }
