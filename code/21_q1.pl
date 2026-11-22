% P1: Department Assignment Puzzle, Reloaded
% SWI-Prolog 9.x.  Run:  swipl -q -f 21_q1.pl -g main -t halt
%
% A solution is a list [p('Alex',D,L,P), p('Ben',..), p('Carla',..), p('Dana',..)]
% where p(Name, Dept, Lang, Project).

:- use_module(library(lists)).

% ---------------------------------------------------------------------------
% Domains
% ---------------------------------------------------------------------------

departments([research, development, design, testing]).
languages([python, java, 'c++', javascript]).
projects(['AI', web, embedded, data]).

all_clues([1, 2, 3, 4, 5, 6, 7, 8]).

% candidate(-Solution)
% Solution is any assignment in which each department, language and project
% is used by exactly one friend (a permutation of each domain).
candidate([p('Alex',  D1, L1, P1),
           p('Ben',   D2, L2, P2),
           p('Carla', D3, L3, P3),
           p('Dana',  D4, L4, P4)]) :-
    departments(Ds), permutation(Ds, [D1, D2, D3, D4]),
    languages(Ls),   permutation(Ls, [L1, L2, L3, L4]),
    projects(Ps),    permutation(Ps, [P1, P2, P3, P4]).

% ---------------------------------------------------------------------------
% Clues.  clue(N, S) holds exactly when clue N is true in the filled-in S.
% "The friend who ..." clues are written with forall/2, so they read as
% "every friend who ... also ...".
% ---------------------------------------------------------------------------

% 1. The friend who prefers the AI project does not work in research and is not Dana.
clue(1, S) :-
    forall(member(p(Name, Dept, _, 'AI'), S),
           ( Dept \== research, Name \== 'Dana' )).

% 2. Alex does not work in development and does not prefer C++.
clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.

% 3. The friend working in the testing department likes Python.
clue(3, S) :-
    forall(member(p(_, testing, Lang, _), S), Lang == python).

% 4. Ben prefers web projects and does not work in testing.
clue(4, S) :-
    memberchk(p('Ben', Dept, _, Proj), S),
    Proj == web,
    Dept \== testing.

% 5. The friend whose favorite language is Java works in the design department.
clue(5, S) :-
    forall(member(p(_, Dept, java, _), S), Dept == design).

% 6. Carla's project preference is not embedded, and her department is not development.
clue(6, S) :-
    memberchk(p('Carla', Dept, _, Proj), S),
    Proj \== embedded,
    Dept \== development.

% 7. Dana's favorite language is not Java, and she works in research or testing.
clue(7, S) :-
    memberchk(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    memberchk(Dept, [research, testing]).

% 8. The friend who prefers data projects works in research and does not use JavaScript.
clue(8, S) :-
    forall(member(p(_, Dept, Lang, data), S),
           ( Dept == research, Lang \== javascript )).

% CLUE 9: The friend who prefers the AI project works in the testing department.
clue(9, S) :-
    forall(member(p(_, Dept, _, 'AI'), S), Dept == testing).

% ---------------------------------------------------------------------------
% Solving and counting
% ---------------------------------------------------------------------------

% satisfies(+Active, +S): every clue whose number is in Active holds in S.
satisfies(Active, S) :-
    forall(member(N, Active), clue(N, S)).

% solve(+Active, -S): S is a candidate that satisfies exactly the clues in Active.
solve(Active, S) :-
    candidate(S),
    satisfies(Active, S).

% count_solutions(+Active, -N): N solutions satisfy the clues in Active
% (all other clues are ignored).
count_solutions(Active, N) :-
    findall(S, solve(Active, S), Solutions),
    length(Solutions, N).

% print_friend(+P): print one line "Name = [Dept, Lang, Project]".
print_friend(p(Name, Dept, Lang, Proj)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Proj]).

% main: derive one solution of clues 1..8 and print it, Alex to Dana.
main :-
    all_clues(Active),
    once(solve(Active, S)),
    forall(member(P, S), print_friend(P)).
