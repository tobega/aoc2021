input =: 1!:1 <'input.txt'

solutionpart1 =: 3 : '(''one'', y)'

solutionpart2 =: 3 : '(''two'', y)'

part =: 2!:5 'part'
main =: 3 : 'if. y = < ''part2'' do. solutionpart2 input else. solutionpart1 input end. '
(main < part) 1!:2 (4)
exit''