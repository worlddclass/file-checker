import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class check {
    private static final String DEFAULT_FILE_NAME = "myFile.txt";
    private static final Pattern MAMA_PATTERN = Pattern.compile("\\bMama\\b", Pattern.CASE_INSENSITIVE);

    public static class FileMetrics {
        public final int lines;
        public final int words;
        public final int paragraphs;
        public final int mamaCount;

        public FileMetrics(int lines, int words, int paragraphs, int mamaCount) {
            this.lines = lines;
            this.words = words;
            this.paragraphs = paragraphs;
            this.mamaCount = mamaCount;
        }
    }

    public static void main(String[] args) {
        String fileName = (args != null && args.length > 0) ? args[0] : DEFAULT_FILE_NAME;
        File file = new File(fileName);

        if (!file.exists()) {
            System.err.println("Error: File '" + fileName + "' not found.");
            return;
        }

        if (file.isDirectory()) {
            System.err.println("Error: '" + fileName + "' is a directory, not a file.");
            return;
        }

        if (!file.canRead()) {
            System.err.println("Error: File '" + fileName + "' cannot be read.");
            return;
        }

        FileMetrics metrics;
        try {
            metrics = analyzeFile(file);
        } catch (IOException e) {
            System.err.println("Error reading file '" + fileName + "': " + e.getMessage());
            return;
        }

        try (Scanner scanner = new Scanner(System.in)) {
            runMenu(metrics, scanner);
        }
    }

    public static void printMenu() {
        System.out.println("=================================");
        System.out.println("       FILE METRICS MENU");
        System.out.println("=================================");
        System.out.println("A. show the amount of words in a file");
        System.out.println("B. show the amount of lines in a file");
        System.out.println("C. show the amount of paragraphs in a file");
        System.out.println("D. show the amount of times the word \"Mama\" appears in a file");
        System.out.println("Q. Quit");
        System.out.println("=================================");
        System.out.print("Enter your choice: ");
    }

    public static void runMenu(FileMetrics metrics, Scanner scanner) {
        boolean isPipe = (System.console() == null);
        while (true) {
            printMenu();
            if (!scanner.hasNextLine()) {
                if (isPipe) {
                    System.out.println();
                }
                break;
            }

            String rawLine = scanner.nextLine();
            String choice = rawLine.trim();
            if (isPipe) {
                System.out.println(rawLine);
            }

            if (choice.isEmpty()) {
                continue;
            }

            if (choice.equalsIgnoreCase("A")) {
                System.out.println("Words: " + metrics.words);
            } else if (choice.equalsIgnoreCase("B")) {
                System.out.println("Lines: " + metrics.lines);
            } else if (choice.equalsIgnoreCase("C")) {
                System.out.println("Paragraphs: " + metrics.paragraphs);
            } else if (choice.equalsIgnoreCase("D")) {
                System.out.println("Occurrences of \"Mama\": " + metrics.mamaCount);
            } else if (choice.equalsIgnoreCase("Q")) {
                System.out.println("Goodbye!");
                break;
            } else {
                System.out.println("Invalid selection. Please choose A, B, C, D, or Q.");
            }
            System.out.println();
        }
    }

    public static FileMetrics analyzeFile(File file) throws IOException {
        int linesRead = 0;
        int wordCount = 0;
        int paragraphCount = 0;
        int mamaCount = 0;
        boolean inParagraph = false;
        boolean isFirstLine = true;

        try (BufferedReader reader = new BufferedReader(new FileReader(file, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (isFirstLine) {
                    if (line.startsWith("\uFEFF")) {
                        line = line.substring(1);
                    }
                    isFirstLine = false;
                }
                linesRead++;
                Matcher mamaMatcher = MAMA_PATTERN.matcher(line);
                while (mamaMatcher.find()) {
                    mamaCount++;
                }

                String trimmed = line.trim();
                if (!trimmed.isEmpty()) {
                    String[] words = trimmed.split("\\s+");
                    wordCount += words.length;
                    if (!inParagraph) {
                        paragraphCount++;
                        inParagraph = true;
                    }
                } else {
                    inParagraph = false;
                }
            }
        }

        int lineCount;
        if (wordCount > 0) {
            lineCount = linesRead;
        } else {
            lineCount = countLineBreaks(file);
        }

        return new FileMetrics(lineCount, wordCount, paragraphCount, mamaCount);
    }

    private static int countLineBreaks(File file) throws IOException {
        int count = 0;
        try (BufferedReader reader = new BufferedReader(new FileReader(file, StandardCharsets.UTF_8))) {
            int ch;
            int prev = -1;
            while ((ch = reader.read()) != -1) {
                if (ch == '\n') {
                    count++;
                } else if (prev == '\r') {
                    count++;
                }
                prev = ch;
            }
            if (prev == '\r') {
                count++;
            }
        }
        return count;
    }
}
