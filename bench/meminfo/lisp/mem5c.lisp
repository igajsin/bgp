(eval-when (:compile-toplevel :load-toplevel :execute)
  (require 'cl-ppcre))

(defun print-result (meminfo)
  (let* ((mem-total (car meminfo))
	 (mem-free (cadr meminfo))
	 (buffers (caddr meminfo))
	 (free-ram (+ (- mem-total mem-free) buffers))
	 (percent-free (/ (* 100.0 free-ram) mem-total)))
    (format t "RAM ~1,2f% ~1,2fmb~%" percent-free (/ free-ram 1024.0))))

(defun get-proc (filename buf scan)
  (with-open-file (in filename)
    (read-sequence buf in)
    (cl-ppcre::register-groups-bind
	((#'parse-integer mem-total) (#'parse-integer  mem-free) (#'parse-integer buffers))
	     (scan buf)
	   (list mem-total mem-free buffers))))

(defun get-file-size (filename)
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil 'eof)
          until (eq line 'eof)
       sum (length line))))

(defun main (argv)
  (declare (ignore argv))
  (let* ((n (parse-integer (cadr *posix-argv*)))
	 (filename "/proc/meminfo")
	 (size (get-file-size filename))
	 (buf (make-string size))
	 (scan (cl-ppcre:create-scanner "MemTotal:\\s+(\\d+).+MemFree:\\s+(\\d+).+Buffers:\\s+(\\d+)"
					:single-line-mode t)))
    (loop for i from 1 to n do
	 (print-result (get-proc filename buf scan)))))
