// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System
open System.Text.RegularExpressions

type Point = int*int*int
type Beacons = List<Point>
type Scanner = Point * Beacons

let translate (dx, dy, dz) scanner = scanner |> List.map (fun (x, y, z) -> (x+dx, y+dy, z+dz))

let flip beacons =
  let rec flipX old flipped = match old with | [] -> flipped | (x,y,z) :: rest -> flipX rest ((-x,-y,z) :: flipped)
  flipX beacons []

let sortx = List.sortBy (fun (x,_,_) -> x)

let faceY scanner = scanner |> List.map (fun (x, y, z) -> (y, -x, z)) |> sortx

let faceZ scanner = scanner |> List.map (fun (x, y, z) -> (z, y, -x)) |> sortx

let rec roll n (scanner: Beacons) =
  match n with
  | 0 -> scanner
  | _ -> roll (n-1) (List.map (fun (x, y, z) -> (x, z, -y)) scanner)

let rec next n a sa b sb pairs = seq {
  if n = 0 then
    yield pairs
  else if sa < 0 || sb < 0 then
    ()
  else 
    let (xa, _, _) = List.head a
    let (xb, _, _) = List.head b
    let ((pa, _, _), (pb, _, _)) = List.head pairs
    if (xa - xb) = (pa - pb) then
      // if there are equal values, we need to select each in turn
      yield! a |> List.toSeq |> Seq.filter (fun (x,_,_) -> x = xa)
      |> Seq.map (fun beacon -> next (n-1) (a |> List.filter (fun b -> b <> beacon)) sa (List.tail b) sb ((beacon, List.head b) :: pairs))
      |> Seq.concat
      // and for b
      yield! b |> List.toSeq |> Seq.filter (fun (x,_,_) -> x = xb)
      |> Seq.map (fun beacon -> next (n-1) (List.tail a) sa (b |> List.filter (fun b -> b <> beacon)) sb ((List.head a, beacon) :: pairs))
      |> Seq.concat      
    else if xa > pa || xb > pb then
      if (xa - xb) > (pa - pb) then
        yield! next n a sa (List.tail b) (sb - 1) pairs
      else
        yield! next n (List.tail a) (sa - 1) b sb pairs
    else
      if (xa - xb) < (pa - pb) then
        yield! next n a sa (List.tail b) (sb - 1) pairs
      else
        yield! next n (List.tail a) (sa - 1) b sb pairs
}

let pick12 origin scanner =
  let rec allO no o origin b sb = seq {
    match origin with
    | [] -> yield! next 11 (List.tail o) (no - 12) (List.tail b) sb [(List.head o, List.head b)]
    | head :: tail ->
      yield! next 11 (List.tail o) (no - 12) (List.tail b) sb [(List.head o, List.head b)]
      yield! allO (no+1) (head :: o) tail b sb
  }
  let rec allS o origin ns s scanner = seq {
    match scanner with
    | [] -> yield! allO 12 o origin s (ns - 12)
    | head :: tail ->
      yield! allO 12 o origin s (ns - 12)
      yield! allS o origin (ns+1) (head :: s) tail
  }
  let rec doPick n o origin s scanner = seq {
    if n < 12 then
      yield! doPick (n+1) ((List.head origin) :: o) (List.tail origin) ((List.head scanner) :: s) (List.tail scanner)
    else
      yield! allS o origin 12 s scanner
  }
  doPick 0 [] origin [] scanner
  
let equidistance o12 s12 =
  let diffs = Seq.zip o12 s12 |> Seq.map (fun ((xo, yo, zo), (xs, ys, zs)) -> (xo-xs, yo-ys, zo-zs))
  let diff = Seq.head diffs
  if (Seq.forall ((=) diff) (Seq.tail diffs)) then
    Some(diff)
  else
    None

let alignX (aligned: List<Scanner>) (scanner: Beacons): option<Scanner> =
  let rec tryRoll r (o12: Beacons) (s12: Beacons) =
    let mutable rolled = s12
    if r = 4 then
      None
    else
      if r > 0 then do
        rolled <- (roll 1 rolled)
      match equidistance o12 rolled with
      | Some(diff) -> Some(r, diff)
      | None -> tryRoll (r+1) o12 rolled
      
  let rec findAlignment alignments =
    if Seq.isEmpty alignments then
      None
    else
      match tryRoll 0 (Seq.head alignments |> Seq.map fst |> Seq.toList) (Seq.head alignments |> Seq.map snd |> Seq.toList) with
      | None -> findAlignment (Seq.tail alignments)
      | found -> found
  
  let rec tryOrigin (remaining: List<Scanner>): option<Scanner> =
    match remaining with
    | [] -> None
    | origin :: rest ->
      match findAlignment (pick12 (snd origin) scanner) with
      | Some(rolls, offset) -> Some(offset, scanner |> roll rolls |> translate offset)
      | None -> tryOrigin rest
  tryOrigin aligned

let findFlip (aligned: List<Scanner>) (next: Beacons) =
  match (alignX aligned next) with
  | Some(scanner) -> Some(scanner)
  | None -> alignX aligned (flip next)

let findFacing (aligned: List<Scanner>) (next: Beacons): option<Scanner> =
  match (findFlip aligned next) with
  | Some(scanner) -> Some(scanner)
  | None ->
    let toY = faceY next
    match findFlip aligned toY with
    | Some(scanner) -> Some(scanner)
    | None -> findFlip aligned (faceZ toY)

let consolidate (beacons:List<Beacons>) =
  let rec alignAll (aligned: List<Scanner>) (unaligned: (List<Beacons> * List<Beacons>)) prev_missed =
    match unaligned with
    | ([], []) -> aligned
    | (missed, []) when (List.length missed) = prev_missed -> failwith "cannot match"
    | (missed, []) -> alignAll aligned ([], missed) (List.length missed)
    | (missed, next :: rest) ->
      match (findFacing aligned next) with
      | Some(oriented) -> alignAll (oriented :: aligned) (missed, rest) prev_missed
      | None -> alignAll aligned (next :: missed, rest) prev_missed
  match beacons with
  | origin :: scanners -> alignAll [(0,0,0), origin] ([], scanners) 0
  | _ -> failwith "empty list of beacons"

let solutionPart1 input =
  consolidate input |> List.map snd |> List.map Set |> List.reduce Set.union |> Set.count

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
  let mutable currentScanner:Beacons = []
  for line in lines do
    match line with
    | "" -> scanners <- (sortx currentScanner) :: scanners; currentScanner <- []
    | Beacon (x, y, z) -> currentScanner <- (x, y, z) :: currentScanner
    | _ -> ()
  (sortx currentScanner) :: scanners


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