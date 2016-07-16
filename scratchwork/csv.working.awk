#!/usr/bin/gawk -f

# Start of function section

# Allows fields to have embedded FS characters
# From https://www.gnu.org/software/gawk/manual/html_node/Splitting-By-Content.html
function fpat(FS_INPUT, QUOTE_CHAR_INPUT) {
    if (FS_INPUT == "") FS_INPUT = FS
    if (QUOTE_CHAR_INPUT == "") QUOTE_CHAR_INPUT = QUOTE_CHAR

    # return "([^" FS_INPUT QUOTE_CHAR_INPUT RS "]*)|" \
    return "([^" FS_INPUT QUOTE_CHAR_INPUT "]*)|" \
         "(" QUOTE_CHAR_INPUT \
         "([^" QUOTE_CHAR_INPUT "]|" QUOTE_CHAR_INPUT QUOTE_CHAR_INPUT ")*" \
         QUOTE_CHAR_INPUT ")"
}

function unescape(ENTRY, quote_char, entry_length) {
    if (quote_char == "") quote_char = QUOTE_CHAR

    if (index(ENTRY, quote_char) == 0) return ENTRY

    if((! match(ENTRY, "^" quote_char)) || (! match(ENTRY, quote_char "$"))) {
        if(match(ENTRY, quote_char)) {
            print "ERROR: QUOTE_CHAR `" QUOTE_CHAR "' cannot appear in un-quoted field: `" ENTRY "' (line " NR ")" > "/dev/stderr"
            exit 1
        } else {
            return ENTRY
        }
    }

    entry_length = length(ENTRY)
    ENTRY = substr(ENTRY, 2, entry_length - 2)
    gsub(QUOTE_CHAR QUOTE_CHAR, QUOTE_CHAR, ENTRY)
    return ENTRY
}

function escape(ENTRY, fs, quote_char) {
    if (fs == "") fs = FS
    if (quote_char == "") quote_char = QUOTE_CHAR

    if (!index(ENTRY, quote_char) && !index(ENTRY, fs)) return ENTRY

    gsub(QUOTE_CHAR, QUOTE_CHAR QUOTE_CHAR, ENTRY)
    return QUOTE_CHAR ENTRY QUOTE_CHAR
}

function collect_rows()    { do_collect_rows = 1 }
function collect_columns() { do_collect_columns = 1 }

function cell(COL_NAME, ROW_NUM, temp_ary) {
    if (ROW_NUM == "") ROW_NUM = 0
    if (ROW_NUM <= 0) ROW_NUM += NR

    if (ROW_NUM == NR) return $csv[COL_NAME]

    if ((do_collect_rows != 1) && (do_collect_columns != 1)) {
        print "ERROR: cell called for non-current row without collect_rows or collect_columns being called" > "/dev/stderr"
        exit 1
    }

    if (do_collect_rows == 1) {
        split(rows[ROW_NUM], temp_ary)
        return temp_ary[csv[COL_NAME]]
    } else {
        split(columns[COL_NAME], temp_ary)
        return temp_ary[ROW_NUM]
    }
}

function cells_joined(JOINED_CELL_NAMES, ROW_NUM, FS_INPUT, QUOTE_CHAR_INPUT, out, temp_ary) {
    if (ROW_NUM == "") ROW_NUM = 0
    if (ROW_NUM <= 0) ROW_NUM += NR

    fpattern = (FS_INPUT == "" && QUOTE_CHAR_INPUT == "") ?
        FPAT : fpat(FS_INPUT, QUOTE_CHAR)

    if (FS_INPUT == "") FS_INPUT = FS

    patsplit(JOINED_CELL_NAMES, temp_ary, fpattern)
    separator = ""
    for (i in temp_ary) {
        out = out separator escape(cell(unescape(temp_ary[i], QUOTE_CHAR_INPUT), ROW_NUM), FS_INPUT, QUOTE_CHAR_INPUT)
        separator = FS_INPUT
    }
    return out
}

function load_cells(LOAD_CELLS, JOINED_CELL_NAMES, ROW_NUM, temp_ary, column, out) {
    if (ROW_NUM == "") ROW_NUM = 0
    if (ROW_NUM <= 0) ROW_NUM += NR

    out = patsplit(JOINED_CELL_NAMES, temp_ary)
    delete OUT_ARRAY
    for (i in temp_ary) {
        column = unescape(temp_ary[i])
        LOAD_CELLS[column] = cell(column, ROW_NUM)
    }
    return out
}

function load_row (LOAD_ROW, ROW_NUM, temp_row) {
    if (ROW_NUM == "") ROW_NUM = 0
    if (ROW_NUM <= 0) ROW_NUM += NR

    if (ROW_NUM == NR) {
        delete LOAD_ROW
        for (field_name in csv) LOAD_ROW[field_name] = $csv[field_name]
        return
    }

    if (do_collect_rows != 1) {
        print "ERROR: load_row called for non-current row without collect_rows being called" > "/dev/stderr"
        exit 1
    }

    delete LOAD_ROW
    split(rows[ROW_NUM], temp_row)
    for (field_name in csv) LOAD_ROW[field_name] = temp_row[csv[field_name]]
    delete temp_row
}

function load_column (LOAD_COLUMN, COL_NAME) {
    if (do_collect_columns != 1) {
        print "ERROR: load_column called without collect_columns being called" > "/dev/stderr"
        exit 1
    }

    delete LOAD_COLUMN
    split(columns[COL_NAME], LOAD_COLUMN)
}
# End of function section

BEGIN {
    QUOTE_CHAR = ENVIRON["CSV_QUOTE_CHAR"] == "" ?
        "\"" : ENVIRON["CSV_QUOTE_CHAR"]
    FPAT = fpat()

    csv[""] = 0

    getline
    patsplit($0, headers)
    num_headers = NF
    NR = 0
    for ( i = 1; i <= NF; i++ ) {
        if (index($i, QUOTE_CHAR)) $i = unescape($i)
        if ($i == "") {
            print "ERROR: blank field name at position " i " in header" > "/dev/stderr"
            exit 1
        }
        if ($i in csv) {
            print "ERROR: duplicate field name: `" $i "'" > "/dev/stderr"
            exit 1
        }
        field_names[i] = $i
        csv[$i] = i
    }

    # validation_regex = "^" FPAT "(" FS FPAT "){" num_headers - 1 "}$"
    validation_regex = "^" FPAT "(" FS FPAT "){" num_headers - 1 "}$"

    do_collect_columns = 0
    do_collect_rows = 0
}

# $0 !~ validation_regex {
#     if (ENVIRON["CSV_STRICT"] != "") {
#         print "ERROR: Invalid line (line " NF ")" > "/dev/stderr"
#         exit 1
#     } else {
#         print "WARN: Invalid line (line " NF ")" > "/dev/stderr"
#     }
# }

QUOTE_CHAR {
#    if (support_newline == 1) {
#        print "NF: " NF
#        num_seps = NF - 1
#        while (NF < num_headers || num_seps < num_headers - 1 || !(match($0, "^" FPAT "(" FS FPAT "){" num_headers - 1 "}$"))) {
#            #    while (NF < num_headers || !(match($0, "^" FPAT "(" FS FPAT ")+$"))) {
#            #    while (NF < num_headers || (index($NF, QUOTE_CHAR) && !match($NF, "^" FPAT "$"))) {
#            #    while (NF < num_headers) {
#            getline tmp_line
#            NR--
#            $0 = $0 "\n" tmp_line
#            NF = patsplit($0, tmp_ary, FPAT, seps)
#            num_seps = 0
#            for (sep in seps) {
#                if (sep == FS) num_seps += 1
#            }
#            print "num_seps: " num_seps
#            print "NF: " NF
#            has_tmp_ary = 1
#        }
#        if (has_tmp_ary == 1) {
#            j = 0
#            print "NF: " NF
#            for (i = 1; i <= NF; i++) {
#                j++
#                $j = tmp_ary[i]
#                # while ((i < NF && seps[i] != FS) || !match($j, "^" FPAT "$")) {
#                while ((i < NF && seps[i] != FS) || !match($j, "^" FPAT "$")) {
#                    i++
#                    $j = $j seps[i - 1] tmp_ary[i]
#                    print "partial field: " $j
#                }
#                print "field: " $j
#            }
#            NF = j
#            print "j: " j
#        }
#        has_tmp_ary = ""
#        tmp_line = ""
#        delete tmp_ary
#        delete seps
#        num_seps = ""
#    }

    for ( i = 1; i <= NF; i++ ) {
        if (index($i, QUOTE_CHAR)) $i = unescape($i)
    }
}

# do_collect_rows == 1 { rows[NR] = $0 }

# do_collect_columns == 1 {
#     __column_separator = NR > 1 ?
#       FS : ""
#     for (field_name in csv) {
#         if (field_name != "")
#             columns[field_name] = columns[field_name] __column_separator $csv[field_name]
#     }
#     __column_separator = 0
# }
