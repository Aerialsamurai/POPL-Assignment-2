

:- use_module(library(plunit)).
:- use_module(library(lists)).

:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../code/*_q1.pl', Pattern),
   expand_file_name(Pattern, [File|_]),
   consult(File).


good([p('Alex',design,java,'AI'),     p('Ben',development,javascript,web),
      p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).


bad(1, [p('Alex',design,java,embedded),  p('Ben',development,javascript,web),    % Dana has AI
        p('Carla',research,'c++',data),  p('Dana',testing,python,'AI')]).
bad(2, [p('Alex',development,java,'AI'), p('Ben',design,javascript,web),         % Alex in development
        p('Carla',research,'c++',data),  p('Dana',testing,python,embedded)]).
bad(3, [p('Alex',design,java,'AI'),      p('Ben',development,javascript,web),    % tester likes c++
        p('Carla',research,python,data), p('Dana',testing,'c++',embedded)]).
bad(4, [p('Alex',design,java,'AI'),      p('Ben',development,javascript,embedded), % Ben not web
        p('Carla',research,'c++',data),  p('Dana',testing,python,web)]).
bad(5, [p('Alex',design,javascript,'AI'), p('Ben',development,java,web),         % Java in development
        p('Carla',research,'c++',data),  p('Dana',testing,python,embedded)]).
bad(6, [p('Alex',design,java,'AI'),      p('Ben',development,javascript,web),    % Carla embedded
        p('Carla',research,'c++',embedded), p('Dana',testing,python,data)]).
bad(7, [p('Alex',design,python,'AI'),    p('Ben',development,javascript,web),    % Dana likes Java
        p('Carla',research,'c++',data),  p('Dana',testing,java,embedded)]).
bad(8, [p('Alex',design,java,'AI'),      p('Ben',development,'c++',web),         % data with JavaScript
        p('Carla',research,javascript,data), p('Dana',testing,python,embedded)]).

:- begin_tests(p1_counts).

test(no_clues) :-                  % 4! * 4! * 4! unconstrained assignments
    count_solutions([], N), N =:= 13824.

test(single_clue_4) :-             % Ben: 3 departments, web fixed -> 18 * 24 * 6
    count_solutions([4], N), N =:= 2592.

test(single_clue_2) :-             % Alex: 3 departments, 3 languages -> 18 * 18 * 24
    count_solutions([2], N), N =:= 7776.

test(clues_1_to_8) :-
    count_solutions([1,2,3,4,5,6,7,8], N), N =:= 3.

test(order_of_active_irrelevant) :-
    count_solutions([8,7,6,5,4,3,2,1], N), N =:= 3.

test(clues_1_to_9_unique) :-
    count_solutions([1,2,3,4,5,6,7,8,9], N), N =:= 1.

test(clue_9_keeps_the_testing_ai_solution) :-
    findall(S, solve([1,2,3,4,5,6,7,8,9], S), [S1]),
    S1 == [p('Alex',design,java,embedded), p('Ben',development,javascript,web),
           p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)].

test(clue_9_false_in_other_two) :-
    findall(S, (solve([1,2,3,4,5,6,7,8], S), \+ clue(9, S)), Rejected),
    length(Rejected, 2).

:- end_tests(p1_counts).

:- begin_tests(p1_clues).

test(good_solution_is_complete) :-
    good(S), once(candidate(S)).

test(bad_solutions_are_complete, [forall(between(1, 8, N))]) :-
    bad(N, S), once(candidate(S)).

test(clue_holds, [forall(between(1, 8, N))]) :-
    good(S), clue(N, S).

test(clue_fails, [forall(between(1, 8, N)), fail]) :-
    bad(N, S), clue(N, S).

:- end_tests(p1_clues).

:- begin_tests(p1_main).

test(main_prints_four_lines) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Parts),
    once(append(Lines, [""], Parts)),     % output ends with a newline
    length(Lines, 4).

test(main_line_format) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", [LA, LB, LC, LD, ""]),
    line_for('Alex', LA), line_for('Ben', LB),
    line_for('Carla', LC), line_for('Dana', LD).

% main/0's output must equal the printed form of one of the solutions of 1-8.
test(main_prints_a_solution_of_1_to_8) :-
    with_output_to(string(MainOut), main),
    findall(Expected,
            ( solve([1,2,3,4,5,6,7,8], S),
              with_output_to(string(Expected), forall(member(P, S), print_friend(P))) ),
            AllExpected),
    length(AllExpected, 3),
    memberchk(MainOut, AllExpected).

:- end_tests(p1_main).

% line_for(+Name, +Line): Line is "Name = [D, L, P]" with three valid values.
line_for(Name, Line) :-
    format(string(Prefix), "~w = [", [Name]),
    string_concat(Prefix, Rest, Line),
    string_concat(Inner, "]", Rest),
    split_string(Inner, ",", " ", [D, L, P]),
    atom_string(DA, D), atom_string(LA, L), atom_string(PA, P),
    departments(Ds), memberchk(DA, Ds),
    languages(Ls), memberchk(LA, Ls),
    projects(Ps), memberchk(PA, Ps).
