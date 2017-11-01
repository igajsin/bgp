cleanup:
	rm mem5
	rm *~
build:
	buildapp --load ./mem5.lisp --entry main --output mem5 --load-system cl-ppcre
run: build
	./mem5 1

builda:
	buildapp --load ./mem5a.lisp --entry main --output mem5a --load-system cl-ppcre
runa: builda
	./mem5a 1

all: build
