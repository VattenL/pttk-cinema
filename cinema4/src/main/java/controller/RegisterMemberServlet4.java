package controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.function.Function;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.CustomerDAO4;
import model.Customer4;

@WebServlet("/registerMember")
public class RegisterMemberServlet4 extends HttpServlet {
    private static final String HOME = "/customer/home4.jsp";
    private static final String FORM = "/customer/registerMember4.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher(FORM).forward(req, resp);
    }

    // Thành công: khách ở trạng thái đã đăng nhập; lỗi thì hiện lại form, giữ dữ liệu đã nhập
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Customer4 customer = readCustomer(req);
        String message = validate(customer, req.getParameter("txtConfirmPassword"));
        if (message.isEmpty()) {
            CustomerDAO4 customerDAO = new CustomerDAO4();
            if (customerDAO.checkDuplicateInfo(customer)) {
                message = "Tên đăng nhập, số điện thoại hoặc email đã được sử dụng.";
            } else if (customerDAO.saveCustomer(customer)) {
                customer.setPassword(null);
                req.getSession().setAttribute("member", customer);
                req.setAttribute("lblMessage", "Đăng ký hội viên thành công.");
                req.getRequestDispatcher(HOME).forward(req, resp);
                return;
            } else {
                message = "Hệ thống chưa lưu được, vui lòng thử lại.";
            }
        }
        customer.setPassword(null);
        req.setAttribute("customer", customer);
        req.setAttribute("lblMessage", message);
        req.getRequestDispatcher(FORM).forward(req, resp);
    }

    // Ngày sinh sai định dạng coi như bỏ trống
    private Customer4 readCustomer(HttpServletRequest req) {
        Function<String, String> param = name -> {
            String value = req.getParameter(name);
            return value == null ? "" : value.trim();
        };
        Customer4 customer = new Customer4();
        customer.setFullName(param.apply("txtFullName"));
        try {
            customer.setDateOfBirth(LocalDate.parse(param.apply("txtDateOfBirth")));
        } catch (DateTimeParseException e) {
            customer.setDateOfBirth(null);
        }
        customer.setGender(param.apply("rdoGender"));
        customer.setPhone(param.apply("txtPhone"));
        customer.setEmail(param.apply("txtEmail"));
        customer.setUsername(param.apply("txtUsername"));
        customer.setPassword(req.getParameter("txtPassword") == null ? "" : req.getParameter("txtPassword"));
        return customer;
    }

    // Trả câu báo lỗi, hoặc chuỗi rỗng nếu hợp lệ
    private String validate(Customer4 customer, String confirmPassword) {
        if (customer.getFullName().isEmpty() || customer.getDateOfBirth() == null
                || customer.getGender().isEmpty() || customer.getPhone().isEmpty()
                || customer.getEmail().isEmpty() || customer.getUsername().isEmpty()
                || customer.getPassword().isEmpty()) {
            return "Vui lòng nhập đủ các trường bắt buộc (*).";
        }
        if (!customer.getPhone().matches("0[0-9]{9}")) {
            return "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0.";
        }
        if (!customer.getEmail().matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+")) {
            return "Email không đúng định dạng.";
        }
        if (!customer.getDateOfBirth().isBefore(LocalDate.now())) {
            return "Ngày sinh không hợp lệ.";
        }
        if (customer.getPassword().length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự.";
        }
        if (!customer.getPassword().equals(confirmPassword)) {
            return "Hai lần nhập mật khẩu không khớp.";
        }
        return "";
    }
}
