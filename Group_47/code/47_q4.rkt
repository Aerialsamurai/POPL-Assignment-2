#lang racket/base

(define (my-length lst)
  (let loop ((l lst) (n 0))
    (if (null? l)
        n
        (loop (cdr l) (+ n 1)))))


(define (my-reverse lst)
  (let loop ((l lst) (acc '()))
    (if (null? l)
        acc
        (loop (cdr l) (cons (car l) acc)))))


(define (my-map f lst)
  (let loop ((l lst) (acc '()))
    (if (null? l)
        (my-reverse acc)
        (loop (cdr l) (cons (f (car l)) acc)))))

(define (list-value? v)
  (or (null? v) (pair? v)))

(define (make-inserter x len-ok?)
  (letrec ((walk
            (lambda (lst)
              (let ((inner (my-map (lambda (e) (if (list-value? e) (walk e) e))
                                   lst)))
                (if (len-ok? (my-length lst))
                    (cons x inner)
                    inner)))))
    walk))


(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))


(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
