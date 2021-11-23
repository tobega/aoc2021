module AocTests

open FsUnit.Xunit
open Xunit
open Aoc

let input = [|0;3;4;42;106;107;267;269|]

[<Fact>]
let ``Solution1 is 2421`` () =
  input |> solutionPart1
  |> should equal 2421

[<Fact>]
let ``Solution2 is 335`` () =
  input |> solutionPart2
  |> should equal 335
