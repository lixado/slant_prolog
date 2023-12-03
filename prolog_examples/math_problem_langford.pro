% The problem: https://mathworld.wolfram.com/LangfordsProblem.html
% Simple explanation:
% write a number which has the following digits 8 digits [1, 1, 2, 2, 3, 3, 4, 4]
% and each number has the same number of digits in between it, for example [2,3,1,2,1,3]
% in this example 2 has 3 digits in between, 1 has 1 digits in between and 3 has 3 digits in between

langford4(X):- 
    length(X,8),
    append(_,[1,_,1|_],X),
    append(_,[2,_,_,2|_],X),
    append(_,[3,_,_,_,3|_],X),
    append(_,[4,_,_,_,_,4|_],X).
  
main :- 
    findall(Result, langford4(Result), Results), 
    print_term("All solutions: ", []), nl,
    print_term(Results, []).

:- main.