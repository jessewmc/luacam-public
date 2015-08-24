(defun square (x)
	(* x x))
	
(defun round (x)
	(format nil 

(defun keyseat-clear (width dia)
	(/ (- dia (sqrt (- (square dia) (square width)))) 2))

(defun ask-number ()
	(let ((val (read-from-string (read-line))))
		(if (numberp val)
			val
			ask-number)))
	
(princ "what is the diameter of the shaft?")

(setf dia (ask-number))

(princ "what is the width of the keyseat?")

(setf width (ask-number))

(princ (keyseat-clear width dia))