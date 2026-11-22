---
name: prolog-dev
description: Conventions, testing workflow, self-review checklist and known AI failure modes for writing SWI-Prolog 9.x solutions in the CS F301 assignment (one predicate per request).
---

# prolog-dev

## Language and environment
- SWI-Prolog 9.x. Files are plain `.pl` source with definitions only.
- The grader runs `swipl -q -f id_qN.pl -g main -t halt` or `swipl -q -f id_qN.pl -g "<goal>" -t halt`.
- Never call `halt/0`, never add `:- initialization(...)`, never print anything except what the task asks for.
- Allowed libraries only: `lists`, `apply`, `yall`, `aggregate`. Load them with `:- use_module(library(...)).`
- Forbidden: `assert*`, `retract*`, `b_setval`, `nb_setval`, any other global state. Do not build a string and parse it back into a term.

## Scope of one request
Work on one unit at a time: one predicate, one group of closely related clauses, one test file, or one review. Do not write a whole problem in one answer.

## Coding conventions
- Predicate names are `snake_case`; variables are `CamelCase`; use `_` for unused variables.
- Every predicate gets a header comment with its mode and a declarative reading, e.g.
  `% split(+List, -Left, -Right): List = Left ++ Right with both parts non-empty.`
- Write each logical case as its own clause. Prefer pattern matching in the head over `=` in the body.
- Use `forall/2` for "every X that ... also ..." conditions; use `memberchk/2` when a single deterministic lookup is enough.
- Use `->` only inside `( ... ; ... )` and keep the condition small. Avoid `!` unless needed to commit to a result; prefer `once/1` at the call site.
- Arithmetic: `is/2` to compute, `=:=`, `=\=`, `<`, `=<` to compare numbers. Use `==`/`\==` for comparing ground terms, never `=` in a test.
- Strings: `"..."` is a string in SWI-Prolog 9 (double_quotes = codes is NOT the default). Build strings with `format(string(S), Fmt, Args)`.
- Atoms that need quotes: `'Alex'`, `'AI'`, `'c++'`.

## How to run and test
- Interactively: `swipl code/21_q1.pl` then query.
- Single goal as the grader does: `swipl -q -f code/21_q1.pl -g main -t halt`.
- Unit tests (plunit) live in `tests/test_qN.pl` and load the code relative to themselves:
  `swipl -q -f tests/test_q1.pl -g run_tests -t halt`.
- Every example from the assignment is a test; add edge cases (empty list, singleton, zeros, division by zero, already-bound output arguments).

## Self-review checklist (apply before answering)
1. Does the predicate terminate for every documented mode, including empty and one-element lists?
2. Does it fail (rather than throw or loop) where the spec says it must fail?
3. Are there unwanted choice points or duplicate answers on backtracking? Is `findall` + `sort` used where the spec asks for a set?
4. Are all atoms spelled and quoted exactly as the spec says (`'c++'`, `'AI'`)?
5. Is every arithmetic comparison done with an arithmetic operator, and every term comparison with `==`?
6. Is there no `assert`, `retract`, global variable, `halt`, `initialization`, or stray output?
7. Are only allowed libraries used?
8. Does the header comment's declarative reading match what the clauses actually do?
9. Has the code actually been run against the tests (not only reasoned about)?

## Known failure modes of AI tools in Prolog
- Writing `X = Y + 1` and expecting arithmetic; forgetting `is/2`.
- Using `=` instead of `==` in a test, which silently binds variables and makes a check succeed.
- Assuming `"abc"` is a code list or an atom; mixing atoms and strings in comparisons and in `sort/2` output.
- Ordering goals so a generator runs after a test on unbound variables (wrong answers or instantiation errors).
- Left recursion or unbounded generators that loop when the answer does not exist (e.g. `length(L, N)` with both unbound).
- Using `\+` on non-ground goals and expecting it to bind variables.
- Integer division: `/` may produce a float or rational; use `//` after checking `mod` is 0 and the divisor is non-zero.
- Hard-coding an answer to a puzzle instead of deriving it from the constraints.
- Adding `:- initialization(main).` or calling `halt.` out of habit.
- Using `nth0/nth1`/`assoc` or other libraries that are not on the allowed list.
- Claiming a count or a test result without running the code.
