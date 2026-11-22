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
