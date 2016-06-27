module type KEY_VALUE_STORE =
  sig
    type t
    type key = ShortUrl of string
    type value = LongUrl of string
    val fetch_store : unit -> t
    val put : t -> key -> value -> unit
    val get : t -> key -> value
    val print : t -> unit
  end


module type UNIQUE_ID_GENERATOR =
  sig
    type t
    val fetch : unit -> t
    val get : t -> string
  end

module UrlShortener
         (KeyValueStore : KEY_VALUE_STORE)
         (UniqueIDGenerator : UNIQUE_ID_GENERATOR) =
  struct

    let short_server = "http://localhost/"
    let key_value_store = KeyValueStore.fetch_store ()
    let id_generator = UniqueIDGenerator.fetch ()

    let make_short_url id =
      short_server ^ id

    let shorten_and_store_url long_url =
      let new_short_id = UniqueIDGenerator.get id_generator in
      let new_short_url = make_short_url new_short_id in
      let open KeyValueStore in
      KeyValueStore.put key_value_store (ShortUrl new_short_url) (LongUrl long_url);
      new_short_url

    let shorten = shorten_and_store_url

    let print_data () = KeyValueStore.print key_value_store
  end

module TestStore : KEY_VALUE_STORE =
  struct
    type key = ShortUrl of string
    type value = LongUrl of string
    type t = (key, value) Hashtbl.t

    let fetch_store () = Hashtbl.create 100
    let put = Hashtbl.add
    let get = Hashtbl.find
    let print t = Hashtbl.iter (fun (ShortUrl s) (LongUrl l) -> print_endline (s ^ " shortens " ^ l)) t
  end

module TestGenerator : UNIQUE_ID_GENERATOR =
  struct
    type t = int ref
    let fetch () = ref 0
    let get r = incr r; string_of_int (!r)
  end

module TestShortener = UrlShortener(TestStore)(TestGenerator)


let main () =
  let open TestShortener in
  let l1 = "www.google.com"
  and l2 = "www.yahoo.com" in
  let _ = shorten l1
  and _ = shorten l2 in
  print_data ()

let () = main ()
