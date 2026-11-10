package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.MemberDAO4;
import model.Member4;
import model.Saler4;

@WebServlet("/login")
public class LoginServlet4 extends HttpServlet {
    private static final String LOGIN = "/member/login4.jsp";
    private static final String SALER_HOME = "/saler/salerHome4.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher(LOGIN).forward(req, resp);
    }

    // action=logout: huỷ phiên; khách về trang chủ, nhân viên về trang đăng nhập
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if ("logout".equals(req.getParameter("action"))) {
            HttpSession session = req.getSession();
            boolean customer = session.getAttribute("member") != null;
            session.invalidate();
            if (customer) {
                resp.sendRedirect(req.getContextPath() + "/");
            } else {
                req.getRequestDispatcher(LOGIN).forward(req, resp);
            }
            return;
        }
        Member4 member = new Member4() {
        };
        member.setUsername(req.getParameter("txtUsername"));
        member.setPassword(req.getParameter("txtPassword"));
        MemberDAO4 memberDAO = new MemberDAO4();
        Member4 result = memberDAO.checkLogin(member);
        if (result instanceof Saler4) {
            req.getSession().setAttribute("saler", result);
            req.getRequestDispatcher(SALER_HOME).forward(req, resp);
        } else {
            req.setAttribute("lblError", result == null
                    ? "Sai tên đăng nhập hoặc mật khẩu."
                    : "Tài khoản không phải nhân viên bán vé.");
            req.getRequestDispatcher(LOGIN).forward(req, resp);
        }
    }
}
