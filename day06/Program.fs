// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

let solutionPart1 (lanternfish:decimal[]) days =
  let propagate day =
    let ready = lanternfish.[0]
    for i in 0..7 do
      Array.set lanternfish i lanternfish.[i+1]
    Array.set lanternfish 8 ready
    Array.set lanternfish 6 (lanternfish.[6] + ready)
  for day = days downto 1 do
    propagate day
  lanternfish |> Array.sum

let parseInts (line: string) =
  let population = [| for _ in 0..8 -> 0m |]
  for i in line.Split ',' do
    Array.set population (int i) (population.[int i] + 1m)
  population


[<EntryPoint>]
let main argv =
    let input = (System.IO.File.ReadAllText("input.txt")
        |> parseInts)

    printfn "F#\n%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> solutionPart1 input 80 |> string
        | "part2" -> solutionPart1 input 256 |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code