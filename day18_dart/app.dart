import 'dart:io';
import 'dart:convert';
import 'dart:async';

class SnailfishOverflow {
  final int left;
  final int right;
  final SnailfishNumber? newChild;

  SnailfishOverflow(this.left, this.right, this.newChild)
      : assert(left > 0 || right > 0 || newChild != null);
}

abstract class SnailfishNumber {
  static SnailfishNumber parse(String line) {
    List<SnailfishNumber> stack = [];
    for (String s = line; s.isNotEmpty; s = s.substring(1)) {
      if (s.startsWith(RegExp(r'\d')))
        stack.add(SnailfishDigit(int.parse(s[0])));
      else if (s.startsWith(']')) {
        var right = stack.removeLast();
        var left = stack.removeLast();
        stack.add(SnailfishPair(left, right));
      }
    }
    if (stack.length != 1) throw 'Bad snailfish number';
    return stack[0];
  }

  SnailfishNumber add(SnailfishNumber other) {
    SnailfishNumber result = SnailfishPair(this.clone(), other.clone());
    SnailfishOverflow? overflow = result.explode(0);
    do {
      result = overflow?.newChild ?? result;
    } while ((overflow = result.split(0)) != null);
    return result;
  }

  SnailfishNumber clone() {
    return SnailfishNumber.parse(this.toString());
  }

  int magnitude();

  SnailfishOverflow? explode(int depth);
  SnailfishOverflow? split(int depth);

  void pushLeft(int value);
  void pushRight(int value);
}

class SnailfishDigit extends SnailfishNumber {
  int value;

  SnailfishDigit(int this.value);

  @override
  int magnitude() {
    return value;
  }

  @override
  SnailfishOverflow? explode(int depth) {
    return null;
  }

  @override
  SnailfishOverflow? split(int depth) {
    if (value >= 10) {
      var split = SnailfishPair(
          SnailfishDigit(value ~/ 2), SnailfishDigit((value + 1) ~/ 2));
      return split.explode(depth) ?? SnailfishOverflow(0, 0, split);
    }
    return null;
  }

  @override
  void pushLeft(int value) {
    this.value += value;
  }

  @override
  void pushRight(int value) {
    this.value += value;
  }

  @override
  String toString() {
    return value.toString();
  }
}

class SnailfishPair extends SnailfishNumber {
  SnailfishNumber left;
  SnailfishNumber right;

  SnailfishPair(SnailfishNumber this.left, SnailfishNumber this.right);

  @override
  int magnitude() {
    return 3 * left.magnitude() + 2 * right.magnitude();
  }

  @override
  SnailfishOverflow? explode(int depth) {
    if (depth == 4) {
      return SnailfishOverflow((left as SnailfishDigit).value,
          (right as SnailfishDigit).value, new SnailfishDigit(0));
    }
    var leftOverflow = left.explode(depth + 1);
    if (leftOverflow != null) {
      if (leftOverflow.newChild != null) {
        left = leftOverflow.newChild as SnailfishNumber;
      }
      if (leftOverflow.right > 0) {
        right.pushRight(leftOverflow.right);
      }
    }
    var rightOverflow = right.explode(depth + 1);
    if (rightOverflow != null) {
      if (rightOverflow.newChild != null) {
        right = rightOverflow.newChild as SnailfishNumber;
      }
      if (rightOverflow.left > 0) {
        left.pushLeft(rightOverflow.left);
      }
    }
    if ((leftOverflow != null && leftOverflow.left > 0) ||
        (rightOverflow != null && rightOverflow.right > 0)) {
      return new SnailfishOverflow(leftOverflow == null ? 0 : leftOverflow.left,
          rightOverflow == null ? 0 : rightOverflow.right, null);
    }
    return null;
  }

  @override
  SnailfishOverflow? split(int depth) {
    int rightAccumulated = 0;
    SnailfishOverflow? overflow = left.split(depth + 1);
    do {
      while (overflow != null) {
        if (overflow.newChild != null) {
          left = overflow.newChild as SnailfishNumber;
        }
        if (overflow.right > 0) {
          right.pushRight(overflow.right);
        }
        if (overflow.left > 0) {
          return SnailfishOverflow(overflow.left, rightAccumulated, null);
        }
        overflow = overflow.newChild == null ? null : left.split(depth + 1);
      }
      overflow = right.split(depth + 1);
      while (overflow != null) {
        if (overflow.newChild != null) {
          right = overflow.newChild as SnailfishNumber;
        }
        rightAccumulated += overflow.right;
        if (overflow.left > 0) {
          left.pushLeft(overflow.left);
          overflow = left.split(depth + 1);
          if (overflow != null) break;
        }
        overflow = right.split(depth + 1);
      }
    } while (overflow != null);
    if (rightAccumulated > 0) {
      return SnailfishOverflow(0, rightAccumulated, null);
    }
    return null;
  }

  @override
  void pushLeft(int value) {
    right.pushLeft(value);
  }

  @override
  void pushRight(int value) {
    left.pushRight(value);
  }

  @override
  String toString() {
    return "[" + left.toString() + "," + right.toString() + "]";
  }
}

int solutionPart1(List<SnailfishNumber> input) {
  return input.reduce((sum, next) => sum.add(next)).magnitude();
}

int solutionPart2(List<SnailfishNumber> input) {
  int maxMagnitude = 0;
  for (int i = 0; i < input.length; i++) {
    for (int j = 0; j < input.length; j++) {
      if (i == j) continue;
      var sum = input[i].add(input[j]);
      var magnitude = sum.magnitude();
      if (magnitude > maxMagnitude) {
        maxMagnitude = magnitude;
      }
    }
  }

  return maxMagnitude;
}

void main() async {
  print('Dart');
  List<SnailfishNumber> input = await parseInput("input.txt");
  String part = Platform.environment["part"] ?? "part1";
  if (part == "part1") {
    print(solutionPart1(input));
  } else if (part == "part2") {
    print(solutionPart2(input));
  } else {
    print("Unknown part " + part);
  }
}

Future<List<SnailfishNumber>> parseInput(String path) async {
  return new File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map(SnailfishNumber.parse)
      .toList();
}
