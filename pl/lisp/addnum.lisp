(defun add-numbers (lis)

    (if (null lis)
        0
        (if (listp (car lis))
			(+ (add-numbers (car lis)) (add-numbers (cdr lis)))
            (if ( numberp ( car lis ) )
				(+ ( car lis) ( add-numbers ( cdr lis) ) )
				(+ 0  ( add-numbers ( cdr lis) ) )
			)
		)
        
    )
)

(defun add-numbers2 (lis)
	
)

( write-line (write-to-string ( add-numbers '(3 60 ( Cael ( Robert  5)) Mike  2  Mark ))))
