

:- use_module(library(lists)).


op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).


apply_op(+, A, B, V) :- V is A + B.
apply_op(-, A, B, V) :- V is A - B.
apply_op(*, A, B, V) :- V is A * B.
apply_op(/, A, B, V) :- B =\= 0, A mod B =:= 0, V is A // B.


wrap_left(CP, PP, S, Out) :-
    (   CP < PP
    ->  format(string(Out), "(~w)", [S])
    ;   Out = S
    ).

wrap_right(CP, PP, S, Out) :-
    (   CP =< PP
    ->  format(string(Out), "(~w)", [S])
    ;   Out = S
    ).

build_table(Nums, Table) :-
    length(Nums, K),
    Max is K - 1,
    build_lengths(1, Max, Nums, [], Table).

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

split_point(Table, I, J, As, Bs) :-
    split_point(Table, I, J, _, As, Bs).

split_point(Table, I, J, K, As, Bs) :-
    J1 is J - 1,
    between(I, J1, K),
    K1 is K + 1,
    memberchk(t(I, K, As), Table),
    memberchk(t(K1, J, Bs), Table).

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

common_value([X|Xs], [Y|Ys], V) :-
    compare(Order, X, Y),
    common_value(Order, X, Xs, Y, Ys, V).

common_value(=, X, _, _, _, X).
common_value(=, _, Xs, _, Ys, V) :- common_value(Xs, Ys, V).
common_value(<, _, Xs, Y, Ys, V) :- common_value(Xs, [Y|Ys], V).
common_value(>, X, Xs, _, Ys, V) :- common_value([X|Xs], Ys, V).

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


generate_equation(List, Equation) :-
    once(equation(List, Equation)).


all_equations(List, Equations) :-
    findall(E, equation(List, E), Es),
    sort(Es, Equations).

count_equations(List, N) :-
    all_equations(List, Es),
    length(Es, N).
