// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System
open System.Text.RegularExpressions

type Point = int*int*int
type Beacons = Set<Point>
type Scanner = Point * Beacons

let translate scanner (dx, dy, dz) = Set (seq { for (x, y, z) in scanner -> (x+dx, y+dy, z+dz)})

let flip scanner (mx, my, mz) = Set (seq { for (x, y, z) in scanner -> (x*mx, y*my, z*mz)})

let faceY scanner = Set (seq { for (x, y, z) in Set.toSeq scanner -> (y, -x, z)})

let faceZ scanner = Set (seq { for (x, y, z) in Set.toSeq scanner -> (z, y, -x)})

let roll scanner = Set (seq { for (x, y, z) in Set.toSeq scanner -> (x, z, -y)})

let matching origin scanner = (Set.intersect origin scanner |> Set.count) >= 12

let alignments origin scanner =
  [for (ox, oy, oz) in (Set.toSeq origin |> Seq.skip 11) do for (sx, sy, sz) in (Set.toSeq scanner |> Seq.skip 11) -> (ox-sx, oy-sy, oz-sz)]

let align (origin: Beacons) scanner =
  let rec tryAlign aligns = 
    match aligns with
    | [] -> None
    | a :: rest ->
      let aligned = translate scanner a
      if matching origin aligned then
        Some(a, aligned)
      else
        tryAlign rest
  tryAlign (alignments origin scanner)

let findRoll (aligned: List<Scanner>) (scanner: Beacons) =
  let rec tryRoll (origin: Beacons) =
    match align origin scanner with
    | Some(rolled) -> Some(rolled)
    | None ->
      let roll1 = roll scanner
      match align origin roll1 with
      | Some(flipped) -> Some(flipped)
      | None ->
        let roll2 = roll roll1
        match align origin roll2 with
        | Some(flipped) -> Some(flipped)
        | None -> align origin (roll roll2)
  let rec tryOrigin (remaining: List<Scanner>) =
    match remaining with
    | [] -> None
    | origin :: rest ->
      match tryRoll (snd origin) with
      | Some(rolled) -> Some(rolled)
      | None -> tryOrigin rest
  tryOrigin aligned

let findFlip (aligned: List<Scanner>) (next: Beacons) =
  match (findRoll aligned next) with
  | Some(scanner) -> Some(scanner)
  | None -> findRoll aligned (flip next (-1, -1, 1))

let findFacing (aligned: List<Scanner>) (next: Beacons) =
  match (findFlip aligned next) with
  | Some(scanner) -> Some(scanner)
  | None ->
    let toY = faceY next
    match findFlip aligned toY with
    | Some(scanner) -> Some(scanner)
    | None -> findFlip aligned (faceZ toY)

let consolidate ((origin :: scanners):List<Beacons>) =
  let rec alignAll (aligned: List<Scanner>) (unaligned: (List<Beacons> * List<Beacons>)) =
    match unaligned with
    | ([], []) -> aligned
    | (missed, []) -> alignAll aligned ([], missed)
    | (missed, next :: rest) ->
      match (findFacing aligned next) with
      | Some(oriented) -> alignAll (oriented :: aligned) (missed, rest)
      | None -> alignAll aligned (next :: missed, rest)
  alignAll [(0,0,0), origin] ([], scanners)

let solutionPart1 input =
  consolidate input |> List.map snd |> List.reduce Set.union |> Set.count

let rec pairs l = seq {  
    match l with 
    | h::t -> for e in t do yield h, e
              yield! pairs t
    | _ -> () } 

let manhattanDistance ((x1,y1,z1),(x2,y2,z2)) = (abs (x1 - x2)) + (abs (y1 - y2)) + (abs (z1 - z2))

let solutionPart2 input =
  consolidate input |> List.map fst |> pairs |> Seq.map manhattanDistance |> Seq.max

let (|Beacon|_|) line =
  let m = Regex("(-?\d+),(-?\d+),(-?\d+)").Match(line)
  if m.Success
  then Some (m.Groups.[1].Value |> int, m.Groups.[2].Value |> int, m.Groups.[3].Value |> int)
  else None


let parseScanners (lines: seq<string>) =
  let mutable scanners = []
  let mutable currentScanner:Beacons = Set.empty
  for line in lines do
    match line with
    | "" -> scanners <- currentScanner :: scanners; currentScanner <- Set.empty
    | Beacon (x, y, z) -> currentScanner <- currentScanner.Add (x, y, z)
    | _ -> ()
  currentScanner :: scanners


[<EntryPoint>]
let main argv =
    let input = (System.IO.File.ReadLines("input.txt")
        |> parseScanners)

    printfn "%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> solutionPart1 input |> string
        | "part2" -> solutionPart2 input |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code