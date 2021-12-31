// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

let getbits (image: int array array) ci ri =
  let clampcol n = min (image.Length - 1) (max 0 n)
  let row = min (image.[0].Length - 1) (max 0 ri)
  (image.[clampcol (ci - 1)].[row] <<< 2) + (image.[clampcol ci].[row] <<< 1) + image.[clampcol (ci + 1)].[row]


let enhanceColumn (rules: int array) image ci (column: int array) =
  let mutable mask = ((getbits image ci -2) <<< 3) + getbits image ci -1
  [| for i in -1 .. column.Length ->
      mask <- ((mask <<< 3) &&& 511) + getbits image ci (i + 1)
      rules.[mask]
  |]

let pad (image: int array array) = Array.concat [[|Array.create image.[0].Length image.[0].[0]|]; image; [|Array.create image.[0].Length image.[0].[0]|]]

let solutionPart1 rules image =
  let mutable next = image |> pad
  for _ in 1..2 do
    next <- next |> Array.mapi (enhanceColumn rules next) |> pad
  next |> Array.sumBy Array.sum

let solutionPart2 rules image =
  let mutable next = image |> pad
  for _ in 1..50 do
    next <- next |> Array.mapi (enhanceColumn rules next) |> pad
  next |> Array.sumBy Array.sum

let frame (b:int) (a: int array array) =
  Array.concat [ [|Array.create (a.[0].Length + 2) b|]; [|for cs in a -> Array.concat [[| b |]; cs; [| b |]] |]; [| Array.create (a.[0].Length + 2) b |] ]

let bitify (s:string) = s |> Seq.map (fun c -> if c = '#' then 1 else 0) |> Seq.toArray

[<EntryPoint>]
let main argv =
  use sr = new IO.StreamReader("input.txt")
  let rules = sr.ReadLine() |> bitify
  sr.ReadLine() |> ignore
  // image is transposed so we can more easily work on columns
  let image = [| for i in seq { while not sr.EndOfStream do yield sr.ReadLine() |> bitify} -> i |] |> frame 0 |> Array.transpose
  
  printfn "%s" (
      match Environment.GetEnvironmentVariable("part") with
      | null | "part1" -> solutionPart1 rules image |> string
      | "part2" -> solutionPart2 rules image |> string
      | env -> $"Unknown value {env}"
  )
  0 // return an integer exit code