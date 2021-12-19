// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System
open System.Text.RegularExpressions

type Scanner = Set<int*int*int>

let translate scanner (dx, dy, dz) = Set (seq { for (x, y, z) in scanner -> (x+dx, y+dy, z+dz)})

let flip scanner (mx, my, mz) = Set (seq { for (x, y, z) in scanner -> (x*mx, y*my, z*mz)})

let roll scanner = Set (seq { for (x, y, z) in Set.toSeq scanner -> (y, z, x)})

let matching origin scanner = (Set.intersect origin scanner |> Set.count) >= 12

let flips = [ for mx in [1;-1] do for my in [1;-1] do for mz in [1;-1] do mx,my,mz ]

let alignments origin scanner =
  [for (ox, oy, oz) in (Set.toSeq origin |> Seq.skip 11) do for (sx, sy, sz) in (Set.toSeq scanner |> Seq.skip 11) -> (ox-sx, oy-sy, oz-sz)]

let align origin scanner =
  let rec tryAlign aligns = 
    match aligns with
    | [] -> None
    | a :: rest ->
      let aligned = translate scanner a
      if matching origin aligned then
        Some(aligned)
      else
        tryAlign rest
  tryAlign (alignments origin scanner)

let findFlip aligned (scanner: Scanner) =
  let rec tryFlip origin flips =
    match flips with
    | [] -> None
    | f :: rest ->
      match align origin (flip scanner f) with
      | Some(flipped) -> Some(flipped)
      | None -> tryFlip origin rest
  let rec tryOrigin remaining =
    match remaining with
    | [] -> None
    | origin :: rest ->
      match tryFlip origin flips with
      | Some(flipped) -> Some(flipped)
      | None -> tryOrigin rest
  tryOrigin aligned

let findOrientation aligned (next: Scanner) =
  match (findFlip aligned next) with
  | Some(scanner) -> Some(scanner)
  | None ->
    let rolled = roll next
    match findFlip aligned rolled with
    | Some(scanner) -> Some(scanner)
    | None ->
      let rollrolled = roll rolled
      match findFlip aligned rollrolled with
      | Some(scanner) -> Some(scanner)
      | None ->
        let tangled = Set (seq { for (x, y, z) in Set.toSeq next -> (y, x, z)})
        findFlip aligned tangled

let consolidate ((origin :: scanners):List<Scanner>) =
  let rec alignAll aligned (unaligned: (List<Scanner> * List<Scanner>)) =
    match unaligned with
    | ([], []) -> aligned
    | (missed, []) -> alignAll aligned ([], missed)
    | (missed, next :: rest) ->
      match (findOrientation aligned next) with
      | Some(oriented) -> alignAll (oriented :: aligned) (missed, rest)
      | None -> alignAll aligned (next :: missed, rest)
  alignAll [origin] ([], scanners)

let solutionPart1 input =
  let beacons = consolidate input |> List.reduce Set.union
  for b in beacons do printfn "%A " b
  beacons |> Set.count

let solutionPart2 input =
  0

let (|Beacon|_|) line =
  let m = Regex("(-?\d+),(-?\d+),(-?\d+)").Match(line)
  if m.Success
  then Some (m.Groups.[1].Value |> int, m.Groups.[2].Value |> int, m.Groups.[3].Value |> int)
  else None


let parseScanners (lines: seq<string>) =
  let mutable scanners = []
  let mutable currentScanner:Scanner = Set.empty
  for line in lines do
    match line with
    | "" -> scanners <- currentScanner :: scanners; currentScanner <- Set.empty
    | Beacon (x, y, z) -> currentScanner <- currentScanner.Add (x, y, z)
    | _ -> ()
  currentScanner :: scanners


[<EntryPoint>]
let main argv =
    let input = (System.IO.File.ReadLines("input_test.txt")
        |> parseScanners)

    printfn "%s" (
        match Environment.GetEnvironmentVariable("part") with
        | null | "part1" -> solutionPart1 input |> string
        | "part2" -> solutionPart2 input |> string
        | env -> $"Unknown value {env}"
    )
    0 // return an integer exit code