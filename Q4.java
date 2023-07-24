import java.util.Scanner;
import java.sql.*;
import java.sql.Date;

public class Q4 {

    public static void main(String[] args) {

        String url = "jdbc:sqlserver://sqlserver.dmst.aueb.gr:1433;" +
                "databaseName=DB109;user=G5109;password=4f34cjio443;";

        Connection dbcon;
        Statement stmt;
        ResultSet rs;
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
            System.out.println("Enter an order code: ");
            Scanner sc = new Scanner(System.in);
            int code = sc.nextInt();

            // Check if the order code exists in the database before attempting to fetch data
            rs = stmt.executeQuery("SELECT COUNT(*) AS count FROM Orders WHERE ordCode = " + code);
            if (rs.next()) {
                int rowCount = rs.getInt("count");
                if (rowCount == 0) {
                    System.out.println("Order with code " + code + " does not exist.");
                    rs.close();
                    stmt.close();
                    dbcon.close();
                    return;
                }
            }
            rs.close();

            rs = stmt.executeQuery("SELECT O.ordCode, O.orDate, O.delDate, O.custCode, I.prCode, I.orQuant, P.prName, P.price, sum(P.price*I.orQuant) as summary " +
                    "FROM Orders O " +
                    "INNER JOIN Includes I ON I.ordCode = O.ordCode " +
                    "INNER JOIN Product P ON P.prCode = I.prCode " +
                    "INNER JOIN Supplies S ON S.prCode = P.prCode " +
                    "INNER JOIN Supplier Su ON Su.sCode = S.sCode " +
                    "WHERE O.ordCode = " + code +
                    "GROUP BY O.ordCode, O.orDate, O.delDate, O.custCode, I.prCode, I.orQuant, P.prName, P.price");

            float total = 0;
            int oc = 0;
            while (rs.next()) {
                oc++; // To display some details only once for each order
                int ordCode = rs.getInt("ordCode");
                Date orDate = rs.getDate("orDate");
                Date delDate = rs.getDate("delDate");
                int custCode = rs.getInt("custCode");

                if (oc == 1) {
                    System.out.println("Order Code: " + ordCode);
                    System.out.println("Order Date: " + orDate);
                    System.out.println("Delivery Date: " + delDate);
                    System.out.println("Customer Code: " + custCode);
                }

                int prCode = rs.getInt("prCode");
                String prName = rs.getString("prName");
                int orQuant = rs.getInt("orQuant");
                float price = rs.getFloat("price");
                float prTotal = rs.getFloat("summary");

                System.out.println("Product Code: " + prCode + "   Product Name: " + prName +
                        "   Quantity: " + orQuant + "   Price: " + price);
                System.out.println("Product Total: " + prTotal);

                total = total + prTotal;
            }
            System.out.println("Total: " + total);
            rs.close();
            stmt.close();
            dbcon.close();
        } catch (SQLException e) {
            System.out.print("SQLException: ");
            System.out.println(e.getMessage());
        }
    }
}
