NR > 250 { exit }

{ prim_id = cell("prim_id") }

prim_ids[prim_id] != 1 {
  total += 1
  prim_ids[prim_id] = 1
}

END { print total }
