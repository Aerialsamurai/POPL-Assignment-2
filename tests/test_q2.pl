% Tests for P2.  Run from anywhere:
%   swipl -q -f tests/test_q2.pl -g run_tests -t halt
% Loads the *_q2.pl file in ../code relative to this test file.

:- use_module(library(plunit)).
:- use_module(library(lists)).

:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../code/*_q2.pl', Pattern),
   expand_file_name(Pattern, [File|_]),
   consult(File).

:- begin_tests(p2).

% --- examples from the assignment ---------------------------------------

test(all_4253) :-
    all_equations([4,2,5,3], Es),
    Es == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
           "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"].

test(generate_4253) :-
    generate_equation([4,2,5,3], E),
    string(E),
    all_equations([4,2,5,3], Es),
    memberchk(E, Es).

test(generate_234_fails, [fail]) :-
    generate_equation([2,3,4], _).

test(all_234_empty) :-
    all_equations([2,3,4], Es), Es == [].

test(all_248) :-
    all_equations([2,4,8], Es), Es == ["2*4=8"].

% --- edge cases ----------------------------------------------------------

test(empty_list_fails, [fail]) :-
    generate_equation([], _).

test(singleton_fails, [fail]) :-
    generate_equation([5], _).

test(all_empty_list) :-
    all_equations([], Es), Es == [].

test(all_singleton) :-
    all_equations([7], Es), Es == [].

test(two_equal) :-
    all_equations([1,1], Es), Es == ["1=1"].

test(zeros) :-
    all_equations([0,0], Es), Es == ["0=0"].

test(no_division_by_zero) :-        % 5/0 must not be produced or raise an error
    all_equations([5,0], Es), Es == [].

test(division_with_zero_dividend) :-
    all_equations([0,5,0], Es), Es == ["0*5=0", "0/5=0", "0=5*0"].

test(exact_division_only) :-
    all_equations([6,3,2], Es), Es == ["6/3=2", "6=3*2"].

test(trailing_zeros) :-
    all_equations([3,0,0], Es), Es == ["3*0=0"].

test(count_2222) :-                 % value cross-checked with an independent enumerator
    count_equations([2,2,2,2], N), N =:= 26.

test(count_4253) :-
    count_equations([4,2,5,3], N), N =:= 7.

test(count_none) :-
    count_equations([2,3,4], N), N =:= 0.

test(results_are_strings) :-
    all_equations([4,2,5,3], Es),
    forall(member(E, Es), string(E)).

test(check_given_equation) :-       % called with Equation already bound
    generate_equation([4,2,5,3], "4=2+(5-3)").

test(negative_intermediate) :-      % 1-(2-3) = 2 uses a negative sub-value
    all_equations([1,2,3,2], Es),
    memberchk("1-(2-3)=2", Es).

test(sorted_no_duplicates) :-
    all_equations([2,2,2,2], Es),
    sort(Es, Sorted), Es == Sorted.

:- end_tests(p2).
