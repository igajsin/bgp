(eval-when (:compile-toplevel :load-toplevel :execute)
  (require 'cl-ppcre))

(defun analize (line meminfo)
  (let ((mem (cl-ppcre::register-groups-bind (name (#'parse-integer value))
	     ("(\\w+):\\s+(\\d+).*$" line)
	       (cons name value))))
    (format t "~a~%" mem)))

(defun read-file (stream meminfo)
  (let ((line (read-line stream nil 'eof)))
    (if (eq line 'eof) meminfo
	(analize line meminfo))))

(defun test ()
  (with-open-file (stream "/proc/meminfo")
    (let ((meminfo (make-hash-table :test 'equal :size 3)))
      (setf (gethash "MemTotal" meminfo) 0)
      (setf (gethash "MemFree" meminfo) 0)
      (setf (gethash "Buffers" meminfo) 0)
      (read-file stream meminfo))))

(defun main (argv)
  (let ((n (parse-integer (cadr *posix-argv*))))
    (loop for i from 1 to n
	 do (test))))
