import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Main {
    private final List<Integer> numbers;
    private final List<Board> boards;

    public Main(List<Integer> numbers, List<Board> boards) {
        this.numbers = numbers;
        this.boards = boards;
    }

    private static class Board {
        private final Integer[] rowMap = new Integer[100];
        private final Integer[] colMap = new Integer[100];
        private final int[] rowMarks = new int[5];
        private final int[] colMarks = new int[5];


        public Board(List<List<Integer>> squares) {
            for (int r = 0; r < squares.size(); r++) {
                List<Integer> row = squares.get(r);
                for (int c = 0; c < row.size(); c++) {
                    rowMap[row.get(c)] = r;
                    colMap[row.get(c)] = c;
                }
            }
        }

        public int callsToCompletion(List<Integer> numbers) {
            for (int i = 0; i < numbers.size(); i++) {
                int number = numbers.get(i);
                Integer r = rowMap[number];
                if (r == null) continue;
                rowMap[number] = null;
                if (++rowMarks[r] == 5 ||
                    ++colMarks[colMap[number]] == 5) {
                    return i;
                }
            }
            return -1;
        }

        public long getScore() {
            return IntStream.range(0, 100).filter(i -> rowMap[i] != null).sum();
        }
    }

    private void part1() {
        int lowestCalls = Integer.MAX_VALUE;
        Board winner = null;
        for (Board board : boards) {
            int calls = board.callsToCompletion(numbers);
            if (calls >= 0 && calls < lowestCalls) {
                lowestCalls = calls;
                winner = board;
            }
        }
        System.out.println(winner.getScore() * numbers.get(lowestCalls));
    }

    private void part2() {
        int highestCalls = -1;
        Board winner = null;
        for (Board board : boards) {
            int calls = board.callsToCompletion(numbers);
            if (calls > highestCalls) {
                highestCalls = calls;
                winner = board;
            }
        }
        System.out.println(winner.getScore() * numbers.get(highestCalls));
    }

    public static void main(String[] args) throws IOException {
        BufferedReader reader = Files.newBufferedReader(Path.of("input.txt"));
        List<Integer> numbers = Arrays.stream(reader.readLine().split(","))
            .map(Integer::parseUnsignedInt).collect(
                Collectors.toList());
        reader.readLine();
        List<String> lines = reader.lines().filter(s -> !s.isEmpty())
            .collect(Collectors.toList());
        List<Board> boards = new ArrayList<>();
        for (int i = 0; i < lines.size(); i+=5) {
            boards.add(readBoard(lines.subList(i, i+5)));
        }
        if ("part2".equals(System.getenv("part"))) {
            new Main(numbers, boards).part2();
        } else {
            new Main(numbers, boards).part1();
        }
    }

    private static Board readBoard(List<String> lines) {
        List<List<Integer>> squares = lines.stream().map(s -> Arrays.stream(s.trim().split("\s+"))
                .map(Integer::parseUnsignedInt).collect(Collectors.toList()))
            .collect(Collectors.toList());
        return new Board(squares);
    }
}
