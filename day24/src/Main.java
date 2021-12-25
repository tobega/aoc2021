import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.stream.Collectors;

public class Main {

    private final List<DigitCalculator> digitCalculators;

    public Main(List<DigitCalculator> digitCalculators) {
        this.digitCalculators = digitCalculators;
    }

    private void part1() {
        var zs = Map.of(0L,0L);
        for (DigitCalculator dc : digitCalculators) {
            zs = dc.nextZs(zs, (ov, nv) -> ov >= nv ? ov : nv);
        }
        System.out.println(zs.get(0L));
    }

    private void part2() {
        var zs = Map.of(0L,0L);
        for (DigitCalculator dc : digitCalculators) {
            zs = dc.nextZs(zs, (ov, nv) -> ov <= nv ? ov : nv);
        }
        System.out.println(zs.get(0L));
    }

    public static void main(String[] args) throws IOException {
        Scanner scanner = new Scanner(Files.newBufferedReader(Path.of("input.txt")));
        List<DigitCalculator> digitCalculators = scanner.useDelimiter("inp w\n").tokens()
            .map(DigitCalculator::parse).collect(Collectors.toList());
        long maxZ = (long) Math.pow(26, 8);
        for (int i = 0; i < digitCalculators.size(); i++) {
            if (i > 6) maxZ /= 26;
            digitCalculators.get(i).setMaxZ(maxZ);
        }
        if ("part2".equals(System.getenv("part"))) {
            new Main(digitCalculators).part2();
        } else {
            new Main(digitCalculators).part1();
        }
    }
}
