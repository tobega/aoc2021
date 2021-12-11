% aoc example program
-module(aoc).
-export([start/0]).

start() -> 
  Input = readlines("input.txt"),
  Part = os:getenv("part", "part1"),
  if 
    Part == "part2" ->
      getSolutionPart2(Input);
    true -> 
      getSolutionPart1(Input)  
  end.

getSolutionPart1(Input) ->
  Octopi = setUpOctopi(Input),
  io:fwrite("~p~n", [step(100, Octopi, 0)]).

step(0, _, TotalFlashes) -> TotalFlashes;
step(N, Octopi, TotalFlashes) ->
  broadcast(Octopi, reset),
  broadcast(Octopi, {quantum, self()}),
  awaitQuiescence(100, N, Octopi, TotalFlashes).

awaitQuiescence(0, N, Octopi, TotalFlashes) ->
  step(N-1, Octopi, TotalFlashes);
awaitQuiescence(Active, N, Octopi, TotalFlashes) ->
  receive
    {quiescent, TriggeredFlashes} -> awaitQuiescence(Active - 1, N, Octopi, TotalFlashes + TriggeredFlashes)
  end.

getSolutionPart2(Input) ->
  Octopi = setUpOctopi(Input),
  io:fwrite("~p~n", [allFlash(Octopi)]).

allFlash(Octopi) ->
  allFlash(Octopi, 0).
allFlash(Octopi, Step) ->
  Flashed = step(1, Octopi, 0),
  if
    Flashed == 100 -> Step + 1;
    true -> allFlash(Octopi, Step + 1)
  end.

readlines(Filename) ->
    {ok, Blob} = file:read_file(Filename),
    string:lexemes(binary_to_list(Blob), "\n").

broadcast(Octopi, Message) ->
  array:map(fun (_, Row) -> array:map(fun (_, Octopus) -> Octopus ! Message end, Row) end, Octopi).

setUpOctopi(Input) ->
  Octopi = array:new(),
  setUpOctopi(Input, Octopi, 0).

setUpOctopi([], Octopi, _) -> Octopi;
setUpOctopi([Row|Rest], Octopi, 0) ->
  setUpOctopi(Rest, array:set(0, setUpRow(Row, []), Octopi), 1);
setUpOctopi([Row|Rest], Octopi, I) ->
  PreviousRow = array:get(I-1, Octopi),
  setUpOctopi(Rest, array:set(I, setUpRow(Row, [], PreviousRow, 0), Octopi), I + 1).

setUpRow([], Spawned) -> array:from_list(lists:reverse(Spawned));
setUpRow([Char|Rest], []) -> setUpRow(Rest, [spawn(dumbo, octopus, [Char - 48, []])]);
setUpRow([Char|Rest], [Left|Others]) -> setUpRow(Rest, [spawn(dumbo, octopus, [Char - 48, [Left]]), Left | Others]).

setUpRow([], Spawned, _, _) -> array:from_list(lists:reverse(Spawned));

setUpRow([Char|Rest], [], PreviousRow, 0) ->
  Neighbours = [array:get(0, PreviousRow), array:get(1, PreviousRow)],
  Baby = spawn(dumbo, octopus, [Char-48, Neighbours]),
  setUpRow(Rest, [Baby], PreviousRow, 1);

setUpRow([Char|[]], [Left|Others], PreviousRow, J) ->
  Neighbours = [Left, array:get(J, PreviousRow), array:get(J-1, PreviousRow)],
  Baby = spawn(dumbo, octopus, [Char-48, Neighbours]),
  array:from_list(lists:reverse([Baby, Left|Others]));

setUpRow([Char|Rest], [Left|Others], PreviousRow, J) ->
  Neighbours = [Left, array:get(J+1, PreviousRow), array:get(J, PreviousRow), array:get(J-1, PreviousRow)],
  Baby = spawn(dumbo, octopus, [Char-48, Neighbours]),
  setUpRow(Rest, [Baby, Left|Others], PreviousRow, J+1).
