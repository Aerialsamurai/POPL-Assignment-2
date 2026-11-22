# P1 Report: Department Assignment Puzzle

## Solution count for clues 1–8

Running `count_solutions([1,2,3,4,5,6,7,8], N)` gives:

`N = 3`

The puzzle therefore has three valid solutions under the original eight clues.

| Solution | Alex | Ben | Carla | Dana |
|---|---|---|---|---|
| A | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| B | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| C | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

Each entry is shown as `[department, language, project]`.

## What the solution count tells us

The puzzle is **consistent** because at least one assignment satisfies all eight clues. However, it is **not uniquely solvable**, because three assignments satisfy them.

The following facts hold in all three solutions:

- Ben works in development, uses JavaScript, and prefers web.
- Java is associated with the design department.
- Python is associated with the testing department.
- The friend who prefers data works in research and uses C++.

The original clues do not uniquely determine the remaining assignments. Consequently, `main/0` prints one valid solution, but that output should not be interpreted as the only possible solution.

With no clues active, the candidate generator produces `4! × 4! × 4! = 13,824` assignments. Clues 1–8 reduce this to three.

## Clue 9: Repairing the ambiguity

The following additional clue is true in exactly one of the three original solutions and does not name a friend:

`% CLUE 9: The friend who prefers the AI project works in the testing department.`

This clue is satisfied by solution B, where Carla prefers AI and works in testing. It is not satisfied by solutions A or C, where the friend preferring AI works in design.

After adding clue 9, the solution count becomes:

`count_solutions([1,2,3,4,5,6,7,8,9], N)`

`N = 1`

The unique solution is:

| Friend | Department | Language | Project |
|---|---|---|---|
| Alex | design | java | embedded |
| Ben | development | javascript | web |
| Carla | testing | python | AI |
| Dana | research | c++ | data |

Clue 9 resolves the ambiguity, making the puzzle uniquely solvable.
