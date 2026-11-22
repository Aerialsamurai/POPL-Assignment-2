% P2: Form a Valid Arithmetic Equation
% SWI-Prolog 9.x.
%
% An expression over a non-empty list of numbers is built as a value together
% with its canonical string and the precedence of its top operator, so no
% string is ever parsed back into a term.
%   precedence: + - = 1,  * / = 2,  a single number = 3 (never parenthesised)

:- use_module(library(lists)).

% op_prec(?Op, ?Prec): Prec is the precedence of binary operator Op.
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

% apply_op(+Op, +A, +B, -V): V is A Op B; division holds only when B =\= 0
% and A is exactly divisible by B.
apply_op(+, A, B, V) :- V is A + B.
apply_op(-, A, B, V) :- V is A - B.
apply_op(*, A, B, V) :- V is A * B.
apply_op(/, A, B, V) :- B =\= 0, A mod B =:= 0, V is A // B.

% wrap_left(+ChildPrec, +ParentPrec, +S, -Out): Out is the left operand S,
% in parentheses only if its precedence is lower than its parent's.
wrap_left(CP, PP, S, Out) :-
    (   CP < PP
    ->  format(string(Out), "(~w)", [S])
    ;   Out = S
    ).

% wrap_right(+ChildPrec, +ParentPrec, +S, -Out): Out is the right operand S,
% in parentheses if its precedence is the same as or lower than its parent's.
wrap_right(CP, PP, S, Out) :-
    (   CP =< PP
    ->  format(string(Out), "(~w)", [S])
    ;   Out = S
    ).

% split(+List, -Left, -Right): List is Left followed by Right, both non-empty.
split(List, [X|Xs], [Y|Ys]) :-
    append([X|Xs], [Y|Ys], List).

% expr(+Nums, -Str, -Val, -Prec): Str is the canonical string of an expression
% tree using every number of Nums once, in order; Val is its integer value and
% Prec its top-level precedence.  Each tree is produced exactly once.
expr([N], Str, N, 3) :-
    number_string(N, Str).
expr(Nums, Str, Val, Prec) :-
    split(Nums, Ls, Rs),
    expr(Ls, LStr, LVal, LPrec),
    expr(Rs, RStr, RVal, RPrec),
    op_prec(Op, Prec),
    apply_op(Op, LVal, RVal, Val),
    wrap_left(LPrec, Prec, LStr, L),
    wrap_right(RPrec, Prec, RStr, R),
    format(string(Str), "~w~w~w", [L, Op, R]).

% equation(+List, -Eq): Eq is the string "L=R" of a valid equation for List.
% For each split, the right-hand expressions are computed once with findall/3
% and the left-hand expressions are matched against them by value.
equation(List, Eq) :-
    is_list(List),
    split(List, Ls, Rs),
    findall(V-S, expr(Rs, S, V, _), Rights),
    Rights \== [],
    expr(Ls, LStr, Val, _),
    member(Val-RStr, Rights),
    format(string(Eq), "~w=~w", [LStr, RStr]).

% generate_equation(+List, ?Equation): Equation is one valid equation for
% List; fails if there is none (including lists of length 0 or 1).
generate_equation(List, Equation) :-
    once(equation(List, Equation)).

% all_equations(+List, -Equations): Equations is the sorted list, without
% duplicates, of every valid equation for List ([] if there is none).
all_equations(List, Equations) :-
    findall(E, equation(List, E), Es),
    sort(Es, Equations).

% count_equations(+List, -N): N is the number of distinct valid equations.
count_equations(List, N) :-
    all_equations(List, Es),
    length(Es, N).
