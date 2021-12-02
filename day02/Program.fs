// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

type Command =
  | Forward of int
  | Down of int
  | Up of int

type Position = {
    mutable distance: int;
    mutable depth: int;
    mutable aim: int;
}

let solutionPart1 commands =
  let pos = {distance=0; depth=0; aim=0;}
  for command in commands do
    match command with
    | Forward(f) -> pos.distance <- pos.distance + f
    | Down(d) -> pos.depth <- pos.depth + d
    | Up(u) -> pos.depth <- pos.depth - u
  pos.distance * pos.depth

let solutionPart2 commands =
  let pos = {distance=0; depth=0; aim=0;}
  for command in commands do
    match command with
    | Forward(f) -> do
        pos.distance <- pos.distance + f
        pos.depth <- pos.depth + f * pos.aim
    | Down(d) -> pos.aim <- pos.aim + d
    | Up(u) -> pos.aim <- pos.aim - u
  pos.distance * pos.depth

let parseCommand (line: string) =
    match line.Split ' ' with
    | [|"forward"; f|] -> Forward(f |> int)
    | [|"down"; d|] -> Down(d |> int)
    | [|"up"; u|] -> Up(u |> int)
    | _ -> raise(System.ArgumentException($"Bad input '{line}'"))

[<EntryPoint>]
let main argv =
    let input = (System.IO.File.ReadLines("input.txt")
        |> Seq.map parseCommand
        |> Seq.toArray)

    printfn "F#\n%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> input |> solutionPart1 |> string
        | "part2" -> input |> solutionPart2 |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code