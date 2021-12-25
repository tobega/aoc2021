import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Scanner;
import java.util.function.BiFunction;
import java.util.regex.Pattern;

public class DigitCalculator {
  private final List<Operation> steps;

  public DigitCalculator(List<Operation> steps) {
    this.steps = steps;
  }

  public Map<Long, Long> nextZs(Map<Long, Long> zs, BiFunction<Long, Long, Long> chooser) {
    Map<Long,Long> next = new HashMap<>();
    for (Map.Entry<Long, Long> entry : zs.entrySet()) {
      for (long digit = 1; digit <= 9; digit++) {
        EnumMap<Register, Long> memory = new EnumMap<>(Map.of(
            Register.w, digit,
            Register.x, 0L,
            Register.y, 0L,
            Register.z, entry.getKey()
        ));
        try {
          steps.forEach(op -> op.execute(memory));
          next.merge(memory.get(Register.z), entry.getValue() * 10 + digit, chooser);
        } catch (ArithmeticException e) {
          // Ignore
        }
      }
    }
    return next;
  }

  enum Register implements Operand {
    w,x,y,z;

    @Override
    public Long get(Map<Register, Long> memory) {
      return memory.get(this);
    }
  }

  @FunctionalInterface
  interface Operand {
    static Operand constant(String s) {
      long value = Long.parseLong(s);
      return (mem) -> value;
    }

    Long get(Map<Register, Long> memory);
  }

  enum Operator {
    add() {
      @Override
      void apply(Register r, Operand operand, Map<Register, Long> memory) {
        memory.put(r, memory.get(r) + operand.get(memory));
      }
    },
    mul {
      @Override
      void apply(Register r, Operand operand, Map<Register, Long> memory) {
        memory.put(r, memory.get(r) * operand.get(memory));
      }
    },
    div {
      @Override
      void apply(Register r, Operand operand, Map<Register, Long> memory) {
        if (operand.get(memory) == 0) throw new ArithmeticException();
        memory.put(r, memory.get(r) / operand.get(memory));
      }
    },
    mod {
      @Override
      void apply(Register r, Operand operand, Map<Register, Long> memory) {
        if (operand.get(memory) <= 0) throw new ArithmeticException();
        if (memory.get(r) < 0) throw new ArithmeticException();
        memory.put(r, memory.get(r) % operand.get(memory));
      }
    },
    eql {
      @Override
      void apply(Register r, Operand operand, Map<Register, Long> memory) {
        memory.put(r, memory.get(r).equals(operand.get(memory)) ? 1L : 0L);
      }
    };

    abstract void apply(Register r, Operand operand, Map<Register, Long> memory);
  }

  record Operation(Operator operator, Register register, Operand operand){

    public void execute(EnumMap<Register, Long> memory) {
      operator.apply(register, operand, memory);
    }
  }

  public static DigitCalculator parse(String program) {
    List<Operation> steps = new Scanner(program)
        .findAll(Pattern.compile("(add|mul|div|mod|eql) ([wxyz]) (([wxyz])|(-?\\d+))"))
        .map(m -> new Operation(
            Operator.valueOf(m.group(1)),
            Register.valueOf(m.group(2)),
            Optional.ofNullable(m.group(4))
                .map(s -> (Operand) Register.valueOf(s))
                .orElseGet(() -> Operand.constant(m.group(5)))
        )).toList();
    return new DigitCalculator(steps);
  }
}
