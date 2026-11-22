---
name: scheme-dev
description: Conventions, allowed built-ins, testing workflow, self-review checklist and known AI failure modes for writing restricted Racket (#lang racket/base) solutions in the CS F301 assignment (one function per request).
---

# scheme-dev

## Language and environment
- Racket 8.x. Every solution file starts with `#lang racket/base` and contains definitions only.
- The grader runs `racket id_qN.rkt` after appending its own calls to the end of the file. Loading the file must print nothing; never call your own functions at the top level.

## Allowed built-ins (nothing else)
`define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` (`'`), `cons`, `car`, `cdr`, `list`, `c[ad]{2,4}r` compositions, `null?`, `pair?`, `eq?`, `assq`, `assoc`, `+ - * < > <= >= =`, `max`, `display`, `newline`. S2 additionally allows `read`.

Forbidden: `set!` and relatives, vectors, hash tables, strings, `do`, `for` loops, `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`, `when`, `unless`, `printf`, `void`, `list?`, `number?`, `symbol?`, `equal?`, `apply`, `foldl`, `provide`, `require`. Write helpers instead (`my-length`, `my-map`, `my-reverse`).

## Scope of one request
Work on one unit at a time: one function (plus tiny private helpers), one test file, or one review. Do not write a whole problem in one answer.

## Coding conventions
- Names are `kebab-case`; predicates end in `?`; helpers that thread an accumulator end in `-acc`.
- Each function has a comment with its recursive reading, e.g.
  `;; (inorder-acc t acc) = inorder(t) followed by acc`.
- All state is passed through arguments; no mutation.
- Prefer tail recursion (named `let` loop with an accumulator) for anything that walks a long list; build in reverse and reverse once at the end, or cons from the right with an accumulator so no reverse is needed.
- Recursion on tree/nesting depth may be non-tail; recursion on list length should be tail recursive.
- Output: `display` the value, then `newline`. Displaying `'()` prints `()`.

## How to run and test
- Grader style: copy the code file, append calls, run `racket file.rkt`.
- Tests live in `tests/test_qN.rkt` and do exactly that via a subprocess: `racket tests/test_q3.rkt`.
- Every example from the assignment is a test, plus edge cases: empty tree/list, single node, skewed trees, `n = 0`, length equal to `n`, nesting depth 100, 10,000 elements, input split over several lines for `read`.
- Before submitting, search the file for forbidden names (`length`, `append`, `map`, `reverse`, `set!`, `for`, `string`, `vector`, `hash`).

## Self-review checklist (apply before answering)
1. Is every identifier used either defined in the file or on the allowed list?
2. Does loading the file print nothing (no top-level calls or expressions)?
3. Does each printing function end with exactly one `newline` per line of output?
4. Are empty inputs handled (`'()` tree, `'()` list, `n = 0`)?
5. Is list-length recursion tail recursive so 10,000 elements cannot overflow?
6. Is the order of results correct (left before right; original element order preserved after mapping)?
7. Are lengths measured on the original list, before any insertion?
8. Do inputs get read in the specified order (use `let*` to sequence `read` calls)?
9. Has the code actually been run against the tests (not only reasoned about)?

## Known failure modes of AI tools in Scheme/Racket
- Reaching for `length`, `append`, `map`, `reverse`, `filter`, `for/list`, `string-append`, `printf` even when forbidden.
- Building a list with `append` in a loop (quadratic) or with non-tail recursion that blows up on long lists.
- Forgetting that `(display '())` prints `()` and special-casing it wrongly.
- Using `let` where `let*` is needed, so `read` calls may be evaluated in an unexpected order.
- Treating `'()` as an atom instead of a list when walking nested lists (empty sublists must be processed too).
- Leaving test calls at the top level of the solution file, which prints output when the grader loads it.
- Using `#lang racket` (full) instead of `#lang racket/base`, or adding `(provide ...)`/`(require ...)`.
- Using `list?`/`equal?`/`number?`, which are not on the allowed list; use `null?`/`pair?`/`eq?`/`=`.
- Confusing `cadr`/`caddr` positions in `(value left right)` triples.
