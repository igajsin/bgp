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
  (let* ((mem-total (assoc-ref meminfo "MemTotal"))
	 (mem-free (assoc-ref meminfo "MemFree"))
	 (buffers (assoc-ref meminfo "Buffers"))
	 (free-ram (+ (- mem-total mem-free) buffers))
	 (percent-free (/ (* 100.0 free-ram) mem-total)))
    (format #t "RAM ~1,2f% ~1,2fmb\n" percent-free (/ free-ram 1024.0) )))

(define (ready? meminfo)
  (and (> (assoc-ref meminfo "MemTotal") 0)
       (> (assoc-ref meminfo "MemFree") 0)
       (> (assoc-ref meminfo "Buffers") 0)))

(define (analize line meminfo)
  (let ((mem-name (match:substring (regexp-exec keyrx line))))
    (if (assoc-ref meminfo mem-name) 
	   (let ((mem-value (match:substring (regexp-exec valrx line))))
	     (acons mem-name (string->number mem-value) meminfo))
	   meminfo)))

(define (fill-meminfo meminfo)
  (let ((line (read-line)))
    (if (eof-object? line) meminfo
	(let ((new-meminfo (analize line meminfo)))
	  (if (ready? new-meminfo) new-meminfo
	      (fill-meminfo new-meminfo))))))

(define (check-mem)
  (let ((meminfo '(("Buffers" . 0) ("MemFree" . 0) ("MemTotal" . 0))))
    (with-input-from-file "/proc/meminfo"
      (lambda () (print-meminfo (fill-meminfo meminfo))))))


(define (main args)
  "repeat calculation with counts given by args "
  (let ((n (string->number (cadr (command-line)))))
    (do ((i 0 (1+ i)))
	((>= i n))
      (check-mem))))
