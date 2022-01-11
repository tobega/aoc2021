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
    private final int[] calledAt;
    private final int[] numbers;
    private final List<Board> boards;

    public Main(int[] numbers, List<Board> boards) {
        this.numbers = numbers;
        this.calledAt = new int[numbers.length];
        for (int i = 0; i < numbers.length; i++) {
            calledAt[numbers[i]] = i;
        }
        this.boards = boards;
    }

    private static class Board {
        private final int[][] board;

        public Board(int[][] board) {
            this.board = board;
        }

        public int callsToCompletion(int[] calledAt) {
            int[] rowMax = new int[5];
            int[] colMax = new int[5];
            for (int r = 0; r < board.length; r++) {
                for (int c = 0; c < board[r].length; c++) {
                    rowMax[r] = Math.max(rowMax[r], calledAt[board[r][c]]);
                    colMax[c] = Math.max(colMax[c], calledAt[board[r][c]]);
                }
            }
            return IntStream.concat(Arrays.stream(rowMax), Arrays.stream(colMax)).min().orElse(-1);
        }

        public long getScore(int[] calledAt, int call) {
            return Arrays.stream(board).flatMapToInt(Arrays::stream).filter(number -> calledAt[number] > call).sum();
        }
    }

    private void part1() {
        int lowestCalls = Integer.MAX_VALUE;
        Board winner = null;
        for (Board board : boards) {
            int calls = board.callsToCompletion(calledAt);
            if (calls >= 0 && calls < lowestCalls) {
                lowestCalls = calls;
                winner = board;
            }
        }
        System.out.println(winner.getScore(calledAt, lowestCalls) * numbers[lowestCalls]);
    }

    private void part2() {
        int highestCalls = -1;
        Board winner = null;
        for (Board board : boards) {
            int calls = board.callsToCompletion(calledAt);
            if (calls > highestCalls) {
                highestCalls = calls;
                winner = board;
            }
        }
        System.out.println(winner.getScore(calledAt, highestCalls) * numbers[highestCalls]);
    }

    public static void main(String[] args) throws IOException {
        BufferedReader reader = Files.newBufferedReader(Path.of("input.txt"));
        String[] calls = reader.readLine().split(",");
        int[] numbers = new int[calls.length];
        for (int i = 0; i < calls.length; i++) {
            numbers[i] = Integer.parseUnsignedInt(calls[i]);
        }
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
        int[][] board = new int[5][5];
        for (int r = 0; r < lines.size(); r++) {
            String[] row = lines.get(r).trim().split("\s+");
            for (int c = 0; c < row.length; c++) {
                int number = Integer.parseUnsignedInt(row[c]);
                board[r][c] = number;
            }
        }
        return new Board(board);
    }
}
