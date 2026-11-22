#lang racket/base
;; S2: Conditionally Insert into a Nested List
;; Only the allowed built-ins are used; list helpers are written by hand and
;; are tail recursive so that lists of 10,000 elements are safe.

;; (my-length lst): number of top-level elements of lst
(define (my-length lst)
  (let loop ((l lst) (n 0))
    (if (null? l)
        n
        (loop (cdr l) (+ n 1)))))

;; (my-reverse lst): lst in reverse order
(define (my-reverse lst)
  (let loop ((l lst) (acc '()))
    (if (null? l)
        acc
        (loop (cdr l) (cons (car l) acc)))))

;; (my-map f lst): list of (f e) for each top-level element e, in order
(define (my-map f lst)
  (let loop ((l lst) (acc '()))
    (if (null? l)
        (my-reverse acc)
        (loop (cdr l) (cons (f (car l)) acc)))))

;; a list is the empty list or a pair (there are no dotted pairs)
(define (list-value? v)
  (or (null? v) (pair? v)))

;; S2.c (make-inserter x len-ok?): a function that, given a list, processes
;; every sublist (at every level) the same way and puts x in front of each list
;; whose original length satisfies len-ok?
(define (make-inserter x len-ok?)
  (letrec ((walk
            (lambda (lst)
              (let ((inner (my-map (lambda (e) (if (list-value? e) (walk e) e))
                                   lst)))
                (if (len-ok? (my-length lst))
                    (cons x inner)
                    inner)))))
    walk))

;; S2.b / S2.c (insert-if-short x lst n): insert x into every list shorter than n
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; S2.a (print-insert-result): read x, lst and n from standard input, in that
;; order, and print the result followed by a newline
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
