(defun count-all (lis)
    (if (null lis)
        0
		(if (listp (car lis))
			(+ (count-all (car lis)) (count-all (cdr lis)))
			( + 1 (count-all( cdr lis)))
		)
    )
)


(if (= (count-all '(+ 1)) 2)
    ( write "hi")
)
