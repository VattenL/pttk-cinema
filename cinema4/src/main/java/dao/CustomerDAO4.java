package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;

import model.Customer4;
import model.MembershipCard4;

public class CustomerDAO4 extends DAO4 {

    public CustomerDAO4() {
        super();
    }

    public boolean checkDuplicateInfo(Customer4 customer) {
        boolean result = true;
        String sql = "SELECT COUNT(*) FROM tblMember4 WHERE username = ? OR phone = ? OR email = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, customer.getUsername());
            ps.setString(2, customer.getPhone());
            ps.setString(3, customer.getEmail());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result = rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = true;
        }
        return result;
    }

    // Một giao dịch: tblMember4 rồi tblCustomer4; mã khách KH + id 7 chữ số
    public boolean saveCustomer(Customer4 customer) {
        boolean result = false;
        String sqlMember = "INSERT INTO tblMember4 (username, password, fullName, dateOfBirth, gender, email, phone)"
                + " VALUES (?, SHA2(?, 256), ?, ?, ?, ?, ?)";
        String sqlCustomer = "INSERT INTO tblCustomer4 (memberId, customerCode, registerDate) VALUES (?, ?, ?)";
        synchronized (DAO4.class) {
            try {
                con.setAutoCommit(false);
                int id;
                try (PreparedStatement ps = con.prepareStatement(sqlMember, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, customer.getUsername());
                    ps.setString(2, customer.getPassword());
                    ps.setString(3, customer.getFullName());
                    ps.setDate(4, Date.valueOf(customer.getDateOfBirth()));
                    ps.setString(5, customer.getGender());
                    ps.setString(6, customer.getEmail());
                    ps.setString(7, customer.getPhone());
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        keys.next();
                        id = keys.getInt(1);
                    }
                }
                String customerCode = String.format("KH%07d", id);
                LocalDate registerDate = LocalDate.now();
                try (PreparedStatement psCustomer = con.prepareStatement(sqlCustomer)) {
                    psCustomer.setInt(1, id);
                    psCustomer.setString(2, customerCode);
                    psCustomer.setDate(3, Date.valueOf(registerDate));
                    psCustomer.executeUpdate();
                }
                con.commit();
                customer.setId(id);
                customer.setCustomerCode(customerCode);
                customer.setRegisterDate(registerDate);
                result = true;
            } catch (Exception e) {
                e.printStackTrace();
                try {
                    con.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                result = false;
            } finally {
                try {
                    con.setAutoCommit(true);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
        return result;
    }

    public Customer4 getCustomerOfCard(MembershipCard4 card) {
        Customer4 result = null;
        String sql = "SELECT m.*, c.customerCode, c.registerDate FROM tblMembershipCard4 mc"
                + " JOIN tblCustomer4 c ON c.memberId = mc.customerId"
                + " JOIN tblMember4 m ON m.id = c.memberId"
                + " WHERE mc.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, card.getId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result = new Customer4();
                    result.setId(rs.getInt("id"));
                    result.setUsername(rs.getString("username"));
                    result.setFullName(rs.getString("fullName"));
                    result.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                    result.setGender(rs.getString("gender"));
                    result.setEmail(rs.getString("email"));
                    result.setPhone(rs.getString("phone"));
                    result.setCustomerCode(rs.getString("customerCode"));
                    result.setRegisterDate(rs.getDate("registerDate").toLocalDate());
                    result.setMembershipCard(card);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
