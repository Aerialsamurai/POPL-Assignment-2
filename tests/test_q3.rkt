#lang racket
;; Tests for S1.  Run:  racket tests/test_q3.rkt
;; Each test does what the grader does: append calls to the end of a copy of
;; code/*_q3.rkt, run it with racket, and compare the printed output.

(require racket/runtime-path)
(define-runtime-path here ".")
(define code-dir (build-path here 'up "code"))
(define code-file
  (for/first ([f (directory-list code-dir #:build? #t)]
              #:when (regexp-match? #rx"_q3\\.rkt$" (path->string f)))
    f))
(define racket-exe (find-system-path 'exec-file))
(define racket-path (or (find-executable-path racket-exe) racket-exe))

;; run the code file with `calls` appended; return (values stdout stderr)
(define (run calls [stdin ""])
  (define tmp (make-temporary-file "q3test~a.rkt"))
  (call-with-output-file tmp #:exists 'truncate
    (λ (o) (write-string (file->string code-file) o)
           (write-string "\n" o)
           (write-string calls o)))
  (define out (open-output-string))
  (define err (open-output-string))
  (parameterize ([current-output-port out]
                 [current-error-port err]
                 [current-input-port (open-input-string stdin)])
    (system* racket-path tmp))
  (delete-file tmp)
  (values (get-output-string out) (get-output-string err)))

(define pass 0)
(define fail 0)
(define (check name calls expected)
  (define-values (got err) (run calls))
  (if (and (equal? got expected) (equal? err ""))
      (set! pass (add1 pass))
      (begin (set! fail (add1 fail))
             (printf "FAIL ~a\n  expected: ~s\n  got:      ~s\n  stderr:   ~s\n"
                     name expected got err))))

(define trees
  "(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(define t4 '(9 () ()))
(define t5 '(1 (2 (3 (4 () ()) ()) ()) ()))
(define t6 '(1 (2 () (4 () ())) (3 () ())))
")

;; loading the original solution file (not a copy) must print nothing
(let ([out (open-output-string)] [err (open-output-string)])
  (parameterize ([current-output-port out] [current-error-port err])
    (system* racket-path code-file))
  (if (and (equal? (get-output-string out) "") (equal? (get-output-string err) ""))
      (set! pass (add1 pass))
      (begin (set! fail (add1 fail))
             (printf "FAIL original file prints on load: ~s ~s\n"
                     (get-output-string out) (get-output-string err)))))

;; --- examples from the assignment ---
(check "inorder t1" (string-append trees "(print-inorder t1)") "(1 2 3 4 5 6 7)\n")
(check "all t1" (string-append trees "(print-all-traversals t1)")
       "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n")
(check "hl t1" (string-append trees "(print-height-and-leaves t1)") "(3 4)\n")
(check "all t2" (string-append trees "(print-all-traversals t2)") "(1 2 3)\n(1 2 3)\n(3 2 1)\n")
(check "hl t2" (string-append trees "(print-height-and-leaves t2)") "(3 1)\n")
(check "all t3" (string-append trees "(print-all-traversals t3)") "(b a c)\n(a b c)\n(b c a)\n")
(check "hl t3" (string-append trees "(print-height-and-leaves t3)") "(2 2)\n")
(check "inorder empty" "(print-inorder '())" "()\n")
(check "all empty" "(print-all-traversals '())" "()\n()\n()\n")
(check "hl empty" "(print-height-and-leaves '())" "(0 0)\n")

;; --- edge cases ---
(check "inorder single" (string-append trees "(print-inorder t4)") "(9)\n")
(check "all single" (string-append trees "(print-all-traversals t4)") "(9)\n(9)\n(9)\n")
(check "hl single" (string-append trees "(print-height-and-leaves t4)") "(1 1)\n")
(check "all left chain" (string-append trees "(print-all-traversals t5)")
       "(4 3 2 1)\n(1 2 3 4)\n(4 3 2 1)\n")
(check "hl left chain" (string-append trees "(print-height-and-leaves t5)") "(4 1)\n")
(check "all mixed" (string-append trees "(print-all-traversals t6)")
       "(2 4 1 3)\n(1 2 4 3)\n(4 2 3 1)\n")
(check "hl mixed" (string-append trees "(print-height-and-leaves t6)") "(3 2)\n")
(check "several calls" (string-append trees "(print-inorder t3)\n(print-height-and-leaves t4)")
       "(b a c)\n(1 1)\n")

(printf "S1: ~a passed, ~a failed\n" pass fail)
(when (> fail 0) (exit 1))
