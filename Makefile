# Static blog system
# xvw.github.io

# General informations
# `make clean` erase builded files
# `make initialize` initialize folders
# `make css` generate CSS file
# `make index` generate index.html


#================================================
# Configuration
#================================================
SRC = src
BYTES = bytes
PDF = pdf
POST	= post
CSS = css
JS	= js
TPL = tpl
RAW = raw
BLOGR = $(RAW)/articles
GIT = master
CSSFiles	= $(CSS)/common.css $(CSS)/template.css


#================================================
# Compilers
#================================================
ocamlc = @ocamlc -I $(SRC) 
ocamljs = ocamlfind ocamlc -package js_of_ocaml -package js_of_ocaml.syntax -syntax camlp4o -linkpkg

#================================================
# PHONY Rules
#================================================
.PHONY: initialize clean all
all : list clean_obj_files clean_emacs_files clean_bytes push

#================================================
# Initialize
#================================================
initialize :
	@echo "Initialize folders"
	@mkdir -p $(SRC) $(BYTES) $(PDF) $(CSS) $(JS)
	@mkdir -p $(TPL) $(RAW) $(BLOGR) $(POST) 


#================================================
# OCaml rules
#================================================
regexp.cmo : $(SRC)/regexp.ml
	@echo "Generate Regexp lib"
	$(ocamlc) -c unix.cma str.cma $(<)
file.cmo : $(SRC)/file.ml regexp.cmo
	@echo "Generate File lib"
	$(ocamlc) -c unix.cma regexp.cmo $(<)
pandoc.cmo : $(SRC)/pandoc.ml regexp.cmo file.cmo
	@echo "Generate Pandoc lib"
	$(ocamlc) -c regexp.cmo file.cmo $(<)
%.byte : regexp.cmo file.cmo pandoc.cmo $(SRC)/%.ml
	@echo "Generate $(@)"
	$(ocamlc) unix.cma str.cma $(^) -o $(BYTES)/$(@)

#================================================
# Js_of_ocaml rules
#================================================
custom.js : $(SRC)/custom.ml
	@echo "Generate custom.js"
	@$(ocamljs) -o $(BYTES)/custom.byte $(^)
	@js_of_ocaml $(BYTES)/custom.byte -o $(JS)/$(@)
#================================================
# Git rules
#================================================
commit:
	git add *
	git commit -m "Update page"
push: commit
	git push origin $(GIT)


#================================================
# Generator rules
#================================================

# - Only minimizer acually
app.min.css : postprocess.byte
	@echo "Generate CSS file"
	@./$(BYTES)/postprocess.byte -o $(CSS)/$(@) $(CSSFiles)
css : app.min.css

#  Build compiled index
index : pagebuilder.byte app.min.css
	@echo "Generate index"
	@./$(BYTES)/pagebuilder.byte -o index.html $(TPL)/index.html

about : pagebuilder.byte index
	@echo "Generate About page"
	@./$(BYTES)/pagebuilder.byte -o apropos.html $(TPL)/apropos.html

#  Build article list
list : about index blogengine.byte
	@echo "Generate article enumeration"
	@./$(BYTES)/blogengine.byte 
	@./$(BYTES)/pagebuilder.byte -o list.html $(TPL)/listarticles.html


#================================================
# Clean rules
#================================================

clean : clean_obj_files clean_emacs_files clean_css cleanD
cleanD: clean_bytes

clean_obj_files :
	@echo "Clean all obj files"
	@rm -rf */*.cm*

clean_bytes :
	@echo "Clean all bytes files"
	@rm -rf */*.byte

clean_emacs_files :
	@echo "Clean all emacs files"
	@rm -rf *~
	@rm -rf */*~
	@rm -rf \#*\#
	@rm -rf */\#*\#

clean_css :
	@echo "Clean postprocessed CSS"
	@rm -rf $(CSS)/app.min.css


# debug stuff
debug_toplevel :  blogengine.byte
	ocaml -I $(SRC) unix.cma str.cma regexp.cmo file.cmo blogengine.cmo 
