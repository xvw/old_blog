(* Tool for file manipulation  *)

(* Read content file *)
let read filename =
	let chan = open_in filename in
	let len = in_channel_length chan in
	let res = Bytes.create len in
	really_input chan res 0 len;
	close_in chan;
	(Bytes.to_string res)

(* Retreive file as a string list *)
let read_lines filename =
	read filename
	|> Regexp.split "\n"

(* Write content into a file  *)
let write filename content =
	let chan = open_out filename in
	output_string chan content;
	close_out chan

(* Append content to a file*)
let append ?(chmod=0o664) filename content =
	let chan =
		open_out_gen
			[
				Open_rdonly;
				Open_append;
				Open_creat;
				Open_text
			] chmod filename
	in
	output_string chan content;
	close_out chan

(* Create tempfile *)
let create_temp filename c =
	append ~chmod:0o777 filename c;
	filename

(* Prepend content to a file*)
let prepend filename content =
	let total = content ^ (read filename) in
	write filename total
 

(* Delete a file *)
let remove = Sys.remove


(* File without extension *)
let basename file =
	file
	|> Filename.basename
	|> Filename.chop_extension
