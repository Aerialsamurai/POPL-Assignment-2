---
name: scheme-dev
description: Rules for writing, testing and reviewing restricted Racket 8.x (#lang racket/base) code for the CS F301 assignment - allowed and forbidden built-ins, conventions, test workflow, self-review checklist and common AI mistakes.
---

# scheme-dev

## Environment
- Racket 8.x. Every solution file starts with `#lang racket/base`.
- Solution files contain **definitions only**: no top-level calls, nothing printed when the file is loaded. The grader appends its own calls and runs `racket id_qN.rkt`.

## Allowed built-ins (the complete list)
`define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` (`'`), `cons`, `car`, `cdr`, `list`, compositions of `car`/`cdr` up to four levels (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, ...), `null?`, `pair?`, `eq?`, `assq`, `assoc`, `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`, `display`, `newline`.
Q4 (`id_q4.rkt`) may also use `read`.

## Forbidden (examples, not exhaustive: anything not listed above is forbidden)
- Mutation: `set!`, `set-car!`, `set-cdr!`, boxes.
- Data structures: vectors, hash tables, strings, characters.
- Loops: `do`, `for`, `for/list` and every other `for` form.
- List library: `length`, `append`, `reverse`, `map`, `filter`, `foldl`, `foldr`, `member`, `memq`, `list-ref`, `list-tail`, `apply`.
- Others: `when`, `unless`, `printf`, `write`, `equal?`, `list?`, `number?`, `symbol?`, `void`, `require`, `provide`, `define-values`.
- Write your own helpers instead (`my-length`, `my-map`, `my-reverse`).

## Conventions
- `kebab-case` names; predicates end in `?`; accumulator helpers end in `-acc`.
- A comment above each function gives its recursive reading, e.g. `;; (inorder-acc t acc) = inorder of t followed by acc`.
- All state passes through arguments.
- Recursion over list length is tail recursive (named `let` with an accumulator); recursion over tree or nesting depth may be ordinary recursion.
- Printing: `display` the value, then `newline`.

## Testing
- Never put test calls in the solution file.
- To test: copy the solution file, append the test calls to the copy, run the copy with `racket`, and compare its output with the expected output. For Q4, feed standard input to the run.
- Tests live in `tests/test_qN.rkt` and automate exactly this.
- Cover every example from the assignment plus edge cases (empty tree/list, single element, `n = 0`, deep nesting, long lists).

## Self-review checklist (before answering)
1. Is every identifier either defined in the file or on the allowed list?
2. Does loading the file print nothing?
3. Does every output line end with `newline`?
4. Are empty inputs handled?
5. Is list-length recursion tail recursive?
6. Is element order preserved (left before right, original list order)?
7. Are values (e.g. list lengths) measured on the original input where the spec says so?
8. Is `let*` used where evaluation order matters (sequenced `read` calls)?
9. Has the code actually been run against the tests?

## Common AI mistakes in Scheme
- Using `length`, `append`, `map`, `reverse`, `for/list`, `printf` out of habit.
- Building lists with repeated `append` (quadratic) or non-tail recursion that overflows on long lists.
- Leaving test calls at the top level of the solution file.
- Using `let` instead of `let*` for ordered `read` calls.
- Treating `'()` as an atom and skipping empty sublists.
- Writing `#lang racket` instead of `#lang racket/base`, or adding `require`/`provide`.
- Using `equal?`, `list?`, `number?` instead of the allowed `eq?`, `null?`, `pair?`, `=`.
- Mixing up `cadr`/`caddr` positions in `(value left right)` triples.
