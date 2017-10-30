#!/var/guix/profiles/per-user/ugoday/guix-profile/bin/guile \
-e main -s
-*- scheme -*-
!#

(use-modules (ice-9 rdelim))
(use-modules (ice-9 regex))
(use-modules (ice-9 format))


(define keyrx (make-regexp "[a-z]*" regexp/icase))
(define valrx (make-regexp "[0-9]+"))

(define meminfo (make-hash-table 3))

(define (print-meminfo)
  (let* ((mem-total (hash-ref meminfo "MemTotal"))
	 (mem-free (hash-ref meminfo "MemFree"))
	 (buffers (hash-ref meminfo "Buffers"))
	 (free-ram (+ (- mem-total mem-free) buffers))
	 (percent-free (/ (* 100.0 free-ram) mem-total)))
;;    (format #t "total: ~1,2f\t free: ~1,2f\t buffers: ~1,2f\n" mem-total mem-free buffers)
    (format #t "RAM ~1,2f% ~1,2fmb\n" percent-free (/ free-ram 1024.0) )))

(define (ready?)
  (and (> (hash-ref meminfo "Buffers") 0)
       (> (hash-ref meminfo "MemFree") 0)
       (> (hash-ref meminfo "MemFree") 0)))

(define (analize line)
  (let ((mem-name (match:substring (regexp-exec keyrx line))))
    (if (hash-ref meminfo mem-name) 
	(let ((mem-value (match:substring (regexp-exec valrx line))))
	  (hash-set! meminfo mem-name (string->number mem-value))))))

(define (fill-meminfo)
  (let ((line (read-line)))
    (if (not (eof-object? line))
	(let ((a (analize line)))
	  (if (not (ready?))
	      (fill-meminfo))))))

(define (check-mem)
  (with-input-from-file "/proc/meminfo"
    (lambda ()
      (fill-meminfo)
      (print-meminfo))))

(define (init-meminfo)
  (hash-set! meminfo "Buffers" 0)
  (hash-set! meminfo "MemFree" 0)
  (hash-set! meminfo "MemTotal" 0))


(define (main args)
  "repeat calculation with counts given by args "
  (let ((n (string->number (cadr (command-line)))))
    (do ((i 0 (1+ i)))
	((>= i n))
      (init-meminfo)
      (check-mem))))
