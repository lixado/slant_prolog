filter([], []). % remove empty characters
filter([' ' | RestOfLine], Cleaned):- filter(RestOfLine, Cleaned).
filter([Char | RestOfLine], [Char | Cleaned]):- filter(RestOfLine, Cleaned).

main :- 
    filter(['a', 'b', ' ', '_'], Result), 
    print_term(Result, []).

:- main.