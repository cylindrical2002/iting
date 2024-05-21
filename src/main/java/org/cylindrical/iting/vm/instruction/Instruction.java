package org.cylindrical.iting.vm.instruction;

public abstract class Instruction {
    protected String opcode;
    protected String subOpcode;

    public Instruction(String opcode, String subOpcode) {
        this.opcode = opcode;
        this.subOpcode = subOpcode;
    }

    public abstract void run();

    @Override
    public String toString() {
        return "Abstract Instruction";
    }
}

