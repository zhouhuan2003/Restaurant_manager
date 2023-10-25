import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class test {
    public static void main(String[] args) {
        LocalDateTime startTime = LocalDate.parse("2023-04-17", DateTimeFormatter.ofPattern("yyyy-MM-dd")).atStartOfDay();
        System.out.println(startTime);
    }
}
