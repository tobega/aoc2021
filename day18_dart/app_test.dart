import 'package:test/test.dart';
import 'app.dart';

void main() {
  group('explode', () {
    test('explode simple', () {
      expect(
          SnailfishNumber.parse("[[[[9,8],1],2],3]")
              .add(SnailfishNumber.parse("4"))
              .toString(),
          equals("[[[[0,9],2],3],4]"));
    });
    test('explode more', () {
      expect(
          SnailfishNumber.parse("[3,[2,[1,[7,3]]]]")
              .add(SnailfishNumber.parse("[6,[5,[4,[3,2]]]]"))
              .toString(),
          equals("[[3,[2,[8,0]]],[9,[5,[7,0]]]]"));
    });
  });

  group('split', () {
    test("carries", () {
      expect(
          SnailfishNumber.parse("5")
              .add(SnailfishNumber.parse("[[[6,[7,1]],2],3]"))
              .toString(),
          equals("[[5,6],[[[0,7],3],3]]"));
    });
  });

  group('add', () {
    test("simple", () {
      expect(
          SnailfishNumber.parse("[[[[4,3],4],4],[7,[[8,4],9]]]")
              .add(SnailfishNumber.parse("[1,1]"))
              .toString(),
          equals("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"));
    });
    test("complex", () {
      expect(
          SnailfishNumber.parse(
                  "[[[[6,0],[7,7]],[[8,7],4]],[[[6,0],[6,6]],[[6,6],[7,0]]]]")
              .add(SnailfishNumber.parse(
                  "[[[0,[3,2]],1],[[0,[2,8]],[2,[0,4]]]]"))
              .toString(),
          equals("[[[[7,0],[7,7]],[[7,6],[6,6]]],[[[6,7],3],[[2,5],[0,5]]]]"));
    });
  });
}
