using Test

input = [
2 1 9 9 9 4 3 2 1 0;
3 9 8 7 8 9 4 9 2 1;
9 8 5 6 7 8 9 8 9 2;
8 7 6 7 8 9 6 7 8 9;
9 8 9 9 9 6 5 6 7 8
]

include("solutions.jl")

@testset "basic tests" begin
  @test solutionpart1() == 15
  @test solutionpart2() == 1134
end