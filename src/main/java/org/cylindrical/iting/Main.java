package org.cylindrical.iting;

import org.apache.commons.cli.*;
import org.cylindrical.iting.ir.ItingIR;
import org.cylindrical.iting.vm.ItingVM;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class Main {
    private static final String VERSION = "1.0";

    public static void main(String[] args) {
        Options options = new Options();

        Option versionOpt = new Option("v", "version", false, "Print version information");
        Option helpOpt = new Option("h", "help", false, "Print this help message");
        Option runOpt = new Option("r", "run", true, "Run the specified .iting or .itingasm file (default)");
        Option asmOpt = new Option("s", "asm", true, "Compile the specified .iting file to .itingasm");
        Option outputOpt = new Option("o", "output", true, "Specify output file for --asm");

        options.addOption(versionOpt);
        options.addOption(helpOpt);
        options.addOption(runOpt);
        options.addOption(asmOpt);
        options.addOption(outputOpt);

        CommandLineParser parser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();

        try {
            CommandLine cmd = parser.parse(options, args);

            if (cmd.hasOption("v")) {
                System.out.println("Version: " + VERSION);
            } else if (cmd.hasOption("h")) {
                formatter.printHelp("Iting Interpreter", options);
            } else if (cmd.hasOption("r")) {
                String path = cmd.getOptionValue("r");
                runFile(path);
            } else if (cmd.hasOption("s")) {
                String path = cmd.getOptionValue("s");
                String outputPath = cmd.getOptionValue("o");
                compileFile(path, outputPath);
            } else {
                if (cmd.getArgs().length > 0) {
                    String path = cmd.getArgs()[0];
                    runFile(path);
                } else {
                    formatter.printHelp("Iting Interpreter", options);
                }
            }
        } catch (ParseException | IOException e) {
            System.err.println(e.getMessage());
            formatter.printHelp("Iting Interpreter", options);
        }
    }

    private static void runFile(String path) throws IOException {
        if (path.endsWith(".iting")) {
            ItingIR ir = new ItingIR();
            ItingVM vm = new ItingVM();
            String input = new String(Files.readAllBytes(Paths.get(path)));
            String asm = ir.generateIR(input);
            vm.run(asm);
        } else if (path.endsWith(".itingasm")) {
            ItingVM vm = new ItingVM();
            String asm = new String(Files.readAllBytes(Paths.get(path)));
            vm.run(asm);
        } else {
            System.err.println("Invalid file type. Please provide a .iting or .itingasm file.");
        }
    }

    private static void compileFile(String path, String outputPath) throws IOException {
        if (path.endsWith(".iting")) {
            ItingIR ir = new ItingIR();
            String input = new String(Files.readAllBytes(Paths.get(path)));
            String asm = ir.generateIR(input);
            if (outputPath == null) {
                outputPath = path.replace(".iting", ".itingasm");
            }
            Files.write(Paths.get(outputPath), asm.getBytes());
        } else {
            System.err.println("Invalid file type. Please provide a .iting file.");
        }
    }
}

