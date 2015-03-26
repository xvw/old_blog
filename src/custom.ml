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
  
let seek elt =
  let kwd =
    let open Regexp in 
    let k = 
      to_string (elt ## value)
      |> split (regexp "\\s|\\+|;|,")
      |> List.fold_left (fun a x -> a^",.keyword_"^x) "" in
    String.(sub k 1 ((length k)-1))

  in
  let all =
    (document ## querySelectorAll (string ".a_article"))
    |> Dom.list_of_nodeList
  in
  let candidates =
    (document ## querySelectorAll (string kwd))
    |> Dom.list_of_nodeList
  in
  match candidates with
  | [] ->
     display all "block"
  | x ->
     display all "none";
     display x "block"
       
  
let state () =
  let searchbar = ((CoerceTo.input (retreive "search-bar") |> unopt)) in
  searchbar ## onkeyup <- Dom.handler (fun _ -> seek searchbar; _true)
let _ = run state
  
