#!/usr/bin/awk -f


# Vars as field number
# referred to like `$some_var'

{
    print "BEGIN {"
    for (i = 1; i <= NF; i += 1)
        print "    " $i " = " i
    print "}"
}


# Vars as functions
# referred to like `some_var()'

# {
#     for (i = 1; i <= NF; i += 1)
#         print "function " $i "() { return $" i " }"
# }


# Direct var names
# referred to like `some_var'

# {
#     print "{"
#     for (i = 1; i <= NF; i += 1)
#         print "    " $i " = $" i
#     print "}"
# }
