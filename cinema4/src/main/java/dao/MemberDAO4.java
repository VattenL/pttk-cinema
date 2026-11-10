package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import model.Customer4;
import model.Employee4;
import model.ManagementStaff4;
import model.Member4;
import model.Saler4;

public class MemberDAO4 extends DAO4 {

    public MemberDAO4() {
        super();
    }

    // Đối tượng trả về thuộc lớp con theo bảng vai trò: Saler4, ManagementStaff4 hoặc Customer4
    public Member4 checkLogin(Member4 member) {
        Member4 result = null;
        String sql = "SELECT m.*, s.counter, e.employeeCode, e.hireDate,"
                + " ms.memberId AS managerId, c.customerCode, c.registerDate"
                + " FROM tblMember4 m"
                + " LEFT JOIN tblEmployee4 e ON e.memberId = m.id"
                + " LEFT JOIN tblSaler4 s ON s.memberId = m.id"
                + " LEFT JOIN tblManagementStaff4 ms ON ms.memberId = m.id"
                + " LEFT JOIN tblCustomer4 c ON c.memberId = m.id"
                + " WHERE m.username = ? AND m.password = SHA2(?, 256)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, member.getUsername());
            ps.setString(2, member.getPassword());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    if (rs.getString("counter") != null) {
                        Saler4 saler = new Saler4();
                        saler.setCounter(rs.getString("counter"));
                        result = saler;
                    } else if (rs.getObject("managerId") != null) {
                        result = new ManagementStaff4();
                    } else if (rs.getString("customerCode") != null) {
                        Customer4 customer = new Customer4();
                        customer.setCustomerCode(rs.getString("customerCode"));
                        customer.setRegisterDate(rs.getDate("registerDate").toLocalDate());
                        result = customer;
                    }
                    if (result instanceof Employee4) {
                        Employee4 employee = (Employee4) result;
                        employee.setEmployeeCode(rs.getString("employeeCode"));
                        employee.setHireDate(rs.getDate("hireDate").toLocalDate());
                        employee.setPosition(result instanceof Saler4 ? "Nhân viên bán vé" : "Nhân viên quản lý");
                    }
                    if (result != null) {
                        result.setId(rs.getInt("id"));
                        result.setUsername(rs.getString("username"));
                        result.setFullName(rs.getString("fullName"));
                        result.setDateOfBirth(rs.getDate("dateOfBirth").toLocalDate());
                        result.setGender(rs.getString("gender"));
                        result.setEmail(rs.getString("email"));
                        result.setPhone(rs.getString("phone"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
