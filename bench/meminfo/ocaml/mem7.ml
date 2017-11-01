open Hashtbl;;

let nod numbers =
  let min_number = List.fold_left min (List.hd numbers) (List.tl numbers) in
  let rec find_nod min_number =
    match List.filter (fun x -> x != 0) (List.map (fun x -> x mod min_number) numbers) with
    | [] -> min_number
    | _ -> find_nod (pred min_number) in
  find_nod  min_number;;

let print_meminfo meminfo =
  let mem_total = float_of_int (find meminfo "MemTotal")
  and mem_free = float_of_int (find meminfo "MemFree")
  and buffers = float_of_int (find meminfo "Buffers") in
  let free_ram = mem_total -. mem_free +. buffers in
  let percent_free = 100. *. free_ram /. mem_total in
  Printf.printf "RAM %.2f %.2fmb\n" percent_free (free_ram /. 1024.);;
  

let not_ready meminfo =
  let ready = find meminfo "Ready" in
  ready != 3;;

let analize line meminfo =
  let r = Str.regexp "[: ]+" in
  let data = Str.split r line in
  let name = List.hd data in
  let value = int_of_string (List.hd (List.tl data)) in
  if mem meminfo name then
    begin
      add meminfo name value;
      add meminfo "Ready" (1 + find meminfo "Ready")
    end
  ;;

let read_file stream meminfo =
  while not_ready meminfo do
    let line = input_line stream in
    analize line meminfo
  done;
  meminfo;;

let mk_meminfo () =
  let meminfo = create 4 in
  add meminfo "MemTotal" 0;
  add meminfo "MemFree" 0;
  add meminfo "Buffers" 0;
  add meminfo "Ready" 0;
  meminfo;;
 
let test filename =
  let meminfo = mk_meminfo () in
  let stream = open_in filename in
  print_meminfo (read_file stream meminfo);
  close_in stream;;

let main num =
  let filename = "/proc/meminfo" in
  for i = 0 to num - 1 do
    test filename
  done;;

let () = main (int_of_string Sys.argv.(1));;
