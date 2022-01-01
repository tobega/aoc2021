input =: 2 2 $ ". > '-?[[:digit:]]+' rxall 1!:1 <'input.txt'

solutionpart1 =: 3 : '2 %~ */ (-1 0) + 2 $  >. / | 1 { y'

max_time =: +/ (2 1) * (-1 0) + 2 $  >. / | 1 { input

max_y =: >. / | 1 { input
cap_y =: >: max_y

max_x =: >. / | 0 { input

min_y =: <. / | 1 { input

min_x =: <. / | 0 { input

triangles_x =: +/\ i. >: max_x

dist_for_time_decelerated =: 4 : 'x - ((-y) }. (y $ 0) , x)'

x_time_by_speed =: triangles_x (dist_for_time_decelerated " 1 0) >: i. max_time

valid_x_time_by_speed =: ((<: min_x) < x_time_by_speed) * ((>: max_x) > x_time_by_speed)

y_direct_accelerated_speed_by_time =: (+/\"1) (i. cap_y) (+ " 0 1) (cap_y, cap_y) $ i. cap_y

valid_y_speed_by_time =: ((<: min_y) < y_direct_accelerated_speed_by_time) * (cap_y > y_direct_accelerated_speed_by_time)

positive_y =: 3 : '((1 + y * 2) $ 0), (1 + y) { valid_y_speed_by_time'

valid_positive_ys_speed_by_time =: (positive_y " 0) 1 }. i. max_y

unique_combinations =: 3 : '+/ +/ 1 <. y (+/ . *) (1 { $ y) {. valid_x_time_by_speed'

solutionpart2 =: 3 : '(unique_combinations valid_y_speed_by_time) + unique_combinations valid_positive_ys_speed_by_time'

part =: 2!:5 'part'
main =: 3 : 'if. y = < ''part2'' do. solutionpart2 input else. solutionpart1 input end. '
(": main < part) 1!:2 (4)
exit''