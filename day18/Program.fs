// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

type SnailfishAtom = | SnailfishAtom of nesting: int * value: int

let inc (SnailfishAtom(n,v)) = SnailfishAtom(n+1, v)

let push v s =
  match s with
  | [] -> s
  | SnailfishAtom(ns, vs) :: rest -> SnailfishAtom(ns, v+vs) :: rest

let rec deepen handled todo =
  match todo with
  | [] -> List.rev handled
  | SnailfishAtom(4, left) :: SnailfishAtom(4, right) :: tail ->
    deepen (SnailfishAtom(4, 0) :: (push left handled)) (push right tail)
  | a :: tail -> deepen ((inc a) :: handled) tail

let rec checksplits handled todo =
  match todo with
  | [] -> List.rev handled
  | SnailfishAtom(4, v) :: tail when v >= 10 ->
      let right = SnailfishAtom(4, 0) :: (push ((v+1)/2) tail)
      match (push (v/2) handled) with
      | [] -> checksplits [] right
      | backup :: rest -> checksplits rest (backup :: right)
  | SnailfishAtom(n, v) :: tail when v >= 10 -> checksplits handled (SnailfishAtom(n+1, v/2) :: SnailfishAtom(n+1, (v+1)/2) :: tail)
  | a :: tail -> checksplits (a :: handled) tail

let add (left: SnailfishAtom list) (right: SnailfishAtom list) =
  deepen [] (left @ right) |> checksplits []

let magnitude snailfishNumber =
  let rec getValue level atoms = 
    match atoms with
    | SnailfishAtom(h,v) :: rest when h = level -> (v, rest)
    | SnailfishAtom(h,v) :: rest when h > level ->
      let (left, tail) = getValue (level+1) (SnailfishAtom(h,v) :: rest)
      let (right, suffix) = getValue (level+1) tail
      (3 * left + 2 * right, suffix)
    | a -> failwith $"Out of sync {a}"
  getValue 0 snailfishNumber |> fst

let solutionPart1 (snailfishNumbers: seq<list<SnailfishAtom>>): int =
  snailfishNumbers |> (Seq.reduce add) |> magnitude

let rec pairs l = seq {  
    match l with 
    | h::t -> for e in t do yield h, e
              yield! pairs t
    | _ -> () } 

let addBoth p =
  seq {
    yield (magnitude (add (fst p) (snd p)))
    yield (magnitude (add (snd p) (fst p))) }

let solutionPart2 snailfishNumbers =
  snailfishNumbers |> Seq.toList |> pairs |> Seq.collect addBoth |> Seq.max

let parseSnailfishNumber (line: string) =
  let mutable depth = 0
  [ for c in line do
    match c with
    | '[' -> depth <- depth + 1
    | ']' -> depth <- depth - 1
    | ',' -> ()
    | v -> yield SnailfishAtom(depth, (int v) - (int '0')) ]


[<EntryPoint>]
let main argv =
    let input = (System.IO.File.ReadLines("input.txt")
        |> Seq.map parseSnailfishNumber)

    printfn "%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> solutionPart1 input |> string
        | "part2" -> solutionPart2 input |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code