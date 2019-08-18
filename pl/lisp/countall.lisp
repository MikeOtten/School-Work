(defun count-all (lis)
    (if (null lis)
        0
		(if (listp (car lis))
			(+ (count-all (car lis)) (count-all (cdr lis)))
			( + 1 (count-all( cdr lis)))
		)
    )
)


( write ( count-all '(Dennis (Dylan Christopher) David Rick))) 
( write(count-all '((Kevin Michelle John) Tamara (Chris (Stephen Khadija)) Jamie Tom)))