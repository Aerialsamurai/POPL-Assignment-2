% Tests for P1.  Run from anywhere:
%   swipl -q -f tests/test_q1.pl -g run_tests -t halt
% Loads the *_q1.pl file in ../code relative to this test file.

:- use_module(library(plunit)).
:- use_module(library(lists)).

:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../code/*_q1.pl', Pattern),
   expand_file_name(Pattern, [File|_]),
   consult(File).

% The three solutions of clues 1..8 (checked independently by brute force).
sol_a([p('Alex',design,java,'AI'),     p('Ben',development,javascript,web),
       p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).
sol_b([p('Alex',design,java,embedded), p('Ben',development,javascript,web),
       p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
sol_c([p('Alex',testing,python,embedded), p('Ben',development,javascript,web),
       p('Carla',design,java,'AI'),        p('Dana',research,'c++',data)]).

:- begin_tests(p1).

test(count_1_to_8) :-
    count_solutions([1,2,3,4,5,6,7,8], N), N =:= 3.

test(count_with_clue_9) :-
    count_solutions([1,2,3,4,5,6,7,8,9], N), N =:= 1.

test(count_no_clues) :-          % 4!^3 unconstrained assignments
    count_solutions([], N), N =:= 13824.

test(count_single_clue_4) :-     % Ben fixed to web (6 project perms), Ben not testing (3 depts of 4)
    count_solutions([4], N), N =:= 24 * 18 * 6.

test(all_clues_hold_in_each_solution) :-
    forall(member(G, [sol_a, sol_b, sol_c]),
           ( call(G, S), forall(between(1, 8, K), clue(K, S)) )).

test(clue_9_true_only_in_kept_solution) :-
    sol_b(B), clue(9, B),
    sol_a(A), \+ clue(9, A),
    sol_c(C), \+ clue(9, C).

test(unique_solution_is_sol_b) :-
    findall(S, solve([1,2,3,4,5,6,7,8,9], S), [S1]),
    sol_b(S1).

test(clue_1_rejects_dana_ai) :-
    \+ clue(1, [p('Alex',design,java,web), p('Ben',development,javascript,embedded),
                p('Carla',research,'c++',data), p('Dana',testing,python,'AI')]).

test(clue_7_rejects_dana_in_design) :-
    \+ clue(7, [p('Alex',research,java,web), p('Ben',development,javascript,embedded),
                p('Carla',testing,'c++',data), p('Dana',design,python,'AI')]).

test(main_output) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Lines0),
    exclude(==(""), Lines0, Lines),
    length(Lines, 4),
    Lines = [LA, LB, LC, LD],
    sub_string(LA, 0, _, _, "Alex = ["),
    sub_string(LB, 0, _, _, "Ben = ["),
    sub_string(LC, 0, _, _, "Carla = ["),
    sub_string(LD, 0, _, _, "Dana = [").

test(main_prints_a_real_solution) :-
    with_output_to(string(Out), main),
    member(G, [sol_a, sol_b, sol_c]),
    call(G, S),
    with_output_to(string(Exp), forall(member(P, S), print_friend(P))),
    Out == Exp, !.

test(main_exact_first_line) :-
    with_output_to(string(Out), main),
    sub_string(Out, 0, _, _, "Alex = [design, java, AI]\n").

:- end_tests(p1).
