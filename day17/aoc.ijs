input =: 2 2 $ ". > '-?[[:digit:]]+' rxall 1!:1 <'input.txt'

triangles =: +/\ i.150

solutionpart1 =: 3 : '2 %~ */ (-1 0) + 2 $  >. / | 1 { y'

solutionpart2 =: 3 : '(''two'', y)'

part =: 2!:5 'part'
main =: 3 : 'if. y = < ''part2'' do. solutionpart2 input else. solutionpart1 input end. '
(": main < part) 1!:2 (4)
exit''