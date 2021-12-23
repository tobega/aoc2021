import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

class Range {
  int min, max;
  Range(this.min, this.max);

  int count() {
    return max - min + 1;
  }

  String toString() {
    return "$min..$max";
  }

  Range copy() {
    return Range(min, max);
  }
}

class Dimension {
  Range range;
  List<Dimension> children;

  Dimension(this.range, this.children);

  Dimension.ofCubes(Iterable<Range> cubes) {
    this.range = cubes.first;
    this.children = cubes.length > 1 ? [Dimension.ofCubes(cubes.skip(1))] : [];
  }

  int count() {
    return range.count() *
        (children.isEmpty
            ? 1
            : children.fold(0, (s, child) => s + child.count()));
  }

  void applyState(Iterable<Range> cubes, bool turnOn) {
    if (cubes.isEmpty) return;
    Range top = cubes.first.copy();
    List<Dimension> result = [];
    for (var child in children) {
      if (top.min > child.range.max || child.range.min > top.max) {
        result.add(child);
        continue;
      }
      if (child.range.min < top.min) {
        var right = min(child.range.max, top.min - 1);
        result.add(Dimension(Range(child.range.min, right), child.children));
        if (right < child.range.max)
          child = Dimension(Range(right + 1, child.range.max), child.children);
      }
      if (top.max >= child.range.min) {
        var right = min(child.range.max, top.max);
        var leftSplit =
            Dimension(Range(child.range.min, right), child.children);
        leftSplit.applyState(cubes.skip(1), false);
        if (!leftSplit.children.isEmpty) result.add(leftSplit);
        if (child.range.max >= right + 1) {
          var rightSplit =
              Dimension(Range(right + 1, child.range.max), child.children);
          result.add(rightSplit);
        }
      }
    }
    if (turnOn) {
      var child = Dimension(
          top, cubes.length > 1 ? [Dimension.ofCubes(cubes.skip(1))] : []);
      result.add(child);
    }
    children = result;
  }

  List<String> show() {
    return children.isEmpty
        ? ["$range"]
        : children.expand((e) => e.show()).map((e) => "$range:$e").toList();
  }

  String toString() {
    return show().toString();
  }
}

RegExp linePattern = RegExp(
    r"(?<state>on|off) x=(?<minx>-?\d+)\.\.(?<maxx>-?\d+),y=(?<miny>-?\d+)\.\.(?<maxy>-?\d+),z=(?<minz>-?\d+)\.\.(?<maxz>-?\d+)");

class CubeInstruction {
  String state;
  List<Range> cubes;

  CubeInstruction.fromLine(String line) {
    var match = linePattern.firstMatch(line);
    this.state = match?.namedGroup("state");
    var x = Range(int.parse(match?.namedGroup("minx")),
        int.parse(match?.namedGroup("maxx")));
    var y = Range(int.parse(match?.namedGroup("miny")),
        int.parse(match?.namedGroup("maxy")));
    var z = Range(int.parse(match?.namedGroup("minz")),
        int.parse(match?.namedGroup("maxz")));
    this.cubes = [x, y, z];
  }

  bool isInitialization() {
    return cubes.first.min >= -50 &&
        cubes.first.min <= 50 &&
        cubes.first.max >= -50 &&
        cubes.first.max <= 50;
  }

  void apply(Dimension universe) {
    universe.applyState(cubes, state == "on");
  }
}

int solutionPart1(List<CubeInstruction> input) {
  var universe = Dimension(Range(0, 0), []);
  input
      .where((instruction) => instruction.isInitialization())
      .forEach((instruction) => instruction.apply(universe));
  return universe.count();
}

int solutionPart2(List<CubeInstruction> input) {
  var universe = Dimension(Range(0, 0), []);
  input.forEach((instruction) => instruction.apply(universe));
  return universe.count();
}

void main() async {
  List<CubeInstruction> input = await parseInput("input.txt");
  String part = Platform.environment["part"] ?? "part1";
  if (part == "part1") {
    print(solutionPart1(input));
  } else if (part == "part2") {
    print(solutionPart2(input));
  } else {
    print("Unknown part " + part);
  }
}

Future<List<CubeInstruction>> parseInput(String path) async {
  return await new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) => CubeInstruction.fromLine(line))
      .toList();
}
