printnl(Text):- print_term(Text, []), nl. % Print with new line

% 
%   Read file
%
read_file_lines(File, Lines) :-
    open(File, read, Stream),
    read_lines(Stream, Lines),
    close(Stream).

read_lines(Stream, []) :-
    at_end_of_stream(Stream).

read_lines(Stream, [ListChars | Rest]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, Line),
    string_chars(Line, ListChars),
    read_lines(Stream, Rest).

%
%   Write to file
%
write_lines(_, []). % done
write_lines(Stream, [Line]) :- % if last write then dont new line
    %string_chars(String, Line), % doesnt work because this is getting a list of a list and not just a list
    write(Stream, String),
    write_lines(Stream, []).

write_lines(Stream, [Line | Rest]) :-
    %string_chars(String, Line), % doesnt work because this is getting a list of a list and not just a list
    write(Stream, String),
    nl(Stream),
    write_lines(Stream, Rest).

write_file_lines(File, Lines) :-
    open(File, write, Stream),
    write_lines(Stream, Lines),
    close(Stream).


%
%   Can be multiple games in file, split into each game
%
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > -1, NI is I-1, replace(T, NI, X, R), !.
replace(L, _, _, L).

filter_out_useless([], []). % remove empty characters
filter_out_useless([' ' | RestOfLine], Cleaned):- filter_out_useless(RestOfLine, Cleaned).
filter_out_useless([Char | RestOfLine], [Char | Cleaned]):- filter_out_useless(RestOfLine, Cleaned).


split_games([], [], []). % done
split_games([['s', 'i', 'z', 'e', ' ', WidthChar, 'x', HeightChar] | Rest], [], Games):- % First line of a new puzzle but with no previous game
    atom_number(WidthChar, Width),
    atom_number(HeightChar, Height),
    split_games(Rest, [[Width, Height]], Games).

split_games([['s', 'i', 'z', 'e', ' ', WidthChar, 'x', HeightChar] | Rest], CurrentGame, [CurrentGame | Games]):- % First line of a new puzzle
    atom_number(WidthChar, Width),
    atom_number(HeightChar, Height),
    split_games(Rest, [[Width, Height]], Games).

split_games([Line | Rest], CurrentGame, Games):- % Continue processing the game
    filter_out_useless(Line, Cleaned),
    append(CurrentGame, [Cleaned], UpdatedGame),
    split_games(Rest, UpdatedGame, Games).

split_games([], CurrentGame, [CurrentGame | Games]):- % Done, add the last game to the list of games
    split_games([], [], Games).


%   Remake the program to a new data sctructure 
%   New data structure Node = [Upleft slant, Upright slant, Bot left slant, Bot right slant, Square value]
%   
getElement(_, -1, _, '', _, _). % if trying to get a slant in the row above which does not exist
getElement(_, _, -1, '', _, _). % trying to get element in non existing col
getElement(_, _, NonExistentColIndex, '', _, Width):- NonExistentColIndex is Width + 1. % trying to get element in non existing col
getElement(_, NonExistentRowIndex, _, '', Height, _):- NonExistentRowIndex is Height * 2 + 1. % trying to get element in non existing row
getElement(Game, RowIndex, ColIndex, Element, _, _):- % get the element otherwise
    nth0(RowIndex, Game, Row), % traverse the 2d list
    nth0(ColIndex, Row, Element). % get the element


%
%   Static solve Node = [Upleft slant, Upright slant, Bot left slant, Bot right slant, Square value]
%
% static solve for zeros 
solve_node(['x', UpRight, BotLeft, BotRight, '0'], Solved):- solve_node(['/', UpRight, BotLeft, BotRight, '0'], Solved). % recursion until no pattern matches
solve_node([UpLeft, 'x', BotLeft, BotRight, '0'], Solved):- solve_node([UpLeft, '\\', BotLeft, BotRight, '0'], Solved).
solve_node([UpLeft, UpRight, 'x', BotRight, '0'], Solved):- solve_node([UpLeft, UpRight, '\\', BotRight, '0'], Solved).
solve_node([UpLeft, UpRight, BotLeft, 'x', '0'], Solved):- solve_node([UpLeft, UpRight, BotLeft, '/', '0'], Solved).
% static solve for ones
% corners
solve_node(['', '', '', 'x', '1'], ['', '', '', '\\', '1']). % up left corner
solve_node(['', '', 'x', '', '1'], ['', '', '/', '', '1']). % up right corner
solve_node(['', 'x', '', '', '1'], ['', '/', '', '', '1']). % bot left corner
solve_node(['x', '', '', '', '1'], ['\\', '', '', '', '1']). % bot right corner
% already have a slant pointed at them, do this later for cases with already filled slants
%solve_node(['\\', 'x', '', '', '1'], ['\\', '\', '', '', '1']).
% static solve for twos
solve_node(['', '', 'x', 'x', '2'], ['', '', '/', '\\', '2']). % first row
solve_node(['x', 'x', '', '', '2'], ['\\', '/', '', '', '2']). % last row
solve_node(['', 'x', '', 'x', '2'], ['', '/', '', '\\', '2']). % left side
solve_node(['x', '', 'x', '', '2'], ['\\', '', '/', '', '2']). % right side
% static solve threes
% static solve four
solve_node([_, _, _, _, '4'], ['\\', '/', '//', '\\', '4']).
solve_node(X, X). % if cant solve anymore return the the node


%
%   Merge node results
%
xor(X, '/'):- member(X, '/'). % return / if the list contains it
xor(X, '\\'):- member(X, '\\'). % return \ if the list contains it
xor(_, 'x').


%
%   Make nodes and solve them
%
make_nodes(_, [], LastRowIndex, _, Height, _):- LastRowIndex is Height * 2 + 2. % done when row is non existent

make_nodes(Game, [SolvedNode | Nodes], RowIndex, Width, Height, Width):- % run on last col to go to next row
    getElement(Game, RowIndex, Width, Value, Height, Width),

    SlantTopRowIndex is RowIndex - 1,
    SlantLeftColIndex is Width - 1,
    getElement(Game, SlantTopRowIndex, SlantLeftColIndex, TopLeft, Height, Width),

    SlantBotRowIndex is RowIndex + 1,
    SlantLeftColIndex is Width - 1,
    getElement(Game, SlantBotRowIndex, SlantLeftColIndex, BotLeft, Height, Width),

    solve_node([TopLeft, '', BotLeft, '', Value], SolvedNode),

    NextSquareRowIndex is RowIndex + 2, % go next row
    make_nodes(Game, Nodes, NextSquareRowIndex, 0, Height, Width).

make_nodes(Game, [SolvedNode | Nodes], RowIndex, ColIndex, Height, Width):- % run else
    getElement(Game, RowIndex, ColIndex, Value, Height, Width),

    SlantTopRowIndex is RowIndex - 1,
    SlantLeftColIndex is ColIndex - 1,
    getElement(Game, SlantTopRowIndex, SlantLeftColIndex, TopLeft, Height, Width),
    getElement(Game, SlantTopRowIndex, ColIndex, TopRight, Height, Width),

    SlantBotRowIndex is RowIndex + 1,
    SlantLeftColIndex is ColIndex - 1,
    getElement(Game, SlantBotRowIndex, SlantLeftColIndex, BotLeft, Height, Width),
    getElement(Game, SlantBotRowIndex, ColIndex, BotRight, Height, Width),

    solve_node([TopLeft, TopRight, BotLeft, BotRight, Value], SolvedNode),

    NextColIndex is ColIndex + 1, % go to next col
    make_nodes(Game, Nodes, RowIndex, NextColIndex, Height, Width).



make_list_of_slants(Nodes, [], LastRowIndex, _, Height, _):- LastRowIndex is Height * 2 + 1. % done when row is non existent

make_list_of_slants(Nodes, Game, RowIndex, Width, Height, Width):- % run on last col to go to next row
    NextSquareRowIndex is RowIndex + 2, % go next row
    make_list_of_slants(Nodes, Game, NextSquareRowIndex, 0, Height, Width).

make_list_of_slants(Nodes, [Slant | Game], RowIndex, ColIndex, Height, Width):- % run else
    NodeUpLeftIndex is ColIndex + ((RowIndex - 1) * Width),
    NodeUpRightIndex is NodeUpLeftIndex + 1,
    NodeBotLeftIndex is NodeUpLeftIndex + Width,
    NodeBotRightIndex is NodeBotLeftIndex + 1,
    % this creates infinite loop

    nth0(NodeUpLeftIndex, Nodes, NodeUpLeft),
    nth0(0, NodeUpLeft, UpLeftSlant),

    nth0(NodeUpRightIndex, Nodes, NodeUpRight),
    nth0(1, NodeUpRight, UpRightSlant),

    nth0(NodeBotLeftIndex, Nodes, NodeBotLeft),
    nth0(0, NodeBotLeft, BotLeftSlant),

    nth0(NodeBotRightIndex, Nodes, NodeBotRight),
    nth0(0, NodeBotRight, BotRightSlant),

    xor([UpLeftSlant, UpRightSlant, BotLeftSlant, BotRightSlant], Slant), % xor the results

    NextColIndex is ColIndex + 1, % go to next col
    make_list_of_slants(Nodes, Game, RowIndex, NextColIndex, Height, Width).


%
%   Iterate for every game and solve each
%
iterate_games([], []). % done
iterate_games([[[Width, Height] | Game] | Games], [SlantList | Results]):- 
    make_nodes(Game, Nodes, 0, 0, Height, Width),
    printnl("Nodes:"),
    printnl(Nodes),
    make_list_of_slants(Nodes, SlantList, 1, 0, Height, Width),
    iterate_games(Games, Results).


%
%   main run of program
%
run :-
    printnl("Starting program..."),
    read_file_lines("puzzle_unsolved.txt", [_ | Rest]),
    split_games(Rest, [], Games),
    printnl(Games),
    iterate_games(Games, SolvedGames),
    printnl("SolvedGames:"),
    printnl(SolvedGames),
    %write_file_lines("puzzle_solved.txt", Games), % need to fix to handle 2d list
    printnl("Ending program...").

:- run.