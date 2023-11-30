% The problem: https://mathworld.wolfram.com/LangfordsProblem.html
% Simple explanation:
% write a number which has the following digits 8 digits [1, 1, 2, 2, 3, 3, 4, 4]
% and each number has the same number of digits in between it, for example [2,3,1,2,1,3]
% in this example 2 has 3 digits in between, 1 has 1 digits in between and 3 has 3 digits in between

sublist([], _).
sublist([X|XS], [X|XSS]) :- sublist(XS, XSS).
sublist([X|XS], [_|XSS]) :- sublist([X|XS], XSS).

langford4(L):-
    L = [_,_,_,_,_,_,_,_], % this is the size 
    sublist([1,_,1], L),  % L has is constrained by having to include 1, _, 1 and so on...
    sublist([2,_,_,2], L),
    sublist([3,_,_,_,3], L),
    sublist([4,_,_,_,_,4], L).

main :- 
    findall(Result, langford4(Result), Results), 
    print_term("All solutions: ", []), nl,
    print_term(Results, []).

:- main.