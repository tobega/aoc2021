import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

int solutionPart1(Page page) {
  return fold(page.points, page.instructions[0]).length;
}

Set<Point<int>> fold(Set<Point<int>> points, String instruction) {
  var parts = instruction.split("=");
  if (parts[0].endsWith("x")) {
    return foldX(points, int.parse(parts[1]));
  } else {
    return foldY(points, int.parse(parts[1]));
  }
}

Set<Point<int>> foldX(Set<Point<int>> points, int fold) {
  return points.map((p) {
    if (p.x < fold) {
      return p;
    } else {
      return Point(fold - (p.x - fold), p.y);
    }
  }).toSet();
}

Set<Point<int>> foldY(Set<Point<int>> points, int fold) {
  return points.map((p) {
    if (p.y < fold) {
      return p;
    } else {
      return Point(p.x, fold - (p.y - fold));
    }
  }).toSet();
}

void solutionPart2(Page page) {
  Set<Point<int>> folded = page.points;
  for (String instruction in page.instructions) {
    folded = fold(folded, instruction);
  }
  printPoints(folded);
}

void printPoints(Set<Point<int>> folded) {
  int right =
      folded.fold(0, (previousValue, element) => max(previousValue, element.x));
  int bottom =
      folded.fold(0, (previousValue, element) => max(previousValue, element.y));
  List<List<String>> code =
      List.generate(bottom + 1, (_) => List.filled(right + 1, " "));
  for (Point p in folded) {
    code[p.y][p.x] = "\u25A0";
  }
  for (var line in code) {
    print(line);
  }
}

void main() async {
  Page page = await parseInput("input.txt");
  String part = Platform.environment["part"] ?? "part1";
  if (part == "part1") {
    print(solutionPart1(page));
  } else if (part == "part2") {
    solutionPart2(page);
  } else {
    print("Unknown part " + part);
  }
}

class Page {
  Set<Point<int>> points;
  List<String> instructions;

  Page(this.points, this.instructions);
}

Future<Page> parseInput(String path) async {
  List<String> lines = await new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .toList();
  Set<Point<int>> points = new Set();
  Iterator<String> it = lines.iterator;
  while (it.moveNext() && it.current.isNotEmpty) {
    var vals = it.current.split(",");
    points.add(new Point(int.parse(vals[0]), int.parse(vals[1])));
  }
  List<String> instructions = [];
  while (it.moveNext()) {
    instructions.add(it.current);
  }
  return Page(points, instructions);
}
