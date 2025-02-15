#lang racket
(provide test-runner test-runner-io)
(require rackunit)

(define (test-runner run)
  ;; Abscond examples
  (check-equal? (run 7) 7)
  (check-equal? (run -8) -8)

  ;; Blackmail examples
  (check-equal? (run '(add1 (add1 7))) 9)
  (check-equal? (run '(add1 (sub1 7))) 7)

  ;; Con examples
  (check-equal? (run '(if (zero? 0) 1 2)) 1)
  (check-equal? (run '(if (zero? 1) 1 2)) 2)
  (check-equal? (run '(if (zero? -7) 1 2)) 2)
  (check-equal? (run '(if (zero? 0)
                          (if (zero? 1) 1 2)
                          7))
                2)
  (check-equal? (run '(if (zero? (if (zero? 0) 1 0))
                          (if (zero? 1) 1 2)
                          7))
                7)

  ;; Dupe examples
  (check-equal? (run #t) #t)
  (check-equal? (run #f) #f)
  (check-equal? (run '(if #t 1 2)) 1)
  (check-equal? (run '(if #f 1 2)) 2)
  (check-equal? (run '(if 0 1 2)) 1)
  (check-equal? (run '(if #t 3 4)) 3)
  (check-equal? (run '(if #f 3 4)) 4)
  (check-equal? (run '(if  0 3 4)) 3)
  (check-equal? (run '(zero? 4)) #f)
  (check-equal? (run '(zero? 0)) #t)

  ;; Dodger examples
  (check-equal? (run #\a) #\a)
  (check-equal? (run #\b) #\b)
  (check-equal? (run '(char? #\a)) #t)
  (check-equal? (run '(char? #t)) #f)
  (check-equal? (run '(char? 8)) #f)
  (check-equal? (run '(char->integer #\a)) (char->integer #\a))
  (check-equal? (run '(integer->char 955)) #\λ)

  ;; Extort examples
  (check-equal? (run '(add1 #f)) 'err)
  (check-equal? (run '(sub1 #f)) 'err)
  (check-equal? (run '(zero? #f)) 'err)
  (check-equal? (run '(char->integer #f)) 'err)
  (check-equal? (run '(integer->char #f)) 'err)
  (check-equal? (run '(integer->char -1)) 'err)
  (check-equal? (run '(write-byte #f)) 'err)
  (check-equal? (run '(write-byte -1)) 'err)
  (check-equal? (run '(write-byte 256)) 'err)

  ;; Fraud examples
  (check-equal? (run '(let ((x 7)) x)) 7)
  (check-equal? (run '(let ((x 7)) 2)) 2)
  (check-equal? (run '(let ((x 7)) (add1 x))) 8)
  (check-equal? (run '(let ((x (add1 7))) x)) 8)
  (check-equal? (run '(let ((x 7)) (let ((y 2)) x))) 7)
  (check-equal? (run '(let ((x 7)) (let ((x 2)) x))) 2)
  (check-equal? (run '(let ((x 7)) (let ((x (add1 x))) x))) 8)

  (check-equal? (run '(let ((x 0))
                        (if (zero? x) 7 8)))
                7)
  (check-equal? (run '(let ((x 1))
                        (add1 (if (zero? x) 7 8))))
                9)
  (check-equal? (run '(+ 3 4)) 7)
  (check-equal? (run '(- 3 4)) -1)
  (check-equal? (run '(+ (+ 2 1) 4)) 7)
  (check-equal? (run '(+ (+ 2 1) (+ 2 2))) 7)
  (check-equal? (run '(let ((x (+ 1 2)))
                        (let ((z (- 4 x)))
                          (+ (+ x x) z))))
                7)
  (check-equal? (run '(= 5 5)) #t)
  (check-equal? (run '(= 4 5)) #f)
  (check-equal? (run '(= (add1 4) 5)) #t)
  (check-equal? (run '(< 5 5)) #f)
  (check-equal? (run '(< 4 5)) #t)
  (check-equal? (run '(< (add1 4) 5)) #f)
  
  ;; Hustle examples
  (check-equal? (run ''()) '())
  (check-equal? (run '(box 1)) (box 1))
  (check-equal? (run '(box -1)) (box -1))
  (check-equal? (run '(cons 1 2)) (cons 1 2))
  (check-equal? (run '(unbox (box 1))) 1)
  (check-equal? (run '(car (cons 1 2))) 1)
  (check-equal? (run '(cdr (cons 1 2))) 2)
  (check-equal? (run '(cons 1 '())) (list 1))
  (check-equal? (run '(let ((x (cons 1 2)))
                        (begin (cdr x)
                               (car x))))
                1)
  (check-equal? (run '(let ((x (cons 1 2)))
                        (let ((y (box 3)))
                          (unbox y))))
                3)
  (check-equal? (run '(eq? 1 1)) #t)
  (check-equal? (run '(eq? 1 2)) #f)
  (check-equal? (run '(eq? (cons 1 2) (cons 1 2))) #f)
  (check-equal? (run '(let ((x (cons 1 2))) (eq? x x))) #t)  

  ;; Hoax examples
  (check-equal? (run '(make-vector 0 0)) #())
  (check-equal? (run '(make-vector 1 0)) #(0))
  (check-equal? (run '(make-vector 3 0)) #(0 0 0))
  (check-equal? (run '(make-vector 3 5)) #(5 5 5))
  (check-equal? (run '(vector? (make-vector 0 0))) #t)
  (check-equal? (run '(vector? (cons 0 0))) #f)
  (check-equal? (run '(vector-ref (make-vector 0 #f) 0)) 'err)
  (check-equal? (run '(vector-ref (make-vector 3 5) -1)) 'err)
  (check-equal? (run '(vector-ref (make-vector 3 5) 0)) 5)
  (check-equal? (run '(vector-ref (make-vector 3 5) 1)) 5)
  (check-equal? (run '(vector-ref (make-vector 3 5) 2)) 5)
  (check-equal? (run '(vector-ref (make-vector 3 5) 3)) 'err)
  (check-equal? (run '(let ((x (make-vector 3 5)))
                        (begin (vector-set! x 0 4)
                               x)))
                #(4 5 5))
  (check-equal? (run '(let ((x (make-vector 3 5)))
                        (begin (vector-set! x 1 4)
                               x)))
                #(5 4 5))
  (check-equal? (run '(vector-length (make-vector 3 #f))) 3)
  (check-equal? (run '(vector-length (make-vector 0 #f))) 0)
  (check-equal? (run '"") "")
  (check-equal? (run '"fred") "fred")
  (check-equal? (run '"wilma") "wilma")
  (check-equal? (run '(make-string 0 #\f)) "")
  (check-equal? (run '(make-string 3 #\f)) "fff")
  (check-equal? (run '(make-string 3 #\g)) "ggg")
  (check-equal? (run '(string-length "")) 0)
  (check-equal? (run '(string-length "fred")) 4)
  (check-equal? (run '(string-ref "" 0)) 'err)
  (check-equal? (run '(string-ref (make-string 0 #\a) 0)) 'err)
  (check-equal? (run '(string-ref "fred" 0)) #\f)
  (check-equal? (run '(string-ref "fred" 1)) #\r)
  (check-equal? (run '(string-ref "fred" 2)) #\e)
  (check-equal? (run '(string-ref "fred" 4)) 'err)
  (check-equal? (run '(string? "fred")) #t)
  (check-equal? (run '(string? (cons 1 2))) #f)
  (check-equal? (run '(begin (make-string 3 #\f)
                             (make-string 3 #\f)))
                "fff")

  ;; Iniquity tests  
  (check-equal? (run
                 '(define (f x) x)
                 '(f 5))
                5)

  (check-equal? (run
                 '(define (tri x)
                    (if (zero? x)
                        0
                        (+ x (tri (sub1 x)))))
                 '(tri 9))
                45)

  (check-equal? (run
                 '(define (f x) x)
                 '(define (g x) (f x))
                 '(g 5))
                5)  
  (check-equal? (run
                 '(define (even? x)
                    (if (zero? x)
                        #t
                        (odd? (sub1 x))))
                 '(define (odd? x)
                    (if (zero? x)
                        #f
                        (even? (sub1 x))))
                 '(even? 101))
                #f)
  (check-equal? (run
                 '(define (map-add1 xs)
                    (if (empty? xs)
                        '()
                        (cons (add1 (car xs))
                              (map-add1 (cdr xs)))))
                 '(map-add1 (cons 1 (cons 2 (cons 3 '())))))
                '(2 3 4))
  (check-equal? (run
                 '(define (f x)
                    10)
                 '(f 1))
                10)
  (check-equal? (run
                 '(define (f x)
                     10)
                 '(let ((x 2)) (f 1)))
                10)
  (check-equal? (run
                 '(define (f x y)
                    10)
                 '(f 1 2))
                10)
  (check-equal? (run
                 '(define (f x y)
                    10)
                 '(let ((z 2)) (f 1 2)))
                10)
  (check-equal? (run '(define (f x y) y)
                     '(f 1 (add1 #f)))
                'err)

  ;; Knock examples
  (check-equal? (run '(match 1)) 'err)
  (check-equal? (run '(match 1 [1 2]))
                2)
  (check-equal? (run '(match 1 [2 1] [1 2]))
                2)
  (check-equal? (run '(match 1 [2 1] [1 2] [0 3]))
                2)
  (check-equal? (run '(match 1 [2 1] [0 3]))
                'err)
  (check-equal? (run '(match 1 [_ 2] [_ 3]))
                2)
  (check-equal? (run '(match 1 [x 2] [_ 3]))
                2)
  (check-equal? (run '(match 1 [x x] [_ 3]))
                1)
  (check-equal? (run '(match (cons 1 2) [x x] [_ 3]))
                (cons 1 2))
  (check-equal? (run '(match (cons 1 2) [(cons x y) x] [_ 3]))
                1)
  (check-equal? (run '(match (cons 1 2) [(cons x 2) x] [_ 3]))
                1)
  (check-equal? (run '(match (cons 1 2) [(cons 3 2) 0] [_ 3]))
                3)
  (check-equal? (run '(match 1 [(cons x y) x] [_ 3]))
                3)
  (check-equal? (run '(match (cons 1 2) [(cons 1 3) 0] [(cons 1 y) y] [_ 3]))
                2)
  (check-equal? (run '(match (box 1) [(box 1) 0] [_ 1]))
                0)
  (check-equal? (run '(match (box 1) [(box 2) 0] [_ 1]))
                1)
  (check-equal? (run '(match (box 1) [(box x) x] [_ 2]))
                1)

  ;; Loot examples
  (check-true (procedure? (run '(λ (x) x))))
  (check-equal? (run '((λ (x) x) 5))
                5)
  
  (check-equal? (run '(let ((f (λ (x) x))) (f 5)))
                5)
  (check-equal? (run '(let ((f (λ (x y) x))) (f 5 7)))
                5)
  (check-equal? (run '(let ((f (λ (x y) y))) (f 5 7)))
                7) 
  (check-equal? (run '((let ((x 1))
                         (let ((y 2))
                           (lambda (z) (cons x (cons y (cons z '()))))))
                       3))
                '(1 2 3)) 
  (check-equal? (run '(define (adder n)
                        (λ (x) (+ x n)))
                     '((adder 5) 10))
                15) 
  (check-equal? (run '(((λ (t)
                          ((λ (f) (t (λ (z) ((f f) z))))
                           (λ (f) (t (λ (z) ((f f) z))))))
                        (λ (tri)
                          (λ (n)
                            (if (zero? n)
                                0
                                (+ n (tri (sub1 n)))))))
                       36))
                666)
  (check-equal? (run '(define (tri n)
                        (if (zero? n)
                            0
                            (+ n (tri (sub1 n)))))
                     '(tri 36))
                666)
  (check-equal? (run '(define (tri n)
                        (match n
                          [0 0]
                          [m (+ m (tri (sub1 m)))]))
                     '(tri 36))
                666)
  (check-equal? (run '((match 8 [8 (lambda (x) x)]) 12))
                12)

  ;; Mug examples
  (check-equal? (run '(symbol? 'foo)) #t)
  (check-equal? (run '(symbol? (string->symbol "foo"))) #t)
  (check-equal? (run '(eq? 'foo 'foo)) #t)
  (check-equal? (run '(eq? (string->symbol "foo")
                           (string->symbol "foo")))
                #t)
  (check-equal? (run '(eq? 'foo (string->symbol "foo")))
                #t)
  (check-equal? (run '(eq? 'fff (string->symbol (make-string 3 #\f))))
                #t)
  (check-equal? (run '(symbol? 'g0)) #t)
  (check-equal? (run '(symbol? "g0")) #f)
  (check-equal? (run '(symbol? (string->symbol "g0"))) #t)
  (check-equal? (run '(symbol? (string->uninterned-symbol "g0"))) #t)
  (check-equal? (run '(eq? 'g0 (string->symbol "g0"))) #t)
  (check-equal? (run '(eq? 'g0 (string->uninterned-symbol "g0"))) #f)
  (check-equal? (run '(eq? (string->uninterned-symbol "g0") (string->uninterned-symbol "g0")))
                #f)
  (check-equal? (run '(eq? (symbol->string 'foo) (symbol->string 'foo))) #f)
  (check-equal? (run '(string? (symbol->string 'foo))) #t)
  (check-equal? (run '(eq? (symbol->string 'foo) "foo")) #f)
  (check-equal? (run ''foo) 'foo)
  (check-equal? (run '(eq? (match #t [_ "foo"]) "bar")) #f)
  (check-equal? (run '(eq? (match #t [_ 'foo]) 'bar)) #f)
  (check-equal? (run '(match 'foo ['bar #t] [_ #f])) #f)
  (check-equal? (run '(match 'foo ['foo #t] [_ #f])) #t)
  (check-equal? (run '(match "foo" ["foo" #t] [_ #f])) #t)
  (check-equal? (run '(match "foo" ["bar" #t] [_ #f])) #f)
  (check-equal? (run '(match (cons '+ (cons 1 (cons 2 '())))
                        [(cons '+ (cons x (cons y '())))
                         (+ x y)]))
                3)

  ;; Mountebank examples  
  (check-equal? (run '#())
                #())
  (check-equal? (run ''#())
                #())
  (check-equal? (run ''#t)
                #t)
  (check-equal? (run ''7)
                7)
  (check-equal? (run ''(1 2 3))
                '(1 2 3))
  (check-equal? (run ''(1 . 2))
                '(1 . 2))
  (check-equal? (run ''(("1") (#() #(1 #(2))) (#&(1)) (#f) (4) (5)))
                '(("1") (#() #(1 #(2))) (#&(1)) (#f) (4) (5)))  
  (check-equal? (run '(define (f) (cons 1 2))
                     '(eq? (f) (f)))
                #f)
  (check-equal? (run '(define (f) '(1 . 2))
                     '(eq? (f) (f)))
                #t)
  (check-equal? (run '(let ((x '(foo . foo)))
                        (eq? (car x) (cdr x))))
                #t)
  (check-equal?
   (run '(define (eval e r)
           (match e
             [(list 'zero? e)
              (zero? (eval e r))]
             [(list 'sub1 e)
              (sub1 (eval e r))]
             [(list '+ e1 e2)
              (+ (eval e1 r) (eval e2 r))]
             [(list 'if e1 e2 e3)
              (if (eval e1 r)
                  (eval e2 r)
                  (eval e3 r))]
             [(list 'λ (list x) e)
              (lambda (v) (eval e (cons (cons x v) r)))]
             [(list e1 e2)
              ((eval e1 r) (eval e2 r))]
             [_
              (if (symbol? e)
                  (lookup r e)
                  e)]))
        '(define (lookup r x)
           (match r
             [(cons (cons y v) r)
              (if (eq? x y)
                  v
                  (lookup r x))]))
        '(eval '(((λ (t)
                    ((λ (f) (t (λ (z) ((f f) z))))
                     (λ (f) (t (λ (z) ((f f) z))))))
                  (λ (tri)
                    (λ (n)
                      (if (zero? n)
                          0
                          (+ n (tri (sub1 n)))))))
                 36)
               '()))
   666))

(define (test-runner-io run)
  ;; Evildoer examples
  (check-equal? (run "" 7) (cons 7 ""))
  (check-equal? (run "" '(write-byte 97)) (cons (void) "a"))
  (check-equal? (run "a" '(read-byte)) (cons 97 ""))
  (check-equal? (run "b" '(begin (write-byte 97) (read-byte)))
                (cons 98 "a"))
  (check-equal? (run "" '(read-byte)) (cons eof ""))
  (check-equal? (run "" '(eof-object? (read-byte))) (cons #t ""))
  (check-equal? (run "a" '(eof-object? (read-byte))) (cons #f ""))
  (check-equal? (run "" '(begin (write-byte 97) (write-byte 98)))
                (cons (void) "ab"))

  (check-equal? (run "ab" '(peek-byte)) (cons 97 ""))
  (check-equal? (run "ab" '(begin (peek-byte) (read-byte))) (cons 97 ""))
  ;; Extort examples
  (check-equal? (run "" '(write-byte #t)) (cons 'err ""))

  ;; Fraud examples
  (check-equal? (run "" '(let ((x 97)) (write-byte x))) (cons (void) "a"))
  (check-equal? (run ""
                     '(let ((x 97))
                        (begin (write-byte x)
                               x)))
                (cons 97 "a"))
  (check-equal? (run "b" '(let ((x 97)) (begin (read-byte) x)))
                (cons 97 ""))
  (check-equal? (run "b" '(let ((x 97)) (begin (peek-byte) x)))
                (cons 97 ""))

  ;; Hustle examples
  (check-equal? (run ""
                     '(let ((x 1))
                        (begin (write-byte 97)
                               1)))
                (cons 1 "a"))

  (check-equal? (run ""
                     '(let ((x 1))
                        (let ((y 2))
                          (begin (write-byte 97)
                                 1))))
                (cons 1 "a"))

  (check-equal? (run ""
                     '(let ((x (cons 1 2)))
                        (begin (write-byte 97)
                               (car x))))
                (cons 1 "a"))
  ;; Iniquity examples
  #|
  (check-equal? (run ""
                     '(define (print-alphabet i)
                        (if (zero? i)
                            (void)
                            (begin (write-byte (- 123 i))
                                   (print-alphabet (sub1 i)))))
                     '(print-alphabet 26))
                (cons (void) "abcdefghijklmnopqrstuvwxyz"))
|#)
