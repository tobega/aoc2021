// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

let rec det100 = seq { yield! seq {for i in 1 .. 100 -> i}; yield! det100}

let solutionPart1 p1 p2 =
  let rec play die rolls (pos, score) other =
    let nextPos = (pos - 1 + (Seq.sum (Seq.take 3 die))) % 10 + 1
    let nextScore = score + nextPos
    if nextScore >= 1000 then
      (rolls + 3, snd other)
    else
      play (Seq.skip 3 die) (rolls+3) other (nextPos, nextScore)
  let result = play det100 0 (p1, 0) (p2, 0)
  (fst result) * (snd result)

let dirac3 = seq { 1..3 }
let rolls: seq<int*int> = Seq.allPairs dirac3 dirac3 |> Seq.allPairs dirac3 |> Seq.map (fun (a,(b,c)) -> a + b + c) |> Seq.countBy id

let solutionPart2 p1 p2 =
  let rec play (active: int64 array array) (other: int64 array array) wa wo =
    let losingStates = other |> Array.map Array.sum |> Array.sum
    let mutable nextWins = 0L
    let nextState: int64 array array = [| for pos in 0..10 -> Array.zeroCreate 21 |]
    let spawn (pos: int) (scores: int64 array) =
      let nextPos = rolls |> Seq.map (fun (roll, count) -> ((roll + pos - 1) % 10 + 1, count))
      scores |> Array.iteri (fun score universes -> nextPos |> Seq.iter (fun (np, count) ->
        if score + np >= 21 then nextWins <- nextWins + int64(count) * universes * losingStates
        else Array.set nextState.[np] (score+np) (nextState.[np].[score+np] + int64(count) * universes))) |> ignore
    if losingStates = 0 then
      max wa wo
    else
      active |> Array.iteri spawn |> ignore
      play other nextState wo (wa + nextWins)
  let s1: int64 array array = [| for _ in 0..10 -> Array.zeroCreate 21 |]
  let s2: int64 array array = [| for _ in 0..10 -> Array.zeroCreate 21 |]
  Array.set s1.[p1] 0 1
  Array.set s2.[p2] 0 1
  play s1 s2 0L 0L

[<EntryPoint>]
let main argv =
  use sr = new IO.StreamReader("input.txt")
  let p1 = sr.ReadLine().[28..] |> int
  let p2 = sr.ReadLine().[28..] |> int
  
  printfn "%s" (
      match Environment.GetEnvironmentVariable("part") with
      | null | "part1" -> solutionPart1 p1 p2 |> string
      | "part2" -> solutionPart2 p1 p2 |> string
      | env -> $"Unknown value {env}"
  )
  0 // return an integer exit code