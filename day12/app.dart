import 'dart:io';
import 'dart:convert';
import 'dart:async';

class _Cave {
  List<_Cave> connected = [];
  void addPath(_Cave to) {
    connected.add(to);
  }

  int countPaths(Set<_SmallCave> visited, bool canRevisit) {
    return connected
        .map((c) => c.countPaths(visited, canRevisit))
        .reduce((value, element) => value + element);
  }
}

class _End extends _Cave {
  int countPaths(Set<_SmallCave> visited, bool canRevisit) {
    return 1;
  }
}

class _SmallCave extends _Cave {
  int countPaths(Set<_SmallCave> visited, bool canRevisit) {
    bool canStillRevisit = canRevisit;
    if (visited.contains(this)) {
      if (canRevisit) {
        canStillRevisit = false;
      } else {
        return 0;
      }
    }
    // This is unsafe for general use. Assuming DFS.
    visited.add(this);
    try {
      return super.countPaths(visited, canStillRevisit);
    } finally {
      if (canRevisit == canStillRevisit) visited.remove(this);
    }
  }
}

int solutionPart1(_Cave start) {
  return start.countPaths(new Set(), false);
}

int solutionPart2(_Cave start) {
  return start.countPaths(new Set(), true);
}

void main() async {
  print('Dart');
  _Cave start = await parseInput("input.txt");
  String part = Platform.environment["part"] ?? "part1";
  if (part == "part1") {
    print(solutionPart1(start));
  } else if (part == "part2") {
    print(solutionPart2(start));
  } else {
    print("Unknown part " + part);
  }
}

Future<_Cave> parseInput(String path) async {
  List<String> lines = await new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .toList();
  Map<String, _Cave> caves = new Map();
  for (String line in lines) {
    var names = line.split("-");
    if (names[1] != "start" && names[0] != "end") {
      caves
          .putIfAbsent(names[0], () => create(names[0]))
          .addPath(caves.putIfAbsent(names[1], () => create(names[1])));
    }
    if (names[0] != "start" && names[1] != "end") {
      caves
          .putIfAbsent(names[1], () => create(names[1]))
          .addPath(caves.putIfAbsent(names[0], () => create(names[0])));
    }
  }
  return caves["start"];
}

create(String name) {
  if (name == "start")
    return new _Cave();
  else if (name == "end")
    return new _End();
  else if (name[0].toLowerCase() == name[0])
    return new _SmallCave();
  else
    return new _Cave();
}
