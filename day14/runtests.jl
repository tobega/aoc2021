using Test

input = "input_test.txt"
include("solutions.jl")

@testset "basic tests" begin
  @test solutionpart1() == 1588
  @test solutionpart2() == 2188189693529
end