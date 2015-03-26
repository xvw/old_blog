(* Postprocessor for CSS files *)
(* This file is in developppement and absolutly not finished *)
(* (And not used in the project) *)

(* At the moment, it only minimize and concat *)

exception Malformed_css

type css_attribute = string * string
type css_decoration = string list * (css_attribute list)
type css_media_queries = string list * css_decoration list
type css_node =
	| MediaQueries of css_media_queries
	| Basic of css_decoration
	| Import of string
type css_document = css_node list

let minimize expr =
	expr
	|> Regexp.minimize
	|> Regexp.replace "\\(:\\|;\\|,\\|{\\|}\\) *" "\\1"
	|> Regexp.replace " *\\({\\|:\\)" "\\1"
	|> Regexp.purge "\t"


let purge_comments = Regexp.purge ".*/\\*(.+)\\*/.*"

let minimize_file f =
	File.read f
	|> minimize

let concate e =
	List.fold_left
		(fun acc x -> acc^(minimize_file x))
		""
		(List.rev e) 

let usage = "postprocess.byte [-o output] fileA fileB fileC"
let anon : (string list) ref = ref []
let anon_fun x =  anon := x::(!anon)
let out = ref "css/app.min.css"

let () =
	let _ =
		Arg.parse
			["-o", Arg.Set_string out, "Output minimized css"]
			anon_fun
			usage
	in
	let e = concate (!anon) in
	File.write !out e;
	print_endline ("postprocess.byte : "^(!out)^" created")
