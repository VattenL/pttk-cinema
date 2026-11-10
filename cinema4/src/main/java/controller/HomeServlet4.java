package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Vào địa chỉ gốc: mở trang chủ (web.xml chặn mở thẳng JSP)
@WebServlet("")
public class HomeServlet4 extends HttpServlet {
    private static final String HOME = "/customer/home4.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher(HOME).forward(req, resp);
    }
}
