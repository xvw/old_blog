(* Custom search system *)
open Js
open Dom_html

let (>>=) = Lwt.bind
                   
let wait_page () =
  let t, u = Lwt.wait () in
  let _ =
    window ## onload <-
      Dom.handler (fun _ -> Lwt.wakeup u (); _true)
  in t

let fail () = raise Not_found
let unopt x = Opt.get x fail
let retreive id = unopt (document ## getElementById (string id))
                        
let run f = (wait_page ()) >>= (fun () -> Lwt.return (f ()))
let display e t =
  List.iter (fun elt -> elt ## style ## display <- (string t)) e

let press_cross e = display [e] "none"
  
let state () =
  let cross = retreive "close-alert" in
  let box = retreive "ui-notif" in
  cross ## onclick <- Dom.handler (fun _ -> press_cross box; _true)
let _ = run state
  
