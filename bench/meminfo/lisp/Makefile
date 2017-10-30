cleanup:
	rm mem5
	rm *~
build:
	buildapp --load ./mem5.lisp --entry main --output mem5 --load-system cl-ppcre
run: build
	./mem5 1
all: build
