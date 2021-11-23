module Aoc
open System.Collections.Generic
open System

let mutable primes = [2]
let mutable top = 2

let rec isPrime n =
  let getPrimeCandidates upTo =
    while top < upTo do
      top <- top + 1
      primes <-
        if isPrime top then
          top :: primes
        else
          primes
    primes |> List.filter (fun p -> p <= upTo)
  let rec isDivisible ps =
    match ps with
    | [] -> false
    | p :: _ when n % p = 0 -> true
    | _ :: [] -> false
    | _ :: rest -> isDivisible rest
  not (isDivisible (getPrimeCandidates (int(Math.Sqrt (float n)))))
    

let solutionPart1 (input:int[]) =
  input |> Array.mapi (fun i n -> if isPrime n then i * n else 0 ) |> Array.sum

let solutionPart2 (input:int[]) =
  input |> Array.mapi (fun i n -> if isPrime n then 0 elif i % 2 = 0 then n else -n) |> Array.sum
