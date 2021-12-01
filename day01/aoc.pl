#!swipl

getLines(L):-
  setup_call_cleanup(
    open('input.txt', read, In),
    readData(In, L),
    close(In)
  ).

readData(In, L):-
  read_line_to_string(In, H),
  (   H == end_of_file
  ->  L = []
  ;   number_string(N, H),
      L = [N|T],
      readData(In,T)
  ).

increases([A,B|T], C):-
  increases([B|T], D),
  (  B > A
  -> C is D + 1
  ;  C is D
  ).
increases([_], 0).
increases([], 0).

sliding3([],[]).
sliding3([_],[]).
sliding3([_,_],[]).
sliding3([A,B,C|T], [A+B+C|S]):-
  sliding3([B,C|T], S).

:- initialization(main, main).

main(_):-
  writeln('Prolog'),
  getLines(L),
  (   not(getenv('part', _))
  ->  P = 'part1'
  ;   getenv('part', P)
  ),
  (   P == 'part1' -> increases(L,C), writeln(C)
  ;   sliding3(L,S), increases(S,V), writeln(V)
  ).
