#lang racket/base

(define (node-value t) (car t))
(define (node-left t) (cadr t))
(define (node-right t) (caddr t))


(define (inorder-acc t acc)
  (if (null? t)
      acc
      (inorder-acc (node-left t)
                   (cons (node-value t)
                         (inorder-acc (node-right t) acc)))))

(define (preorder-acc t acc)
  (if (null? t)
      acc
      (cons (node-value t)
            (preorder-acc (node-left t)
                          (preorder-acc (node-right t) acc)))))

(define (postorder-acc t acc)
  (if (null? t)
      acc
      (postorder-acc (node-left t)
                     (postorder-acc (node-right t)
                                    (cons (node-value t) acc)))))

(define (inorder t) (inorder-acc t '()))
(define (preorder t) (preorder-acc t '()))
(define (postorder t) (postorder-acc t '()))

(define (height t)
  (if (null? t)
      0
      (+ 1 (max (height (node-left t)) (height (node-right t))))))


(define (count-leaves-acc t acc)
  (cond ((null? t) acc)
        ((and (null? (node-left t)) (null? (node-right t))) (+ acc 1))
        (else (count-leaves-acc (node-right t)
                                (count-leaves-acc (node-left t) acc)))))


(define (count-leaves t) (count-leaves-acc t 0))

(define (display-line v)
  (display v)
  (newline))

(define (print-inorder tree)
  (display-line (inorder tree)))

(define (print-all-traversals tree)
  (display-line (inorder tree))
  (display-line (preorder tree))
  (display-line (postorder tree)))

(define (print-height-and-leaves tree)
  (display-line (list (height tree) (count-leaves tree))))
