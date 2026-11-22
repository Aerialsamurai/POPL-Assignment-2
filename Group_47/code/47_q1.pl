

:- use_module(library(lists)).



departments([research, development, design, testing]).
languages([python, java, 'c++', javascript]).
projects(['AI', web, embedded, data]).


all_clues([1, 2, 3, 4, 5, 6, 7, 8]).


candidate([p('Alex',  D1, L1, P1),
           p('Ben',   D2, L2, P2),
           p('Carla', D3, L3, P3),
           p('Dana',  D4, L4, P4)]) :-
    departments(Ds), permutation(Ds, [D1, D2, D3, D4]),
    languages(Ls),   permutation(Ls, [L1, L2, L3, L4]),
    projects(Ps),    permutation(Ps, [P1, P2, P3, P4]).


clue(1, S) :-
    forall(member(p(Name, Dept, _, 'AI'), S),
           ( Dept \== research, Name \== 'Dana' )).

clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.


clue(3, S) :-
    forall(member(p(_, testing, Lang, _), S), Lang == python).


clue(4, S) :-
    memberchk(p('Ben', Dept, _, Proj), S),
    Proj == web,
    Dept \== testing.


clue(5, S) :-
    forall(member(p(_, Dept, java, _), S), Dept == design).


clue(6, S) :-
    memberchk(p('Carla', Dept, _, Proj), S),
    Proj \== embedded,
    Dept \== development.

clue(7, S) :-
    memberchk(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    memberchk(Dept, [research, testing]).

clue(8, S) :-
    forall(member(p(_, Dept, Lang, data), S),
           ( Dept == research, Lang \== javascript )).

% CLUE 9: The friend who prefers the AI project works in the testing department.
clue(9, S) :-
    forall(member(p(_, Dept, _, 'AI'), S), Dept == testing).

satisfies(Active, S) :-
    forall(member(N, Active), clue(N, S)).

solve(Active, S) :-
    candidate(S),
    satisfies(Active, S).

count_solutions(Active, N) :-
    findall(S, solve(Active, S), Solutions),
    length(Solutions, N).

print_friend(p(Name, Dept, Lang, Proj)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Proj]).

main :-
    all_clues(Active),
    once(solve(Active, S)),
    forall(member(P, S), print_friend(P)).
