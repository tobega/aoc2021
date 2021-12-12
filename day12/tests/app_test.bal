import ballerina/test;

@test:Config {}
function testPart1() {
  test:assertEquals(findPaths("start", "end", [
    {'from: "start", to: "A"},
    {'from: "start", to: "b"},
    {'from: "A", to: "c"},
    {'from: "A", to: "b"},
    {'from: "b", to: "d"},
    {'from: "A", to: "end"},
    {'from: "b", to: "end"},
    {'from: "A", to: "start"},
    {'from: "b", to: "start"},
    {'from: "c", to: "A"},
    {'from: "b", to: "A"},
    {'from: "d", to: "b"},
    {'from: "end", to: "A"},
    {'from: "end", to: "b"}
  ], false, ["start"]), 10);
}

@test:Config {}
function testPart2a() {
  test:assertEquals(findPaths("start", "end", [
    {'from: "start", to: "A"},
    {'from: "start", to: "b"},
    {'from: "A", to: "c"},
    {'from: "A", to: "b"},
    {'from: "b", to: "d"},
    {'from: "A", to: "end"},
    {'from: "b", to: "end"},
    {'from: "A", to: "start"},
    {'from: "b", to: "start"},
    {'from: "c", to: "A"},
    {'from: "b", to: "A"},
    {'from: "d", to: "b"},
    {'from: "end", to: "A"},
    {'from: "end", to: "b"}
  ], true, ["start"]), 36);
}

@test:Config {}
function testPart2() {
  test:assertEquals(findPaths("start", "end", [
    {'from: "dc", to: "end"},
    {'from: "HN", to: "start"},
    {'from: "start", to: "kj"},
    {'from: "dc", to: "start"},
    {'from: "dc", to: "HN"},
    {'from: "LN", to: "dc"},
    {'from: "HN", to: "end"},
    {'from: "kj", to: "sa"},
    {'from: "kj", to: "HN"},
    {'from: "kj", to: "dc"},
    {'from: "end", to: "dc"},
    {'from: "start", to: "HN"},
    {'from: "kj", to: "start"},
    {'from: "start", to: "dc"},
    {'from: "HN", to: "dc"},
    {'from: "dc", to: "LN"},
    {'from: "end", to: "HN"},
    {'from: "sa", to: "kj"},
    {'from: "HN", to: "kj"},
    {'from: "dc", to: "kj"}
  ], true, ["start"]), 103);
}