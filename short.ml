module type KEY_VALUE_STORE =
  sig
    type t
    type key
    type value
    val fetch_store : unit -> t
    val put : t -> key -> value -> unit
    val get : t -> key -> value
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

    let short_server = "http://localhost"

    let make_short_url id =
      short_server ^ id

    let shorten_and_store_url long_url =
      let key_value_store = KeyValueStore.fetch_store () in
      let id_generator = UniqueIDGenerator.fetch () in
      let new_short_id = UniqueIDGenerator.get id_generator in
      let new_short_url = make_short_url new_short_id in
      ()
  end
