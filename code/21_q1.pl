% P1: Department Assignment Puzzle, Reloaded
% SWI-Prolog 9.x.  Run:  swipl -q -f 21_q1.pl -g main -t halt
%
% A solution is a list [p('Alex',D,L,P), p('Ben',..), p('Carla',..), p('Dana',..)]
% where p(Name, Department, Language, Project).

:- use_module(library(lists)).

% ---------------------------------------------------------------------------
% Domains
% ---------------------------------------------------------------------------

% departments(-Ds), languages(-Ls), projects(-Ps): the four values of each attribute.
departments([research, development, design, testing]).
languages([python, java, 'c++', javascript]).
projects(['AI', web, embedded, data]).

% all_clues(-Ns): the clue numbers of the original puzzle.
all_clues([1, 2, 3, 4, 5, 6, 7, 8]).

% candidate(-S): S is an assignment, in the order Alex, Ben, Carla, Dana, in
% which every department, language and project is used by exactly one friend.
candidate([p('Alex',  D1, L1, P1),
           p('Ben',   D2, L2, P2),
           p('Carla', D3, L3, P3),
           p('Dana',  D4, L4, P4)]) :-
    departments(Ds), permutation(Ds, [D1, D2, D3, D4]),
    languages(Ls),   permutation(Ls, [L1, L2, L3, L4]),
    projects(Ps),    permutation(Ps, [P1, P2, P3, P4]).

% ---------------------------------------------------------------------------
% Clues.  clue(+N, +S) holds exactly when clue N is true in the fully
% instantiated solution S.  "The friend who ..." clues use forall/2:
% "every friend who ... also ...".
% ---------------------------------------------------------------------------

% 1. The friend who prefers AI does not work in research and is not Dana.
clue(1, S) :-
    forall(member(p(Name, Dept, _, 'AI'), S),
           ( Dept \== research, Name \== 'Dana' )).

% 2. Alex does not work in development and does not prefer C++.
clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.

% 3. The friend working in testing likes Python.
clue(3, S) :-
    forall(member(p(_, testing, Lang, _), S), Lang == python).

% 4. Ben prefers web projects and does not work in testing.
clue(4, S) :-
    memberchk(p('Ben', Dept, _, Proj), S),
    Proj == web,
    Dept \== testing.

% 5. The friend whose favorite language is Java works in design.
clue(5, S) :-
    forall(member(p(_, Dept, java, _), S), Dept == design).

% 6. Carla does not prefer embedded and does not work in development.
clue(6, S) :-
    memberchk(p('Carla', Dept, _, Proj), S),
    Proj \== embedded,
    Dept \== development.

% 7. Dana does not prefer Java and works in research or testing.
clue(7, S) :-
    memberchk(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    memberchk(Dept, [research, testing]).

% 8. The friend who prefers data works in research and does not use JavaScript.
clue(8, S) :-
    forall(member(p(_, Dept, Lang, data), S),
           ( Dept == research, Lang \== javascript )).

% ---------------------------------------------------------------------------
% Solving and counting
% ---------------------------------------------------------------------------

% satisfies(+Active, +S): every clue whose number is in Active holds in S.
satisfies(Active, S) :-
    forall(member(N, Active), clue(N, S)).

% solve(+Active, -S): S is a candidate satisfying the clues in Active;
% clues not in Active are ignored.
solve(Active, S) :-
    candidate(S),
    satisfies(Active, S).

% count_solutions(+Active, -N): N is the number of candidates satisfying
% exactly the clues in Active.
count_solutions(Active, N) :-
    findall(S, solve(Active, S), Solutions),
    length(Solutions, N).

% print_friend(+P): prints one line "Name = [Dept, Lang, Project]".
print_friend(p(Name, Dept, Lang, Proj)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Proj]).

% main: derives one solution of clues 1-8 and prints it, Alex to Dana.
main :-
    all_clues(Active),
    once(solve(Active, S)),
    forall(member(P, S), print_friend(P)).
