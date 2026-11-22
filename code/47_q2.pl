% P2: Form a Valid Arithmetic Equation
% SWI-Prolog 9.x.
%
% Strategy (no string is ever parsed back into a term):
%  1. For every interval I..J of the input (except the whole list) build the
%     sorted set of integer values its expressions can take.  The tables are
%     built bottom-up by interval length and passed around as an argument.
%  2. For every split point, intersect the value sets of the left and right
%     sides.  Only for a common value V are expression trees produced, and only
%     trees whose value is V: every choice made while building them is checked
%     against the tables, so no work is spent on expressions that cannot match.
% precedence: + - = 1,  * / = 2,  a single number = 3 (never parenthesised)

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

% ---------------------------------------------------------------------------
% Value tables
% ---------------------------------------------------------------------------

% build_table(+Nums, -Table): Table holds t(I, J, Vs) for every interval I..J
% (1-based) of Nums shorter than the whole list, where Vs is the sorted set of
% values of all expressions over the numbers I..J.
build_table(Nums, Table) :-
    length(Nums, K),
    Max is K - 1,
    build_lengths(1, Max, Nums, [], Table).

% build_lengths(+L, +Max, +Nums, +T0, -T): T is T0 extended with the entries
% for all intervals of length L..Max (shorter intervals are already in T0).
build_lengths(L, Max, _, T, T) :-
    L > Max.
build_lengths(L, Max, Nums, T0, T) :-
    L =< Max,
    length(Nums, K),
    Last is K - L + 1,
    findall(t(I, J, Vs),
            ( between(1, Last, I),
              J is I + L - 1,
              interval_values(Nums, T0, I, J, Vs) ),
            New),
    append(T0, New, T1),
    L1 is L + 1,
    build_lengths(L1, Max, Nums, T1, T).

% interval_values(+Nums, +Table, +I, +J, -Vs): Vs is the sorted set of values
% of the expressions over numbers I..J; Table already holds every shorter interval.
interval_values(Nums, _, I, I, [N]) :-
    nth1(I, Nums, N).
interval_values(_, Table, I, J, Vs) :-
    I < J,
    findall(V,
            ( split_point(Table, I, J, As, Bs),
              member(A, As),
              member(B, Bs),
              op_prec(Op, _),
              apply_op(Op, A, B, V) ),
            Vs0),
    sort(Vs0, Vs).

% split_point(+Table, +I, +J, -As, -Bs): the interval I..J is split into
% I..K and K+1..J (I =< K < J) whose value sets are As and Bs.
split_point(Table, I, J, As, Bs) :-
    split_point(Table, I, J, _, As, Bs).

% split_point(+Table, +I, +J, -K, -As, -Bs): as split_point/5, also giving K.
split_point(Table, I, J, K, As, Bs) :-
    J1 is J - 1,
    between(I, J1, K),
    K1 is K + 1,
    memberchk(t(I, K, As), Table),
    memberchk(t(K1, J, Bs), Table).

% ---------------------------------------------------------------------------
% Expressions with a given value
% ---------------------------------------------------------------------------

% operands(+Op, +V, +As, +Bs, -A, -B): A is in As, B is in Bs and A Op B = V
% (with exact, non-zero division).  Each pair is produced once.
operands(+, V, As, Bs, A, B) :-
    member(A, As), B is V - A, memberchk(B, Bs).
operands(-, V, As, Bs, A, B) :-
    member(A, As), B is A - V, memberchk(B, Bs).
operands(*, V, As, Bs, A, B) :-
    member(A, As),
    (   A =:= 0
    ->  V =:= 0, member(B, Bs)
    ;   V mod A =:= 0, B is V // A, memberchk(B, Bs)
    ).
operands(/, V, As, Bs, A, B) :-
    member(B, Bs), B =\= 0, A is V * B, memberchk(A, As).

% expr_val(+Nums, +Table, +I, +J, +V, -Str, -Prec): Str is the canonical string
% of an expression tree over numbers I..J (all used once, in order) whose value
% is V, and Prec its top-level precedence.  Each tree is produced exactly once.
expr_val(Nums, _, I, I, V, Str, 3) :-
    nth1(I, Nums, N),
    N =:= V,
    number_string(N, Str).
expr_val(Nums, Table, I, J, V, Str, Prec) :-
    I < J,
    split_point(Table, I, J, K, As, Bs),
    K1 is K + 1,
    op_prec(Op, Prec),
    operands(Op, V, As, Bs, A, B),
    expr_val(Nums, Table, I, K, A, LStr, LPrec),
    expr_val(Nums, Table, K1, J, B, RStr, RPrec),
    wrap_left(LPrec, Prec, LStr, L),
    wrap_right(RPrec, Prec, RStr, R),
    format(string(Str), "~w~w~w", [L, Op, R]).

% common_value(+Xs, +Ys, -V): V is in both sorted lists Xs and Ys.
common_value([X|Xs], [Y|Ys], V) :-
    compare(Order, X, Y),
    common_value(Order, X, Xs, Y, Ys, V).

% common_value(+Order, +X, +Xs, +Y, +Ys, -V): merge step of common_value/3.
common_value(=, X, _, _, _, X).
common_value(=, _, Xs, _, Ys, V) :- common_value(Xs, Ys, V).
common_value(<, _, Xs, Y, Ys, V) :- common_value(Xs, [Y|Ys], V).
common_value(>, X, Xs, _, Ys, V) :- common_value([X|Xs], Ys, V).

% ---------------------------------------------------------------------------
% Equations
% ---------------------------------------------------------------------------

% equation(+List, -Eq): Eq is the string "L=R" of a valid equation for List.
% Lists shorter than 2 have none.
equation(List, Eq) :-
    is_list(List),
    length(List, K),
    K >= 2,
    build_table(List, Table),
    J1 is K - 1,
    between(1, J1, J),
    J2 is J + 1,
    memberchk(t(1, J, Ls), Table),
    memberchk(t(J2, K, Rs), Table),
    common_value(Ls, Rs, V),
    expr_val(List, Table, 1, J, V, LStr, _),
    expr_val(List, Table, J2, K, V, RStr, _),
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
