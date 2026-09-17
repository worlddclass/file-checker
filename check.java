import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

public class check {
    private static final String DEFAULT_FILE_NAME = "myFile.txt";

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

        int linesRead = 0;
        int wordCount = 0;
        int paragraphCount = 0;
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
        } catch (IOException e) {
            System.err.println("Error reading file '" + fileName + "': " + e.getMessage());
            return;
        }

        int lineCount;
        if (wordCount > 0) {
            lineCount = linesRead;
        } else {
            try {
                lineCount = countLineBreaks(file);
            } catch (IOException e) {
                System.err.println("Error analyzing line count: " + e.getMessage());
                return;
            }
        }

        System.out.println("Analyzing file: " + fileName);
        System.out.println("---------------------------------");
        System.out.printf("%-13s%d%n", "Lines:", lineCount);
        System.out.printf("%-13s%d%n", "Words:", wordCount);
        System.out.printf("%-13s%d%n", "Paragraphs:", paragraphCount);
        System.out.println("---------------------------------");
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
