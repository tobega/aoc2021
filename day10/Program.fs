// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

type Line =
  | Incomplete of prefix: char list
  | SyntaxError of score: int

let syntaxErrorScore line =
  let rec check (suffix:string) stack =
    if suffix = "" then
      Incomplete(stack)
    else
    match suffix[0] with
    | '(' | '[' | '{' | '<' -> check suffix[1..] (suffix[0] :: stack)
    | _ -> match (suffix[0], stack) with
           | (')', '(' :: rest) | (']', '[' :: rest) | ('}', '{' :: rest) | ('>', '<' :: rest) -> check suffix[1..] rest
           | (')', _) -> SyntaxError(3)
           | (']', _) -> SyntaxError(57)
           | ('}', _) -> SyntaxError(1197)
           | ('>', _) -> SyntaxError(25137)
           | _ -> failwith line
  check line []

let solutionPart1 =
  System.IO.File.ReadLines("input.txt") |> Seq.map syntaxErrorScore |>
  Seq.map (function
          | Incomplete(_) -> 0
          | SyntaxError(score) -> score)
  |> Seq.sum

let autoCompleteScore syntaxCheck =
  let rec completion prefix score =
    match prefix with
    | [] -> score
    | '(' :: rest -> completion rest (5m*score+1m)
    | '[' :: rest -> completion rest (5m*score+2m)
    | '{' :: rest -> completion rest (5m*score+3m)
    | '<' :: rest -> completion rest (5m*score+4m)
    | _ -> failwith "impossible"
  match syntaxCheck with
  | Incomplete(prefix) -> completion prefix 0m
  | _ -> failwith "impossible"


let solutionPart2 =
  System.IO.File.ReadLines("input.txt") |> Seq.map syntaxErrorScore
  |> Seq.filter (function
                | SyntaxError(_) -> false
                | Incomplete(_) -> true)
  |> Seq.map autoCompleteScore
  |> Seq.sort
  |> Seq.toArray
  |> (fun a -> a.[a.Length / 2])

[<EntryPoint>]
let main argv =
    printfn "F#\n%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> solutionPart1 |> string
        | "part2" -> solutionPart2 |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code