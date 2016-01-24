open Bootstrapper

(* Side effects *)
let current_slide = ref 0

(* Low level function *)

let doc =
  Dom_html.document ## documentElement
    
let hide elt =
  let _ = Html.add_class elt "hidden" in
  Html.remove_class elt "visible"
    
let show elt =
  let _ = Html.remove_class elt "hidden" in
  Html.add_class elt "visible"
    
let slides () =
  Html.select_nodes doc ".slide"
    
let hide_slides () =
  List.iter hide (slides ())


let show_current_slide () =
  let slides = slides () in
  let () = List.iter hide slides in
  List.iteri
    (fun i e -> if i = !current_slide then show e)
    slides

let next () =
  let _ =
    if !current_slide < (List.length (slides ())) -1
    then current_slide := !current_slide + 1
  in Lwt.return (show_current_slide ())

let prev () =
  let _ =
    if !current_slide > 0
    then current_slide := !current_slide - 1
  in Lwt.return (show_current_slide ())

let bind_event () =
  let open Event in
  let _ =
    doc >-(mouseup, fun _ _ -> next ()) |> ignore
  in
  let _ =
    doc >- (
      keyup, fun e _ ->
        match e##keyCode with
        | 38 | 37 -> prev ()
        | 40 | 39 -> next ()
        | _ -> Lwt.return_unit
    )
    |> ignore
  in 
  let _ =
    async_loop
      mousewheel
      doc
      (fun (e, (x, y)) _ ->
         if y > 0 then next () else prev ())
  in ()
    

(* Initialize *)
    
let () =
  show_current_slide ();
  bind_event ()
    
