(* Kernel of blogging system *)
exception Malformed_document
exception Malformed_list

let url = "http://xvw.github.io"
            
let extract_block tag expr =
	let open Str in 
	let re_begin = regexp ("<"^tag^">\\(.*\\)")
	and re_end = regexp ("\\(.*\\)</"^tag^">") in
	let rec aux acc state = function
		| [] -> raise Malformed_document
		| x::xs ->
			let re = if state then re_end else re_begin in 
			if string_match re x 0
			then
				let sub = replace_first re "\\1" x in
				if state then
					let delim = if acc = "" then "" else "\n" in 
					(acc ^ delim ^ sub)
				else aux acc true (sub :: xs) 
			else
			if state then aux (acc ^ "\n" ^ x) state xs
			else aux acc state xs
	in
	try Some (aux "" false (Regexp.split "\n" expr))
	with Malformed_document -> None

let list_to_couple = function
	| [x;y] -> Some (x^"", y^"")
	| _ -> None

let extract_inline tag expr =
	let open Str in
	let re = regexp (".*<"^tag^"/>.*") in
	string_match re (Regexp.minimize expr) 0

let has_extension ext filename =
	let full_ext = "."^ext in
	let len = String.length full_ext in
	(Str.last_chars filename len) = full_ext

							 
module Date =
struct

	let current = Unix.time
									
	let to_string tf =
		let open Unix in 
		let gmt = localtime tf in
		Printf.sprintf
			"%02d/%02d/%d"
			gmt.tm_mday
			(gmt.tm_mon + 1)
			(gmt.tm_year + 1900)

	let of_string gmt =
		let open Unix in
		Scanf.sscanf
			gmt
			"%02d/%02d/%d"
			(fun d m y ->
			 {(gmtime (current ())) with
				 tm_sec = 0;
				 tm_min = 0;
				 tm_hour = 0;
				 tm_mday = d;
				 tm_mon = m - 1;
				 tm_year = y - 1900;
			 }
			)
		|> Unix.mktime
		|> fst

  let to_rss2 date =
    let open Unix in 
    let t = gmtime date
    and month i =
      [|
        "Jan"; "Feb"; "Mar"; "Apr";
        "May"; "Jun"; "Jul"; "Aug";
        "Sep"; "Oct"; "Nov"; "Dec";
       |].(i)
    and day i =
      [|
        "Sun"; "Mon"; "Tue"; "Wed"; "Thu";
        "Fri"; "Sat"
      |].(i)
    in
    Printf.sprintf
      "%s, %02d %s %04d %02d:%02d:%02d UT"
      (day t.tm_wday)
      (t.tm_mday)
      (month t.tm_mon)
      (t.tm_year + 1900)
      (t.tm_hour)
      (t.tm_min)
      (t.tm_sec)

end
	
module Retreive =
struct

	let title e =
		match extract_block "title" e with
		| Some x -> x
		| _ -> raise Malformed_document

	let desc e =
		match extract_block "desc" e with
		| Some x -> Some (Pandoc.markdown_on_the_run x )
		| None -> None
								 
	let subtitle = extract_block "subtitle"
	let file = extract_block "file"
	let draft = extract_inline "draft"

	let date e =
		match extract_block "date" e with
		| Some x -> Some (Date.of_string x)
		| None -> None

	let keywords e =
		match extract_block "keywords" e with
		| None -> []
		| Some x ->
			 let res =
         Regexp.minimize x
			   |> String.lowercase
			   |> Regexp.replace " " ""
			   |> Regexp.split ","
       in res

	let links e =
		match extract_block "links" e with
		| None -> []
		| Some x ->
			Regexp.replace "\n" ";" x
			|> Regexp.purge "\t"
			|> Regexp.split ";"
			|> List.map
					 (fun x ->
						(Regexp.split "->" x) |> list_to_couple)
			|> List.fold_left (fun a x -> match x with Some b -> b::a |_ -> a) []
			|> List.rev

end


type entry = {
	title : string;
	subtitle : string option;
	desc : string option;
	date : float;
	file : string option;
	draft : bool;
	keywords : string list;
	links : (string * string) list;
}

let kwd k=
  let e = List.fold_left (fun a x -> a^","^x) "" k in
  try
    String.sub e 1 ((String.length e)-1)
    |> Printf.sprintf "<meta name='keywords' content='%s'>"
  with _ -> ""

let kwd_to_class =
  List.fold_left (fun a x -> a^" keyword_"^x) ""
               
let create_html_file t s md base kw =
	Pandoc.process md (".pandoc_buffer");
	File.read "tpl/article.html"
	|> Regexp.replace "{{CSS}}" (File.read "tpl/cssheader.html")
  |> Regexp.replace "{{KEYWORDS}}" (kwd kw)
	|> Regexp.replace "href='css/" "href='../css/"
	|> Regexp.replace "{{article-title}}" t
	|> Regexp.replace
			 "{{article-subtitle}}"
			 (match s with Some x -> x | _ -> "")
	|> Regexp.replace "{{article-content}}" (File.read ".pandoc_buffer")
	|> File.write ("post/"^base^".html");
	File.remove ".pandoc_buffer";
	print_endline ("blogengine.byte : "^base^".html generated!")
																					

let treat_entry filename =
	let content = File.read filename in
	try 
		let title = Retreive.title content
		and subtitle = Retreive.subtitle content
		and desc = Retreive.desc content
		and file = Retreive.file content
		and draft = Retreive.draft content
		and keywords = Retreive.keywords content
		and links = Retreive.links content
		and date =
			match Retreive.date content with
			| None ->
				 let indate = Date.current () in 
				 File.append filename ("<date>"^Date.to_string indate^"</date>");
				 indate
			| Some x -> x
		in
		let result =
			{
				title = title;
				subtitle = subtitle;
				desc = desc;
				file = file;
				draft = draft;
				keywords = keywords;
				links = links;
				date = date
			} in
		(* Create PDF file *)
		let _ =
			match file with
			| Some x ->
				 let base = File.basename x in
				 Pandoc.process ~t:("latex") x ("pdf/"^base^".pdf");
				 print_endline ("blogengine.byte : "^base^".pdf generated!");
				 create_html_file title subtitle x base keywords;
			| None -> ()
		in 
		Some result
	with
	| Malformed_document -> None


let concat_if a = function
	| Some x -> x::a
	| None -> a

let entries dir =
	Sys.readdir dir
	|> Array.fold_left
			 (fun a x ->
				if (has_extension "xml" x)
				then ((dir^"/"^x)::a) else a
			 )
			 []
	|> List.map treat_entry
	|> List.fold_left concat_if []
	|> List.filter (fun x -> not x.draft) 
	|> List.sort (fun a b -> compare b.date a.date )

let entry_to_string e =
	let title = match e.subtitle with
		| None -> e.title
		| Some s -> e.title^": "^s
	and desc = match e.desc with
		| None -> ""
		| Some d -> d
	in
	let (target, links) = match e.file with
		| None -> ("#Il-n-y-a-rien-de-clickable-aha!", e.links)
		| Some x ->
			 let base = File.basename x in 
			 ("post/"^base^".html", (("Lire", "post/"^base^".html") ::
					("Lire en PDF", "pdf/"^base^".pdf") :: e.links))
	in 
	"<div class='a_article "^(kwd_to_class e.keywords)^"'>"
	^ "<span class='a_date'>" ^ (Date.to_string e.date) ^ "</span>"
	^ "<a class='a_title' href='"^target^"'>" ^ title ^ "</a>"
	^ desc
	^ "<ul class='enum-links'>"
	^ List.fold_left
			(fun a (l, t) -> a^("<li><a href='"^t^"'>"^l^"</a></li>")) "" links
	^ "</ul>"
	^ "</div>"

(* Erf, this is really ugly :'( *)
let generate_rss entries =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  ^"<rss version=\"2.0\"><channel>"
  ^"<title>Xavier Van de Woestyne, Page personnelle</title>"
  ^"<description>Page personnelle de moi :v</description>"
  ^"<lastBuildDate>"^(Date.to_rss2 (Unix.time ()))^"</lastBuildDate>"
  ^"<link>"^url^"</link>"
  ^ (
    List.fold_left
      (fun a x ->
       let desc = match x.desc with
         | Some x -> x | None -> "Pas de description"
       and link = match x.file with
         | Some x -> url ^ "/post/" ^ (File.basename x) ^ ".html"
         | None -> url ^ "/list.html" in                         
       let sub =
         "<item>"
         ^"<title>"^x.title^"</title>"
         ^"<description>"^desc^"</description>"
         ^"<pubDate>"^Date.to_rss2 x.date^"</pubDate>"
         ^"<link>"^link^"</link>"
         ^"</item>" in a ^ sub
      ) "" entries
  )
  ^"</channel></rss>"
  |> File.write "feed.xml";
  print_endline "blogengine.byte : RSS Generated !"

let () =
	let e  = entries "raw" in
  let _ = generate_rss e in
  e
	|> List.map entry_to_string
	|> List.fold_left (fun a x -> a^x) ""
	|> File.write "raw_list.html" 
	              
