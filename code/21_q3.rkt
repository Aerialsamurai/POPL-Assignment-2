#lang racket/base
;; S1: Binary Tree Traversals
;; A tree is () or (value left right).
;; Each traversal threads an accumulator: the values of the subtree are consed
;; in front of acc, so the result comes out in order without append or reverse.

;; tree accessors for a node (value left right)
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

;; (inorder t), (preorder t), (postorder t): the traversal lists of t
(define (inorder t) (inorder-acc t '()))
(define (preorder t) (preorder-acc t '()))
(define (postorder t) (postorder-acc t '()))
