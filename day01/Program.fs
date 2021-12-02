// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

let solutionPart1 nums =
  let rec count xs n =
    match xs with
    | a :: (b :: rest) when b > a -> count (b :: rest) (n+1)
    | a :: rest -> count rest n
    | _ -> n
  count nums 0

let solutionPart2 nums =
  let rec count xs n =
    match xs with
    | a :: (b :: (c :: (d :: rest))) when d > a -> count (b :: c :: d :: rest) (n+1)
    | a :: rest -> count rest n
    | _ -> n
  count nums 0

[<EntryPoint>]
let main argv =
    let input = (System.IO.File.ReadLines("input.txt")
        |> Seq.map int
        |> Seq.toList)

    printfn "F#\n%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> input |> solutionPart1 |> string
        | "part2" -> input |> solutionPart2 |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code