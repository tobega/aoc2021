input = open("input.txt") do file
  [parse(Int32, line) for line in eachline(file)]
end

function solutionpart1()
  count(input[1:end-1] .< input[2:end])
end

function solutionpart2()
  sliding = input[1:end-2] .+ input[2:end-1] .+ input[3:end]
  count(sliding[1:end-1] .< sliding[2:end])
end

part = get(Base.ENV, "part", "part1")
println(if part == "part1"
  solutionpart1()
elseif part == "part2"
  solutionpart2()
else
  "Unknown part " * part
end)
