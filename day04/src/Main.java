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
        private final int[] rowMap;
        private final int[] colMap;
        private final int[] rowMarks = new int[5+1];
        private final int[] colMarks = new int[5+1];


        public Board(int[] rowMap, int[] colMap) {
            this.rowMap = rowMap;
            this.colMap = colMap;
        }

        public int callsToCompletion(List<Integer> numbers) {
            for (int i = 0; i < numbers.size(); i++) {
                int number = numbers.get(i);
                int r = rowMap[number];
                if (r == 0) continue;
                rowMap[number] = 0;
                if (++rowMarks[r] == 5 ||
                    ++colMarks[colMap[number]] == 5) {
                    return i;
                }
            }
            return -1;
        }

        public long getScore() {
            return IntStream.range(0, 100).filter(i -> rowMap[i] != 0).sum();
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
        int[] rowMap = new int[100];
        int[] colMap = new int[100];
        for (int r = 0; r < lines.size(); r++) {
            String[] row = lines.get(r).trim().split("\s+");
            for (int c = 0; c < row.length; c++) {
                int number = Integer.parseUnsignedInt(row[c]);
                rowMap[number] = r+1;
                colMap[number] = c+1;
            }
        }
        return new Board(rowMap, colMap);
    }
}
