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

;; (insert-if-short x lst n): lst with every sublist (at every level) processed
;; the same way, and x put in front when lst's original length is less than n
(define (insert-if-short x lst n)
  (let ((inner (my-map (lambda (e) (if (list-value? e) (insert-if-short x e n) e))
                       lst)))
    (if (< (my-length lst) n)
        (cons x inner)
        inner)))
