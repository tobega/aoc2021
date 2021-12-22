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

  void addToChildren(Iterable<Range> cubes) {
    if (cubes.isEmpty) return;
    Range top = cubes.first;
    List<Dimension> result = [];
    for (var child in children) {
      if (top.max < top.min || top.min > child.range.max) {
        result.add(child);
        continue;
      }
      if (top.min < child.range.min) {
        int right = min(top.max, child.range.min - 1);
        result.add(Dimension(Range(top.min, right),
            cubes.length > 1 ? [Dimension.ofCubes(cubes.skip(1))] : []));
        top.min = right + 1;
      }
      if (top.max >= child.range.min) {
        var right = min(child.range.max, top.max);
        var leftSplit =
            Dimension(Range(child.range.min, right), child.children);
        leftSplit.addToChildren(cubes.skip(1));
        result.add(leftSplit);
        if (child.range.max > right + 1) {
          result.add(
              Dimension(Range(right + 1, child.range.max), child.children));
        }
        top.min = right + 1;
      }
    }
    if (top.max >= top.min) {
      var child = Dimension(
          top, cubes.length > 1 ? [Dimension.ofCubes(cubes.skip(1))] : []);
      result.add(child);
    }
    children = result;
  }

  void removeFromChildren(Iterable<Range> cubes) {
    if (cubes.isEmpty) return;
    Range top = cubes.first;
    List<Dimension> result = [];
    for (var child in children) {
      if (top.max < top.min || top.min > child.range.max) {
        result.add(child);
        continue;
      }
      if (top.min < child.range.min) {
        top.min = child.range.min;
      }
      if (top.max >= child.range.min) {
        var right = min(child.range.max, top.max);
        var leftSplit =
            Dimension(Range(child.range.min, right), child.children);
        leftSplit.removeFromChildren(cubes.skip(1));
        if (!leftSplit.children.isEmpty) result.add(leftSplit);
        if (child.range.max > right + 1) {
          result.add(
              Dimension(Range(right + 1, child.range.max), child.children));
        }
        top.min = right + 1;
      }
    }
    children = result;
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
    return cubes.first.min >= -50 && cubes.first.min <= 50;
  }

  void apply(Dimension universe) {
    if (state == "on") {
      universe.addToChildren(cubes);
    } else {
      universe.removeFromChildren(cubes);
    }
    print(universe.count());
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
  return 0;
}

void main() async {
  List<CubeInstruction> input = await parseInput("input_test.txt");
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
