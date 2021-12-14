R = CartesianIndices(input)
Ifirst, Ilast = first(R), last(R)
I1 = oneunit(Ifirst)
H1 = CartesianIndex(0,1)
V1 = CartesianIndex(1,0)

function solutionpart1()
  sum = 0
  for I in R
    if input[I] == min(input[max(Ifirst, I-I1):min(Ilast, I+I1)]...)
      sum += input[I] + 1
    end
  end
  sum
end

function solutionpart2()
  0
end
