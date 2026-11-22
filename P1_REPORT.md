# P1 Report: Department Assignment Puzzle, Reloaded

## Value of N for clues 1 to 8

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

The three solutions (Alex, Ben, Carla, Dana as `[Dept, Lang, Project]`):

| # | Alex | Ben | Carla | Dana |
|---|------|-----|-------|------|
| A | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| B | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| C | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

## What N = 3 tells us

The puzzle as given is **under-constrained**: clues 1 to 8 are consistent (N > 0), but they do not
determine a unique answer (N > 1). Some facts are forced in every solution: Ben always works in
development, likes JavaScript and prefers web; Java always goes with design and Python with testing;
whoever prefers data is in research and likes C++. What the clues leave open is which of the other
three friends takes which of the remaining combinations, so `main/0` can only print *one* of the three
valid answers (it prints A, the first one found).

For comparison, the count without any clues is 4!^3 = 13824, so the eight clues remove all but 3
assignments.

## Repair (P1.c)

```prolog
% CLUE 9: The friend who prefers the AI project works in the testing department.
clue(9, S) :-
    forall(member(p(_, Dept, _, 'AI'), S), Dept == testing).
```

Clue 9 is true in solution B (Carla: testing, AI) and false in A (AI is in design) and C (AI is in
design). It names no friend, only attribute values. With it:

```
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```

The unique solution is B:

```
Alex = [design, java, embedded]
Ben = [development, javascript, web]
Carla = [testing, python, AI]
Dana = [research, c++, data]
```
