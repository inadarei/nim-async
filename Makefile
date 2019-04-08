.PHONY: build
build: 
	nim compile -d:ssl http.nim

.PHONY: run
run:
	./http

# OSX: brew install mingw-w64
# see: https://github.com/nim-lang/Nim/issues/10717
# edit ~/.choosenim/toolchains/nim-0.19.4/config/nim.cfg
.PHONY: windows
windows:
	nim c -d:mingw http.nim
