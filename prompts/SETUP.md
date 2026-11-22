SETUP — Skills
Prompt 1 — Prolog skill
Create skills/prolog-dev/SKILL.md for SWI-Prolog 9.x. Include YAML frontmatter with name and description, naming conventions, and require every predicate to have a comment explaining its mode and declarative meaning. Include instructions for running files using swipl -q -f file.pl -g goal -t halt and writing/running plunit tests. Add a self-review checklist and common AI mistakes in Prolog. Do not allow assert, retract, global variables, initialization directives, halt, or libraries other than lists, apply, yall and aggregate. Keep it practical and concise.
Prompt 2 — Scheme skill
Create skills/scheme-dev/SKILL.md for Racket 8.x using #lang racket/base. Include YAML frontmatter, coding conventions, a self-review checklist, and common AI mistakes in Scheme.
The only allowed built-ins are define, lambda, let, let*, letrec, named let, if, cond, and, or, not, begin, quote, cons, car, cdr, list, c[ad]r compositions up to four levels, null?, pair?, eq?, assq, assoc, +, -, *, , =, =, max, display, newline, and read for Q4. Clearly list forbidden constructs and functions.
Solution files must contain definitions only. Tests should be run by copying the solution file and appending test calls to the copy. Save the skill in the specified path.

Prompt 3 — Group number change
also updated group number is 47
