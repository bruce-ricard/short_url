[%%shared
    open Eliom_lib
    open Eliom_content
    open Html5.D
]

module Shortening_service_app =
  Eliom_registration.App (
    struct
      let application_name = "shortening_service"
    end)

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let form_service =
  Eliom_service.Http.post_service
    ~fallback:main_service
    ~post_params:Eliom_parameter.(string "long_url")
    ()

let create_form long_url =
  [p [
       pcdata "Enter an URL to shorten: ";
       Form.input ~input_type:`Text ~name:long_url Form.string;
       Form.input ~input_type:`Submit ~value:"Shorten" Form.string
     ]
  ]

let post_form () =
  Form.post_form ~service:form_service create_form ()

let result_page long_url short_url =
  html
    (head (title (pcdata "shortening_service")) [])
    (body [p [
               pcdata (Printf.sprintf "The url %s has been shortened into:" long_url);
               br ();
               pcdata short_url
             ]])

let () =
    Shortening_service_app.register
      ~service:form_service
      (fun () long_url ->
       let short_url = Short.TestShortener.shorten long_url in
       Lwt.return (result_page long_url short_url)
      )

let () =
  Shortening_service_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"shortening_service"
           ~css:[["css";"shortening_service.css"]]
           (body
                      [
                        h1 [pcdata "Welcome to this URL shortening service."];
                        post_form ()
                      ]
           )
        )
    )
