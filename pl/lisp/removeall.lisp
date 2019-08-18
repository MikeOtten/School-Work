(defun remove-all (atm lis)
	(cond
		((null lis) 			'())
		((listp (car lis)) 		(cons (remove-all atm (car lis)) (remove-all atm (cdr lis) ) ) )
		(( eq atm (car lis)) 	(remove-all atm (cdr lis) ) )
		(t 						(cons (car lis) (remove-all atm (cdr lis) ) ) )
	)
)
(write (remove-all 'Andy '(Austen Andy Khalil (Andy John) Tony)))