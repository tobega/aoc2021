-module(dumbo).
-export([octopus/2]).

octopus(Energy, Neighbours) ->
  init(Neighbours),
  ready(Energy, Neighbours).

init([]) -> ok;
init([Neighbour| Neighbours]) ->
  Neighbour ! {connect, self()},
  init(Neighbours).

ready(Energy, Neighbours) ->
  receive
    {connect, Neighbour} -> ready(Energy, [Neighbour | Neighbours]);
    {quantum, Source} -> if
      Energy == 9 -> flash(Neighbours, 0, Neighbours, Source);
      true -> Source ! {quiescent, 0}, ready(Energy + 1, Neighbours)
    end;
    reset -> if
      Energy > 9 -> ready(0, Neighbours);
      true -> ready(Energy, Neighbours)
    end
  end.

flash([], Flashed, Neighbours, Source) ->
  quiesce(Flashed, 1, Neighbours, Source);
flash([ToFlash|Remaining], Flashed, Neighbours, Source) ->
  ToFlash ! {quantum, self()},
  flash(Remaining, Flashed + 1, Neighbours, Source).

quiesce(0, FlashCount, Neighbours, Source) ->
  Source ! {quiescent, FlashCount},
  ready(10, Neighbours);
quiesce(Flashed, FlashCount, Neighbours, Source) ->
  receive
    {quantum, Other} -> Other ! {quiescent, 0}, quiesce(Flashed, FlashCount, Neighbours, Source);
    {quiescent, TriggeredFlashes} -> quiesce(Flashed - 1, FlashCount + TriggeredFlashes, Neighbours, Source)
  end.
