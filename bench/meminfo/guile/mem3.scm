#!/var/guix/profiles/per-user/ugoday/guix-profile/bin/guile \
-e main -s
-*- scheme -*-
!#

(use-modules (ice-9 rdelim))
(use-modules (ice-9 regex))

(define keyrx (make-regexp "[a-z]*" regexp/icase))
(define valrx (make-regexp "[0-9]+"))

(define (next-pair)
  (let ((line (read-line)))
    (if (eof-object? line) line
	(let ((mem-name (match:substring (regexp-exec keyrx line))))
	  (if (member mem-name '("MemTotal" "MemFree" "Buffers"))
	      (let ((mem-value (match:substring (regexp-exec valrx line))))
		(cons mem-name (string->number mem-value)))
	      )))))
 
(define (read-meminfo)
  (let ((free-memory 0))
    (do ((mem-pair (next-pair) (next-pair))) ((eof-object? mem-pair))
      (if (pair? mem-pair)
	  (set! free-memory
		((if (or (string= (car mem-pair) "MemTotal")
			 (string= (car mem-pair) "Buffers"))
		     +
		     -)
		 free-memory (cdr mem-pair)))))
    (display (/ free-memory 1024.0))
    (newline)))

(define (check-mem)
  (with-input-from-file "/proc/meminfo"
    read-meminfo))


(define (main args)
  "repeat calculation with counts given by args "
  (let ((n (string->number (cadr (command-line)))))
    (do ((i 0 (1+ i)))
	((>= i n))
      (check-mem))))
