#!/usr/bin/awk -f

BEGIN {
    spinner_chars[1] = "/"
    spinner_chars[2] = "-"
    spinner_chars[3] = "\\"
    spinner_chars[4] = "|"
    spinner_state = 0
}

function spinner() {
    printf("\b" spinner_chars[spinner_state / 100000])
    printf(spinner_chars[int(spinner_state / 1000) + 1] "\b")
    if (spinner_state % 499 == 0)
        printf(spinner_chars[int(spinner_state / 1000) + 1] "\b")
    spinner_state = (spinner_state + 1) % 3999
}
