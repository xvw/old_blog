(* Easy regexp use *)

(* Split a string with a pattern *)
let split pattern =
	Str.split @@ Str.regexp pattern

(* replace all occurence of pattern with form in s*)
let replace pattern form  =
	Str.global_replace (Str.regexp pattern) form
                     
(* erase all occurence of pattern *)
let purge pattern = replace pattern ""

(* Erase futile data *)
let minimize  =
	replace "\n" ""

(* multiline process *)
let multiline_process expr f =
	replace "\n" "--<multiline-escaped>--" expr
	|> f 
	|> replace "--<multiline-escaped>--" "\n" 
