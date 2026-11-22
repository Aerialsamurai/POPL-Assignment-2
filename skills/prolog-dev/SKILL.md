---
name: prolog-dev
description: Practical rules for writing, running and reviewing SWI-Prolog 9.x code for the CS F301 assignment - conventions, restrictions, plunit testing, a self-review checklist and common AI mistakes.
---

# prolog-dev

## Environment and restrictions
- SWI-Prolog 9.x. Solution files contain definitions only.
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate` (load with `:- use_module(library(...)).`). Nothing else.
- Forbidden: `assert*`, `retract*`, global variables (`b_setval`, `nb_setval`), any `initialization` directive, calling `halt`.
- Print only what the task asks for.

## Conventions
- Predicates `snake_case`, variables `CamelCase`, `_` for unused variables.
- Every predicate has a comment above it giving its mode and its declarative meaning:
  `% split(+List, -Left, -Right): List is Left followed by Right, both non-empty.`
- One clause per logical case; prefer head unification to `=` in the body.
- `forall/2` for "every X that ... also ..." conditions; `memberchk/2` for a single deterministic lookup.
- Compute with `is/2`, compare numbers with `=:= =\= < =<`, compare ground terms with `== \==`.
- `"..."` is a string in SWI-Prolog 9; build strings with `format(string(S), Fmt, Args)`.
- Quote atoms that need it: `'Alex'`, `'AI'`, `'c++'`.

## Running
- Main goal, as the grader does: `swipl -q -f code/47_q1.pl -g main -t halt`
- Any other goal: `swipl -q -f code/47_q1.pl -g "count_solutions([1,2,3],N), writeln(N)" -t halt`
- A goal that fails exits with status 1; one that succeeds exits with 0.

## Testing with plunit
- One test file per problem: `tests/test_qN.pl`. It loads the solution relative to its own directory, then wraps tests in `:- begin_tests(name).` ... `:- end_tests(name).`
- Test forms: `test(name) :- Goal.`, `test(name, [fail]) :- Goal.`, `test(name, [true(X == Expected)]) :- Goal.`
- Run: `swipl -q -f tests/test_q1.pl -g run_tests -t halt`
- Cover every example from the assignment plus edge cases, and both passing and failing inputs.

## Self-review checklist (before answering)
1. Terminates in every documented mode, including empty and one-element inputs?
2. Fails (not loops or throws) where the spec says it should fail?
3. No duplicate answers or unwanted choice points?
4. Atoms spelled and quoted exactly as in the spec?
5. Arithmetic vs term comparison operators used correctly?
6. No forbidden predicates, libraries, directives or stray output?
7. Each comment's declarative meaning matches the clauses?
8. Code actually run against the tests?

## Common AI mistakes in Prolog
- `X = Y + 1` instead of `X is Y + 1`.
- `=` used as a test, silently binding variables.
- Mixing up strings, atoms and code lists.
- Testing variables before the generator has bound them.
- Generators that never terminate when no answer exists.
- `/` producing a float where `//` with an exactness check was needed.
- Hard-coding a puzzle answer instead of deriving it.
- Adding `:- initialization(main).` or `halt.` by habit.
- Reporting a count or test result without running the code.
