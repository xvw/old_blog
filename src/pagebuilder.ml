(* Compile HTML page *)
let read_empty f =
	try File.read f
	with _ -> "Il n y a aucun article pour le moment !"

let attributes =
	[
		"CSS", File.read "tpl/cssheader.html";
		"articles-enum", read_empty "raw_list.html"
	]

let minimize expr =
	expr
	|> Regexp.minimize
	|> Regexp.replace ">\\( \\|\t\\)*<" "><"
	|> Regexp.replace " +\\|\t+" " "
			 
let read = File.read
let apply str =
	List.fold_left
		(
			fun acc (key, pattern) ->
			Regexp.replace ("{{"^key^"}}") pattern acc
		)
		str
		attributes

let minimize file =
	File.read file
	|> apply
	|> minimize

let usage = "pagebuilder.byte [-o output] file.html"
let anon = ref ""
let anon_fun x = anon := x 
let out = ref "out.html"

let () =
	let _ =
		Arg.parse
			["-o", Arg.Set_string out, "Output compiled html"]
			anon_fun
			usage
	in
	let e = minimize (!anon) in
	File.write !out e;
	print_endline ("pagebuilder.byte : "^(!out)^" created")

								
