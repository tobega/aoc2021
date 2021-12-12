import ballerina/io;
import ballerina/os;

type Connection record {
  readonly string 'from;
  readonly string to;
};

Connection[] input = check readInput();

public function main() {
    io:println("Ballerina");
    string part = os:getEnv("part");
    io:println(solve(part));
}

function readInput() returns Connection[]|error {
    string[] lines = check io:fileReadLines("input.txt");
    Connection[] connections = [];
    foreach var line in lines {
      int dash = line.indexOf("-") ?: 0;
      string a = line.substring(0, dash);
      string b = line.substring(dash+1);
      connections.push({'from:a, to: b});
      connections.push({'from:b, to: a});
    }
    return connections;
}

function solve(string part) returns string {
    match part {
      ""|"part1" => {
        return solutionPart1().toString();
      }
      "part2" => {
        return solutionPart2().toString();
      }
      _ => {
        return "Unknown part " + part;
      }
    }
}

function solutionPart1() returns int {
    return findPaths("start", "end", input, false, ["start"]);
}

function findPaths(string 'start, string end, Connection[] connections, boolean canRevisit, string[] visited) returns int {
  int paths = 0;
  Connection[] remaining = connections;
  if ('start == "start" || !canRevisit && 'start == 'start.toLowerAscii()) {
    remaining = from var {'from, to} in connections
                where 'from != 'start && to != 'start
                select {'from, to};
  }
  Connection[] nextLegs = connections.filter(function(Connection c) returns boolean {return c.'from == 'start;});
  foreach Connection leg in nextLegs {
    if (leg.to == end) {
      paths = paths + 1;
      continue;
    }
    boolean canStillRevisit = canRevisit;
    string[] newVisited = [leg.to];
    foreach string v in visited {
      newVisited.push(v);
      if (v == v.toLowerAscii()) {
        canStillRevisit = canStillRevisit && v != leg.to;
      }
    }

    Connection[] stillRemaining = remaining;
    if (canRevisit && !canStillRevisit) {
      foreach var v in visited {
        if (v == v.toLowerAscii()) {
          stillRemaining = from var {'from, to} in stillRemaining
                where to != v
                select {'from, to};
        }
      }
    }

    paths = paths + findPaths(leg.to, end, stillRemaining, canStillRevisit, newVisited);
  }
  return paths;
}

function solutionPart2() returns int {
    return findPaths("start", "end", input, true, ["start"]);
}

