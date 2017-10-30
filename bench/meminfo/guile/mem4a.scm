#!/var/guix/profiles/per-user/ugoday/guix-profile/bin/guile \
-e main -s
-*- scheme -*-
!#

(use-modules (ice-9 rdelim))
(use-modules (ice-9 regex))
(use-modules (ice-9 format))


(define keyrx (make-regexp "[a-z]*" regexp/icase))
(define valrx (make-regexp "[0-9]+"))

(define (print-meminfo meminfo)
  (let* ((mem-total (hash-ref meminfo "MemTotal"))
	 (mem-free (hash-ref meminfo "MemFree"))
	 (buffers (hash-ref meminfo "Buffers"))
	 (free-ram (+ (- mem-total mem-free) buffers))
	 (percent-free (/ (* 100.0 free-ram) mem-total)))
    (format #t "RAM ~1,2f% ~1,2fmb\n" percent-free (/ free-ram 1024.0) )))

(define (ready? meminfo)
  (and (hash-ref meminfo "Buffers")
       (hash-ref meminfo "MemFree")
       (hash-ref meminfo "MemTotal")))

(define (analize line meminfo)
  (let ((mem-name (match:substring (regexp-exec keyrx line))))
    (if (hash-ref meminfo mem-name) 
	(let ((mem-value (match:substring (regexp-exec valrx line))))
	  (hash-set! meminfo mem-name (string->number mem-value))
	  meminfo)
	meminfo)))

(define (fill-meminfo meminfo)
  (let ((line (read-line)))
    (if (eof-object? line) meminfo
	(let ((new-meminfo (analize line meminfo)))
	  (if (ready? new-meminfo) new-meminfo
	      (fill-meminfo new-meminfo))))))

(define (check-mem)
  (let ((meminfo (make-hash-table 3)))
    (hash-set! meminfo "Buffers" 0)
    (hash-set! meminfo "MemFree" 0)
    (hash-set! meminfo "MemTotal" 0)
    (with-input-from-file "/proc/meminfo"
      (lambda () (print-meminfo (fill-meminfo meminfo))))))


(define (main args)
  "repeat calculation with counts given by args "
  (let ((n (string->number (cadr (command-line)))))
    (do ((i 0 (1+ i)))
	((>= i n))
      (check-mem))))
