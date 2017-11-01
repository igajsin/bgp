NUM = 20000

test:
	time shell/mem2.sh $(NUM) > /dev/null
	time guile/mem4a.scm $(NUM) > /dev/null
	time lisp/mem5 $(NUM) > /dev/null
	time lisp/mem5a $(NUM) > /dev/null

