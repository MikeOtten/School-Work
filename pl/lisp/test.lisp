
;;; base recursive function that identifies and calls addition or multiplication
(defun addition (lisa)
	(cond 
		((null lisa) 				'() )
		((listp (car lisa)) 			(cons (simplify (car lisa)) (simplify (cdr lisa))))
		((eq (car lisa) 0)			(addition (cdr lisa) ) )
		(t 							(cons (car lisa) (addition (cdr lisa))))
	)
)

(defun multiplication (liss)
	
	(cond 
		((null liss) 			'() )
		((listp (car liss)) 	(cons (simplify (car liss)) (simplify (cdr liss))))
		((eq (car liss) 1)		(multiplication (cdr liss) ) )
		(t 						(cons (car liss) (multiplication (cdr liss) ) ) )
	)

)

(defun simplify (lisd)
	(cond
		((null lisd) 						'() )
		((listp (car lisd)) 					(cons (simplify (car lisd)) (simplify (cdr lisd)) ) )
		((eq (car lisd) (car '( + 7) ) )		(if (= (count-all lisd) 3 )
													(if (> (count-zero lisd) 0)
														(addition(cdr lisd)))
													(cons  (car lisd) (addition (cdr lisd) ) ) ) )
		((eq (car lisd) (car '( * 7) ) )		(if (> (count-zero lisd) 0)
													0
													(if (= (count-one lisd) 0)
														(if (= (count-all lisd) 3 )
															(if ( and (listp (car (cdr lisd))) (listp (cdr (cdr lisd))) )
																(cons (car lisd) (multiplication (cdr lisd) ) )
																(multiplication  (cdr lisd))
															)
															(cons (car lisd) (multiplication (cdr lisd) ) ) 
														)
														(cons (car lisd) (multiplication (cdr lisd) ) ) 
													)
												))
		(t									(cons (car lisd) (simplify (cdr lisd))))
	)
	
)


(defun count-all (lis)
    (if (null lis)
        0
		( + 1 (count-all( cdr lis)))
    )
)

(defun count-zero (lis)
	(cond
		( (null lis)					0)
		;( (listp (car lis)) 			(+ (count-zero (car lis) ) (count-zero (cdr lis) ) ) )
		( (eq (car lis) '0)				( + 1 (count-zero( cdr lis))))
		(t 								(count-zero(cdr lis)))
	)
)
(defun count-one (lis)
	(cond
		( (null lis)					0)
		;( (listp (car lis)) 			(+ (count-zero (car lis) ) (count-zero (cdr lis) ) ) )
		( (eq (car lis) '1)				( + 1 (count-one( cdr lis))))
		(t 								(count-zero(cdr lis)))
	)
)

( write-line (write-to-string	(simplify '( * 3 0))))
( write-line (write-to-string	(simplify '( + 3 0))))
( write-line (write-to-string 	(simplify '( + 1 2 0) )  ) )
( write-line (write-to-string 	(simplify '( * 1 2) ) ) ) 
( write-line (write-to-string 	(simplify '( * (+ 6 0) (* 1 6 2) )  ) ) )

"""
(defun remove-all (atm lis)
	(cond
		((null lis) 			'())
		((listp (car lis)) 		(cons (remove-all atm (car lis)) (remove-all atm (cdr lis) ) ) )
		(( eq atm (car lis)) 	(remove-all atm (cdr lis) ) )
		(t 						(cons (car lis) (remove-all atm (cdr lis) ) ) )
	)
)


(if (and (eq (car lis) (car '( * 7) )) ()
		)
		
		(eq (car lis) 0)		0)
		
		
"""