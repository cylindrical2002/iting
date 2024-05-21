package org.cylindrical.iting.vm;

import java.util.HashMap;
import java.util.Map;

public class ItingVM {
    private final Map<String, Integer> registers = new HashMap<>();

    public void run(String itingAsm) {
        String[] lines = itingAsm.split("\n");
        for (String line : lines) {
            execute(line);
        }
    }

    private void execute(String instruction) {
        String[] parts = instruction.split(" ");
        String command = parts[0];

        switch (command) {
            case "set" -> registers.put(parts[1], Integer.parseInt(parts[2]));
            case "add" -> {
                int result = registers.get(parts[1]) + registers.get(parts[2]);
                registers.put(parts[3], result);
            }
            case "return" -> System.out.println(registers.get(parts[1]));
            default -> throw new IllegalArgumentException("Unknown command: " + command);
        }
    }
}
