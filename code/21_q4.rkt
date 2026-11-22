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
