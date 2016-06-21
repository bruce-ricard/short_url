let main () =
  let open Short.TestShortener in
  let l1 = "www.google.com"
  and l2 = "www.yahoo.com" in
  let _ = shorten l1
  and _ = shorten l2 in
  print_data ()

let () = main ()
