#lang racket
;; Tests for S2.  Run:  racket tests/test_q4.rkt
;; Each test does what the grader does: append calls to the end of a copy of
;; code/*_q4.rkt, run it with racket (feeding stdin), and compare the output.

(require racket/runtime-path)
(define-runtime-path here ".")
(define code-dir (build-path here 'up "code"))
(define code-file
  (for/first ([f (directory-list code-dir #:build? #t)]
              #:when (regexp-match? #rx"_q4\\.rkt$" (path->string f)))
    f))
(define racket-exe (find-system-path 'exec-file))
(define racket-path (or (find-executable-path racket-exe) racket-exe))

;; run the code file with `calls` appended; return (values stdout stderr)
(define (run calls [stdin ""])
  (define tmp (make-temporary-file "q4test~a.rkt"))
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
(define (report name ok? expected got err)
  (if ok?
      (set! pass (add1 pass))
      (begin (set! fail (add1 fail))
             (printf "FAIL ~a\n  expected: ~a\n  got:      ~a\n  stderr:   ~s\n"
                     name (trunc expected) (trunc got) err))))
(define (trunc s) (if (> (string-length s) 200) (string-append (substring s 0 200) "...") s))

;; S2.a: feed stdin to (print-insert-result)
(define (check-io name stdin expected)
  (define-values (got err) (run "(print-insert-result)" stdin))
  (report name (and (equal? got expected) (equal? err "")) expected got err))

;; other functions: run calls, compare stdout
(define (check name calls expected)
  (define-values (got err) (run calls))
  (report name (and (equal? got expected) (equal? err "")) expected got err))

;; loading the file alone must print nothing
(check "load prints nothing" "" "")

;; --- examples from the assignment ---
(check-io "ex1" "42 ((1 2) (3 4 5) (6) ()) 3" "((42 1 2) (3 4 5) (42 6) (42))\n")
(check-io "ex2" "0 (((1) 2) (3) ((4 5 6) ())) 3" "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
(check-io "ex3" "7 () 3" "(7)\n")
(check-io "ex4" "7 () 0" "()\n")

;; --- edge cases ---
(check-io "inputs on separate lines" "42\n((1 2) (3 4 5) (6) ())\n3\n"
          "((42 1 2) (3 4 5) (42 6) (42))\n")
(check-io "symbol x" "a (b (c d) ()) 3" "(b (a c d) (a))\n")
(check-io "n = 0 changes nothing" "x (1 (2 ()) ()) 0" "(1 (2 ()) ())\n")
(check-io "length equal to n is not short" "x (1 2) 2" "(1 2)\n")
(check-io "all lists short" "x (1 (2) (())) 10" "(x 1 (x 2) (x (x)))\n")
(check-io "flat list only top level" "x (1 2 3) 4" "(x 1 2 3)\n")
(check-io "lengths measured before insertion" "x ((1)) 2" "(x (x 1))\n")

;; nesting depth 100: (((...()...))) each level has length 1
(define (nested d) (if (= d 0) "()" (string-append "(" (nested (- d 1)) ")")))
(define (nested-ins d) (if (= d 0) "(x)" (string-append "(x " (nested-ins (- d 1)) ")")))
(check-io "depth 100" (string-append "x " (nested 100) " 2") (string-append (nested-ins 100) "\n"))
;; with n = 1 only the innermost () (length 0) is short
(define (wrap d s) (if (= d 0) s (string-append "(" (wrap (- d 1) s) ")")))
(check-io "depth 100, n=1" (string-append "x " (nested 100) " 1")
          (string-append (wrap 100 "(x)") "\n"))

;; 10,000 elements
(define big (string-join (for/list ([i 10000]) (number->string i)) " "))
(check-io "10000 not short" (string-append "x (" big ") 5") (string-append "(" big ")\n"))
(check-io "10000 short" (string-append "x (" big ") 10001") (string-append "(x " big ")\n"))
(define big-sub (string-join (for/list ([i 10000]) "(1)") " "))
(define big-sub-ins (string-join (for/list ([i 10000]) "(x 1)") " "))
(check-io "10000 sublists" (string-append "x (" big-sub ") 2") (string-append "(" big-sub-ins ")\n"))

;; S2.b helpers
(check "my-length" "(display (list (my-length '()) (my-length '(1 (2 3) ()))))" "(0 3)")
(check "my-map" "(display (my-map (lambda (v) (* v v)) '(1 2 3)))" "(1 4 9)")
(check "my-map empty" "(display (my-map (lambda (v) v) '()))" "()")
(check "insert-if-short direct" "(display (insert-if-short 'z '(1 (2 3 4) ()) 2))"
       "(1 (2 3 4) (z))")

;; S2.c make-inserter with other predicates
(check "make-inserter even lengths"
       "(display ((make-inserter 'e (lambda (k) (= k 2))) '((1 2) (3) (4 5))))"
       "((e 1 2) (3) (e 4 5))")
(check "make-inserter long lists"
       "(display ((make-inserter 0 (lambda (k) (> k 1))) '(1 (2 3) (4))))"
       "(0 1 (0 2 3) (4))")
(check "make-inserter returns a procedure"
       "(define f (make-inserter 'q (lambda (k) (< k 1)))) (display (f '(() (()))))"
       "((q) ((q)))")

(printf "S2: ~a passed, ~a failed\n" pass fail)
(when (> fail 0) (exit 1))
