(eval-when (:compile-toplevel :load-toplevel :execute)
  (require 'cl-ppcre))

(defvar *scan* (cl-ppcre:create-scanner "([\\w,(,)]+):\\s+(\\d+).*$"))

(defun add-value (hash key value)
  (setf (gethash key hash) value)
  (setf (gethash "Ready" hash)
	(1+ (or (gethash "Ready" hash) 0))))

(defun print-meminfo (meminfo)
  (let* ((mem-total (gethash "MemTotal" meminfo))
	 (mem-free (gethash "MemFree" meminfo))
	 (buffers (gethash "Buffers" meminfo))
	 (free-ram (+ (- mem-total mem-free) buffers))
	 (percent-free (/ (* 100.0 free-ram) mem-total)))
    (format t "RAM ~1,2f% ~1,2fmb~%" percent-free (/ free-ram 1024.0))))

(defun ready-p (meminfo)
  (= 3 (gethash "Ready" meminfo)))
  

(defun update (meminfo name value)
  (when (gethash name meminfo)
    (add-value meminfo name value))
  meminfo)

(defun analize (line meminfo)
  (let ((mem (cl-ppcre::register-groups-bind (name (#'parse-integer value))
	     (*scan* line)
	       (update meminfo name value))))
    mem))

(defun read-file (stream meminfo)
  (let ((line (read-line stream nil 'eof)))
    (if (eq line 'eof) meminfo
	(let ((new-meminfo (analize line meminfo)))
	  (if (ready-p new-meminfo) new-meminfo
	      (read-file stream new-meminfo))))))

(defun test ()
  (with-open-file (stream "/proc/meminfo")
    (let ((meminfo (make-hash-table :test 'equal :size 3)))
      (add-value meminfo "MemTotal" 0)
      (add-value meminfo "MemFree" 0)
      (add-value meminfo "Buffers" 0)
      (add-value meminfo "Ready" 0)
      (print-meminfo (read-file stream meminfo)))))

(defun main (argv)
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (ignore argv))
  (let ((n (parse-integer (cadr *posix-argv*))))
    (loop for i from 1 to n
	 do (test))))
