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

let () =
  Shortening_service_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"shortening_service"
           ~css:[["css";"shortening_service.css"]]
           Html5.F.(body [
             h2 [pcdata "Welcome from Eliom's distillery!"];
           ])))
