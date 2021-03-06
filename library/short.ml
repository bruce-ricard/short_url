type url = string
type long_url = LongUrl of url
type short_url = ShortUrl of url
type unique_url_id = ID of string

module type KEY_VALUE_STORE =
  sig
    type t
    type key = unique_url_id
    type value = long_url
    val fetch_store : unit -> t
    val put : t -> key -> value -> unit
    val get : t -> key -> value option
    val print : t -> unit
  end


module type UNIQUE_ID_GENERATOR =
  sig
    type t
    val fetch : unit -> t
    val get : t -> unique_url_id
  end

module UrlShortener
         (KeyValueStore : KEY_VALUE_STORE)
         (UniqueIDGenerator : UNIQUE_ID_GENERATOR) =
  struct

    let short_server = "http://vps81546.vps.ovh.ca/"
    let key_value_store = KeyValueStore.fetch_store ()
    let id_generator = UniqueIDGenerator.fetch ()

    let make_short_url (ID id) =
      ShortUrl (short_server ^ id)

    let shorten_and_store_url (LongUrl long_url) =
      let new_short_id = UniqueIDGenerator.get id_generator in
      let new_short_url = make_short_url new_short_id in
      let open KeyValueStore in
      KeyValueStore.put key_value_store new_short_id (LongUrl long_url);
      new_short_url

    let shorten = shorten_and_store_url
    let lookup short_url =
      KeyValueStore.get key_value_store short_url

    let print_data () = KeyValueStore.print key_value_store
  end

module TestStore : KEY_VALUE_STORE =
  struct
    type key = unique_url_id
    type value = long_url
    type t = (key, value) Hashtbl.t

    let fetch_store () = Hashtbl.create 100
    let print t = Hashtbl.iter (fun (ID id) (LongUrl l) -> print_endline (id ^ " shortens " ^ l)) t

    let put t x = print t; Hashtbl.add t x
    let get table key =
      try
        Some(Hashtbl.find table key)
      with
        Not_found -> None
  end

module TestGenerator : UNIQUE_ID_GENERATOR =
  struct
    type t = int ref
    let fetch () = ref 0
    let get r = incr r; ID (string_of_int (!r))
  end

module TestShortener = UrlShortener(TestStore)(TestGenerator)
