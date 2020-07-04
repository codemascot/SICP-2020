;; Exercise 2.54 (page 196)

(require rackunit)

(define (equal? a b)
  (cond ((and (null? a) (null? b)) #t)
        ((or (null? a) (null? b)) #f)
        ((eq? (car a) (car b)) (equal? (cdr a) (cdr b)))
        (else #f)))
     
(check-equal? (equal? '(0 1 2) (range 3)) #t)
(check-equal? (equal? '(0 1 2) (range 2)) #f)

;; Symbolic Differentiation (from the book)

(define (variable? x) (symbol? x))
(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))
(define (=number? exp num) (and (number? exp) (= exp num)))
(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
        ((=number? a2 0) a1)
        ((and (number? a1) (number? a2))
         (+ a1 a2))
        (else (list '+ a1 a2))))
(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
        ((=number? m1 1) m2)
        ((=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list '* m1 m2))))
(define (sum? x) (and (pair? x) (eq? (car x) '+)))
(define (addend s) (cadr s))
(define (augend s) (caddr s))
(define (product? x) (and (pair? x) (eq? (car x) '*)))
(define (multiplier p) (cadr p))
(define (multiplicand p) (caddr p))

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp) (if (same-variable? exp var) 1 0))
        ((sum? exp) (make-sum (deriv (addend exp) var)
                              (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        (else
         (error "unknown expression type: DERIV" exp))))

;; Exercise 2.56 (page 203)

(define (make-exponentiation base exp) 
  (cond ((=number? base 1) 1) 
        ((=number? exp 1) base) 
        ((=number? exp 0) 1) 
        (else (list '^ base exp))))

(define base cadr)
(define exponent caddr)

(define (exponentiation? exp) 
  (and (list? exp) (eq? (car exp) '^))) 

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp) (if (same-variable? exp var) 1 0))
        ((sum? exp) (make-sum (deriv (addend exp) var)
                              (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        ((exponentiation? exp) 
         (make-product  
          (make-product
           (exponent exp)
           (make-exponentiation (base exp)
                                (make-sum (exponent exp) -1)))
          (deriv (base exp) var)))
        (else
         (error "unknown expression type: DERIV" exp))))

(check-equal? (deriv '(^ x 3) 'x) '(* 3 (^ x 2)))

;; Exercise 2.59 (page 207)

(define (element-of-set? x set)
  (cond ((null? set) #f)
        ((equal? x (car set)) #t)
        (else (element-of-set? x (cdr set)))))

(check-equal? (element-of-set? 1 '(1 2 3)) #t)
(check-equal? (element-of-set? 4 '(1 2 3)) #f)

(define (union-set a b)
  (cond ((null? b) a)
        ((element-of-set? (car b) a) (union-set a (cdr b)))
        (else (union-set (cons (car b) a) (cdr b)))))

(check-equal? (union-set '(1 2 3) '(4 5 6)) '(6 5 4 1 2 3))
(check-equal? (union-set '(1 2 3) '(2 3 4)) '(4 1 2 3 ))