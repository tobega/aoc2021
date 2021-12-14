
polymer, _, rules = open(input) do io
  collect(readline(io)), readline(io),
  Dict([(collect(pair)...,)=>insert[1] for (pair,insert) in [split(l," -> ") for l in readlines(io)]])
end

function applyrules(pairs)
  result = Dict([(k,v) for (k,v) in pairs if !haskey(rules, k)])
  for ((a,b), i) in rules
    (count = get(pairs, (a,b), 0)) > 0 || continue
    result[(a, i)] = get(result, (a, i), 0) + count
    result[(i, b)] = get(result, (i, b), 0) + count
  end
  result
end

function diffcount(pairs)
  elements = Dict()
  for ((a,b),v) in pairs
    elements[a] = get(elements, a, 0) + v
    elements[b] = get(elements, b, 0) + v
  end
  elements[first(polymer)] += 1
  elements[last(polymer)] += 1
  (b,t) = extrema(values(elements))
  (t - b) ÷ 2
end

function solutionpart1(times=10)
  pairs = Dict()
  for p in zip(polymer[1:end-1], polymer[2:end])
    pairs[p] = get(pairs, p, 0) + 1
  end
  for _ in 1:times
    pairs = applyrules(pairs)
  end
  diffcount(pairs)
end

function solutionpart2()
  solutionpart1(40)
end
