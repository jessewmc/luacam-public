(defun listofn (num elem)
	(if (eql num 0) ()
		(cons elem (listofn (- num 1) elem))))

;uses "true" as T because T is clobbered
(defun custlist (lst elem)
	(cond
		((eql lst nil) ())
		((atom lst) `(defconstant ,lst ,elem))
		("true" (cons
				(custlist (car lst) elem)
				(custlist (cdr lst) elem)))))

(defmacro defaddresses (names)
	`(progn ,@(custlist names nil)))

;no t, m, or g
(defaddresses
	(a b c d e f h i j k l n o p q r s u w x y z))

(defun g (num &rest args)
	(string-upcase (concatenate 
										'string "g" 
										(write-to-string num)
										)))

(defun cust-round (num digits)
		(let ((digit-order (expt 10.0 digits)))
			(let (
				(inter (* digit-order num))
				(modint (mod (* (* 10 digit-order) num) 10)))
					(cond
						((< modint 5) (/ (floor inter) digit-order))
						("true" (/ (ceiling inter) digit-order))))))

(defun g-round (num)
	(let(
		(inter (* 10000 num))
		(modint (mod (* 100000 num) 10)))
			(cond
				((< modint 5) (/ (floor inter) 10000.0))
				("true" (/ (ceiling inter) 10000.0)))))
;	(/ (ceiling (* 10000 num)) 10000.0))
	
#|	

(numberp )
(write-to-string (defvar g))

DEFVAR returs var name. I think there is a better way tho
G00 Xnum Znum -->

(G00 Znum Xnum2)
(G00 X num Y num P num F num
(G 00 x num y num p num f num)
(m 51)
|#
