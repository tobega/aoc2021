
io = open(input)
initial = collect(readline(io))
pairs = Dict()
for p in zip(initial[1:end-1], initial[2:end])
  pairs[p] = get(pairs, p, 0) + 1
end
readline(io)
rules = Dict([(collect(s[1])...,)=>s[2][1] for s in [split(l," -> ") for l in readlines(io)]])

function applyrules(polymer)
  result = Dict()
  for p in keys(rules)
    (count = get(polymer, p, 0)) > 0 || continue
    i = rules[p]
    p1 = (p[1], i)
    result[p1] = get(result, p1, 0) + count
    p2 = (i, p[2])
    result[p2] = get(result, p2, 0) + count
  end
  result
end

function diffcount(polymer)
  elements = Dict()
  for (k,v) in polymer
    elements[k[1]] = get(elements, k[1], 0) + v
    elements[k[2]] = get(elements, k[2], 0) + v
  end
  elements[initial[1]] += 1
  elements[initial[end]] += 1
  occurrences = sort([v for v in values(elements)])
  (occurrences[end] - occurrences[1])/2
end

function solutionpart1(times=10)
  polymer = pairs
  for _ in 1:times
    polymer = applyrules(polymer)
  end
  diffcount(polymer)
end

function solutionpart2()
  solutionpart1(40)
end
