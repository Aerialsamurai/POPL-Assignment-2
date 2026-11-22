#lang racket/base
;; S1: Binary Tree Traversals
;; A tree is () or (value left right).
;; Each traversal threads an accumulator: the values of the subtree are consed
;; in front of acc, so the result comes out in order without append or reverse.

;; tree accessors
(define (node-value t) (car t))
(define (node-left t) (cadr t))
(define (node-right t) (caddr t))

;; (inorder-acc t acc) = inorder(t) followed by acc
(define (inorder-acc t acc)
  (if (null? t)
      acc
      (inorder-acc (node-left t)
                   (cons (node-value t)
                         (inorder-acc (node-right t) acc)))))

;; (preorder-acc t acc) = preorder(t) followed by acc
(define (preorder-acc t acc)
  (if (null? t)
      acc
      (cons (node-value t)
            (preorder-acc (node-left t)
                          (preorder-acc (node-right t) acc)))))

;; (postorder-acc t acc) = postorder(t) followed by acc
(define (postorder-acc t acc)
  (if (null? t)
      acc
      (postorder-acc (node-left t)
                     (postorder-acc (node-right t)
                                    (cons (node-value t) acc)))))

(define (inorder t) (inorder-acc t '()))
(define (preorder t) (preorder-acc t '()))
(define (postorder t) (postorder-acc t '()))

;; height of () is 0; a node is 1 + the larger subtree height
(define (height t)
  (if (null? t)
      0
      (+ 1 (max (height (node-left t)) (height (node-right t))))))

;; (count-leaves-acc t acc) = number of leaves in t plus acc
(define (count-leaves-acc t acc)
  (cond ((null? t) acc)
        ((and (null? (node-left t)) (null? (node-right t))) (+ acc 1))
        (else (count-leaves-acc (node-right t)
                                (count-leaves-acc (node-left t) acc)))))

(define (count-leaves t) (count-leaves-acc t 0))

;; print one value followed by a newline
(define (display-line v)
  (display v)
  (newline))

;; S1.a
(define (print-inorder tree)
  (display-line (inorder tree)))

;; S1.b
(define (print-all-traversals tree)
  (display-line (inorder tree))
  (display-line (preorder tree))
  (display-line (postorder tree)))

;; S1.c
(define (print-height-and-leaves tree)
  (display-line (list (height tree) (count-leaves tree))))
