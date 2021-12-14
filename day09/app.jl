include("solutions.jl")

input = vcat([permutedims(parse.(Int, l)) for l in collect.(readlines("input.txt"))]...)

println("Julia")

part = get(Base.ENV, "part", "part1")
println(if part == "part1"
  solutionpart1()
elseif part == "part2"
  solutionpart2()
else
  "Unknown part " * part
end)
