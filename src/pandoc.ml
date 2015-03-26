(* Usefull tools for Pandoc usage *)

let process ?(f="markdown") ?(t="html") input output =
	Sys.command
		("pandoc --latex-engine=xelatex -t "^t^" -f "^f^" -o"^output^" "^input)
	|> ignore

let markdown_on_the_run str =
	let fileIn = File.create_temp ".pandoc_buffer" str in
	let fileOut = File.create_temp ".pandoc_output.html" "" in
	let _ = process fileIn fileOut in
	let result = File.read fileOut in
	File.remove fileIn;
	File.remove fileOut;
	result
	
