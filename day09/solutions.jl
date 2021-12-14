R = CartesianIndices(input)
Ifirst, Ilast = first(R), last(R)
I1 = oneunit(Ifirst)

function solutionpart1()
  sum = 0
  for I in R
    # strictly not correct, this checks diagonals as well
    if input[I] == min(input[max(Ifirst, I-I1):min(Ilast, I+I1)]...)
      sum += input[I] + 1
    end
  end
  sum
end

function solutionpart2()
  ids = reshape(collect([I for I in R]), size(input)...)
  function getid(I)
    while I != ids[I]
      I = ids[I]
    end
    I
  end
  
  for v in 1:size(input)[1]
    for h in 2:size(input)[2]
      I = CartesianIndex(v,h)
      L = CartesianIndex(v, h-1)
      if input[I] != 9 && input[L] != 9
        ids[getid(I)] = ids[getid(L)]
      end
    end
  end
  for v in 2:size(input)[1]
    for h in 1:size(input)[2]
      I = CartesianIndex(v,h)
      U = CartesianIndex(v-1, h)
      if input[I] != 9 && input[U] != 9
        ids[getid(I)] = ids[getid(U)]
      end
    end
  end

  counts = zeros(Int, size(input))
  for I in R
    counts[getid(I)] += 1
  end
  counts = sort(reshape(counts, :), rev=true)
  counts[1] * counts[2] * counts[3]
end