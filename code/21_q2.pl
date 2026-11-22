% P2: Form a Valid Arithmetic Equation
% SWI-Prolog 9.x.
%
% An expression over a non-empty list of numbers is built as a value together
% with its canonical string and the precedence of its top operator, so no
% string is ever parsed back into a term.
%   precedence: + - = 1,  * / = 2,  a single number = 3 (never parenthesised)

:- use_module(library(lists)).

% op_prec(?Op, ?Prec): precedence of each binary operator.
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

% split(+List, -Left, -Right): List = Left ++ Right with both parts non-empty.
split(List, [X|Xs], [Y|Ys]) :-
    append([X|Xs], [Y|Ys], List).

% apply_op(+Op, +A, +B, -V): V is A Op B; division only when exact and B =\= 0.
apply_op(+, A, B, V) :- V is A + B.
apply_op(-, A, B, V) :- V is A - B.
apply_op(*, A, B, V) :- V is A * B.
apply_op(/, A, B, V) :- B =\= 0, A mod B =:= 0, V is A // B.

% wrap_left(+ChildPrec, +ParentPrec, +S, -Out):
% a left operand is parenthesised only if its precedence is lower.
wrap_left(CP, PP, S, Out) :-
    (   CP < PP
    ->  format(string(Out), "(~w)", [S])
    ;   Out = S
    ).

% wrap_right(+ChildPrec, +ParentPrec, +S, -Out):
% a right operand is parenthesised if its precedence is the same or lower.
wrap_right(CP, PP, S, Out) :-
    (   CP =< PP
    ->  format(string(Out), "(~w)", [S])
    ;   Out = S
    ).

% expr(+Nums, -Str, -Val, -Prec)
% Str is the canonical string of an expression tree that uses every number of
% Nums once, in order; Val is its integer value and Prec its top precedence.
% Each tree is produced exactly once.
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

% equation(+List, -Eq): Eq is the string "L=R" of one valid equation.
% The right-hand values are computed once per split point and looked up.
equation(List, Eq) :-
    is_list(List),
    split(List, Ls, Rs),
    findall(V-S, expr(Rs, S, V, _), Rights),
    Rights \== [],
    expr(Ls, LStr, Val, _),
    member(Val-RStr, Rights),
    format(string(Eq), "~w=~w", [LStr, RStr]).

% P2.a  generate_equation(+List, ?Equation): one valid equation, else fail.
generate_equation(List, Equation) :-
    once(equation(List, Equation)).

% P2.b  all_equations(+List, -Equations): all valid equations, sorted, no duplicates.
all_equations(List, Equations) :-
    findall(E, equation(List, E), Es),
    sort(Es, Equations).

% count_equations(+List, -N): number of distinct valid equations.
count_equations(List, N) :-
    all_equations(List, Es),
    length(Es, N).
