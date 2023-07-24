import java.util.Scanner;
import java.sql.*;

public class Q3 {

    public static void main(String[] args) {

        String url = "jdbc:sqlserver://sqlserver.dmst.aueb.gr:1433;" +
                "databaseName=DB109;user=G5109;password=4f34cjio443;";

        Connection dbcon;
        Statement stmt;

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (java.lang.ClassNotFoundException e) {
            System.out.print("ClassNotFoundException: ");
            System.out.println(e.getMessage());
            return; // Exit the program if the driver class is not found
        }

        try {
            dbcon = DriverManager.getConnection(url);
            stmt = dbcon.createStatement();
            System.out.println("Enter a customer code to delete: ");
            Scanner sc = new Scanner(System.in);
            int code = sc.nextInt();

            // Check if the customer code exists in the database before attempting to delete
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM Customer WHERE custCode = " + code);
            if (rs.next()) {
                int rowCount = rs.getInt("count");
                if (rowCount == 0) {
                    System.out.println("Customer with code " + code + " does not exist.");
                    rs.close();
                    stmt.close();
                    dbcon.close();
                    return;
                }
            }
            rs.close();

            String sql = "DELETE FROM Customer WHERE custCode = " + code;
            stmt.executeUpdate(sql);
            System.out.println("The deletion of customer " + code + " was successful!");
            stmt.close();
            dbcon.close();
        } catch (SQLException e) {
            System.out.print("SQLException: ");
            System.out.println(e.getMessage());
        }
    }
}