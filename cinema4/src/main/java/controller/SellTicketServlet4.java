package controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.CustomerDAO4;
import dao.InvoiceDAO4;
import dao.MembershipCardDAO4;
import dao.MovieDAO4;
import dao.SeatDAO4;
import dao.ShowtimeDAO4;
import dao.TicketDAO4;
import dao.TicketPriceDAO4;
import model.Customer4;
import model.Invoice4;
import model.MembershipCard4;
import model.Movie4;
import model.Saler4;
import model.Seat4;
import model.Showtime4;
import model.Ticket4;
import model.TicketPrice4;

// Dữ liệu giữa các bước giữ trong HttpSession; hoá đơn chỉ vào CSDL khi đã trả tiền
@WebServlet("/sellTicket")
public class SellTicketServlet4 extends HttpServlet {
    private static final String VIEW = "/saler/";

    // GET chỉ đọc: mở tìm phim, tìm, chọn phim, chọn suất
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (req.getSession().getAttribute("saler") == null) {
            resp.sendRedirect("login");
            return;
        }
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        try {
            switch (action) {
                case "searchMovie":
                    searchMovie(req, resp);
                    break;
                case "selectMovie":
                    selectMovie(req, resp);
                    break;
                case "selectShowtime":
                    selectShowtime(req, resp);
                    break;
                default:
                    openSearchMovie(req, resp);
            }
        } catch (RuntimeException e) {
            // Tham số sai hoặc phiên đã hết (Back sau khi kết thúc): bắt đầu lại từ tìm phim
            e.printStackTrace();
            openSearchMovie(req, resp);
        }
    }

    // POST thay đổi dữ liệu: chọn, xoá ghế, xác nhận mua, thanh toán, chuyển khoản, kết thúc
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (req.getSession().getAttribute("saler") == null) {
            resp.sendRedirect("login");
            return;
        }
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        try {
            switch (action) {
                case "selectSeat":
                    selectSeat(req, resp);
                    break;
                case "confirmPurchase":
                    confirmPurchase(req, resp);
                    break;
                case "pay":
                    pay(req, resp);
                    break;
                case "confirmTransfer":
                    confirmTransfer(req, resp);
                    break;
                case "cancelTransfer":
                    cancelTransfer(req, resp);
                    break;
                case "removeDraftTicket":
                    removeDraftTicket(req, resp);
                    break;
                case "finish":
                    finish(req, resp);
                    break;
                default:
                    openSearchMovie(req, resp);
            }
        } catch (RuntimeException e) {
            e.printStackTrace();
            openSearchMovie(req, resp);
        }
    }

    private void openSearchMovie(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        session.removeAttribute("listMovie");
        session.setAttribute("txtTitle", "");
        session.setAttribute("txtShowDate", LocalDate.now().toString());
        req.getRequestDispatcher(VIEW + "searchMovie4.jsp").forward(req, resp);
    }

    private void searchMovie(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String title = req.getParameter("txtTitle") == null ? "" : req.getParameter("txtTitle").trim();
        String showDate = req.getParameter("txtShowDate") == null || req.getParameter("txtShowDate").isEmpty()
                ? LocalDate.now().toString() : LocalDate.parse(req.getParameter("txtShowDate")).toString();
        MovieDAO4 movieDAO = new MovieDAO4();
        ArrayList<Movie4> listMovie = movieDAO.searchShowingMovies(title, LocalDate.parse(showDate));
        session.setAttribute("listMovie", listMovie);
        session.setAttribute("txtTitle", title);
        session.setAttribute("txtShowDate", showDate);
        req.getRequestDispatcher(VIEW + "searchMovie4.jsp").forward(req, resp);
    }

    @SuppressWarnings("unchecked")
    private void selectMovie(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int movieId = Integer.parseInt(req.getParameter("movieId"));
        Movie4 movie = ((ArrayList<Movie4>) session.getAttribute("listMovie")).stream()
                .filter(m -> m.getId() == movieId).findFirst().orElseThrow(IllegalStateException::new);
        LocalDate showDate = LocalDate.parse((String) session.getAttribute("txtShowDate"));
        ShowtimeDAO4 showtimeDAO = new ShowtimeDAO4();
        ArrayList<Showtime4> listShowtime = showtimeDAO.getShowtimesOfMovie(movie, showDate);
        TicketDAO4 ticketDAO = new TicketDAO4();
        HashMap<Integer, Integer> mapSoldCount = ticketDAO.countSoldTickets(listShowtime);
        session.setAttribute("movie", movie);
        session.setAttribute("listShowtime", listShowtime);
        session.setAttribute("mapSoldCount", mapSoldCount);
        req.getRequestDispatcher(VIEW + "showtimeList4.jsp").forward(req, resp);
    }

    // Bảng vé tạm làm mới khi đổi suất, giữ nguyên khi quay lại từ trang thanh toán
    @SuppressWarnings("unchecked")
    private void selectShowtime(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int showtimeId = Integer.parseInt(req.getParameter("showtimeId"));
        Showtime4 showtime = ((ArrayList<Showtime4>) session.getAttribute("listShowtime")).stream()
                .filter(s -> s.getId() == showtimeId).findFirst().orElseThrow(IllegalStateException::new);
        TicketDAO4 ticketDAO = new TicketDAO4();
        ArrayList<Ticket4> listSoldTicket = ticketDAO.getSoldSeats(showtime);
        boolean started = LocalDateTime.of(showtime.getShowDate(), showtime.getStartTime()).isBefore(LocalDateTime.now());
        if (started || listSoldTicket.size() >= showtime.getRoom().getCapacity()) {
            ((HashMap<Integer, Integer>) session.getAttribute("mapSoldCount")).put(showtime.getId(), listSoldTicket.size());
            req.setAttribute("lblMessage", "Suất " + showtime.getShowtimeCode()
                    + (started ? " đã bắt đầu chiếu" : " vừa bán hết ghế") + ", vui lòng chọn suất khác.");
            req.getRequestDispatcher(VIEW + "showtimeList4.jsp").forward(req, resp);
            return;
        }
        SeatDAO4 seatDAO = new SeatDAO4();
        ArrayList<Seat4> listSeat = seatDAO.getSeatsOfRoom(showtime.getRoom());
        TicketPriceDAO4 ticketPriceDAO = new TicketPriceDAO4();
        ArrayList<TicketPrice4> listPrice = ticketPriceDAO.getPricesOfShowtime(showtime);
        Showtime4 oldShowtime = (Showtime4) session.getAttribute("showtime");
        if (oldShowtime == null || oldShowtime.getId() != showtime.getId()
                || session.getAttribute("listDraftTicket") == null) {
            session.setAttribute("listDraftTicket", new ArrayList<Ticket4>());
            session.removeAttribute("txtCardCode");
        }
        session.setAttribute("showtime", showtime);
        session.setAttribute("listSoldTicket", listSoldTicket);
        session.setAttribute("listSeat", listSeat);
        session.setAttribute("listPrice", listPrice);
        req.getRequestDispatcher(VIEW + "seatMap4.jsp").forward(req, resp);
    }

    @SuppressWarnings("unchecked")
    private void selectSeat(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int seatId = Integer.parseInt(req.getParameter("btnSeat"));
        Showtime4 showtime = (Showtime4) session.getAttribute("showtime");
        ArrayList<Ticket4> listDraftTicket = (ArrayList<Ticket4>) session.getAttribute("listDraftTicket");
        Seat4 seat = ((ArrayList<Seat4>) session.getAttribute("listSeat")).stream()
                .filter(s -> s.getId() == seatId).findFirst().orElseThrow(IllegalStateException::new);
        boolean picked = listDraftTicket.stream().anyMatch(t -> t.getSeat().getId() == seatId);
        TicketDAO4 ticketDAO = new TicketDAO4();
        if (picked) {
            req.setAttribute("lblMessage", "Ghế " + seat.getSeatCode() + " đã có trong bảng vé đang chọn.");
        } else if (!ticketDAO.checkSeatAvailable(showtime, seat)) {
            req.setAttribute("lblMessage", "Ghế " + seat.getSeatCode() + " vừa được bán hoặc không dùng được, vui lòng chọn ghế khác.");
        } else {
            Ticket4 ticket = ticketDAO.calculatePrice(seat, (ArrayList<TicketPrice4>) session.getAttribute("listPrice"));
            if (ticket == null) {
                req.setAttribute("lblMessage", "Loại ghế " + seat.getSeatType() + " chưa có giá cho suất này.");
            } else {
                ticket.setShowtime(showtime);
                listDraftTicket.add(ticket);
            }
        }
        req.getRequestDispatcher(VIEW + "seatMap4.jsp").forward(req, resp);
    }

    @SuppressWarnings("unchecked")
    private void removeDraftTicket(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int seatId = Integer.parseInt(req.getParameter("seatId"));
        ArrayList<Ticket4> listDraftTicket = (ArrayList<Ticket4>) session.getAttribute("listDraftTicket");
        listDraftTicket.removeIf(t -> t.getSeat().getId() == seatId);
        req.getRequestDispatcher(VIEW + "seatMap4.jsp").forward(req, resp);
    }

    // Chưa chọn ghế hoặc thẻ sai: ở lại trang chọn ghế, giữ vé tạm và mã thẻ
    @SuppressWarnings("unchecked")
    private void confirmPurchase(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        ArrayList<Ticket4> listDraftTicket = (ArrayList<Ticket4>) session.getAttribute("listDraftTicket");
        String cardCode = req.getParameter("txtCardCode") == null ? "" : req.getParameter("txtCardCode").trim();
        session.setAttribute("txtCardCode", cardCode);
        if (listDraftTicket == null || listDraftTicket.isEmpty()) {
            req.setAttribute("lblMessage", "Chưa chọn ghế nào.");
            req.getRequestDispatcher(VIEW + "seatMap4.jsp").forward(req, resp);
            return;
        }
        Invoice4 invoice = new Invoice4();
        invoice.setListTicket(new ArrayList<>(listDraftTicket));
        invoice.setSaler((Saler4) session.getAttribute("saler"));
        MembershipCard4 card = null;
        if (!cardCode.isEmpty()) {
            MembershipCardDAO4 membershipCardDAO = new MembershipCardDAO4();
            card = membershipCardDAO.getCardByCode(cardCode);
            if (card == null) {
                req.setAttribute("lblMessage", "Thẻ không tồn tại, bị khoá hoặc hết hạn.");
                req.getRequestDispatcher(VIEW + "seatMap4.jsp").forward(req, resp);
                return;
            }
            CustomerDAO4 customerDAO = new CustomerDAO4();
            Customer4 customer = customerDAO.getCustomerOfCard(card);
            invoice.setCustomer(customer);
        }
        InvoiceDAO4 invoiceDAO = new InvoiceDAO4();
        invoice = invoiceDAO.calculateDiscount(invoice, card);
        session.setAttribute("invoice", invoice);
        if (card == null) {
            session.removeAttribute("card");
        } else {
            session.setAttribute("card", card);
        }
        req.getRequestDispatcher(VIEW + "payment4.jsp").forward(req, resp);
    }

    // Tiền mặt lưu ngay; chuyển khoản chỉ tạo QR, lưu khi tiền về; hoá đơn đã lưu thì không lưu lại
    private void pay(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Invoice4 invoice = (Invoice4) session.getAttribute("invoice");
        if (invoice.getId() > 0) {
            req.getRequestDispatcher(VIEW + "printTicket4.jsp").forward(req, resp);
            return;
        }
        String paymentMethod = req.getParameter("rdoPaymentMethod");
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            req.setAttribute("lblMessage", "Chọn hình thức thanh toán.");
            req.getRequestDispatcher(VIEW + "payment4.jsp").forward(req, resp);
            return;
        }
        invoice.setPaymentMethod(paymentMethod);
        InvoiceDAO4 invoiceDAO = new InvoiceDAO4();
        if ("Chuyển khoản".equals(paymentMethod)) {
            String imgQrCode = invoiceDAO.createTransferQr(invoice);
            session.setAttribute("imgQrCode", imgQrCode);
            req.getRequestDispatcher(VIEW + "transfer4.jsp").forward(req, resp);
            return;
        }
        Invoice4 savedInvoice = invoiceDAO.saveInvoice(invoice);
        if (savedInvoice == null) {
            req.setAttribute("lblMessage", "Có ghế vừa được bán ở quầy khác, vui lòng chọn lại ghế.");
            req.getRequestDispatcher(VIEW + "payment4.jsp").forward(req, resp);
            return;
        }
        session.setAttribute("invoice", savedInvoice);
        session.removeAttribute("listDraftTicket");
        MembershipCard4 card = (MembershipCard4) session.getAttribute("card");
        if (card != null) {
            MembershipCardDAO4 membershipCardDAO = new MembershipCardDAO4();
            membershipCardDAO.addLoyaltyPoint(card, savedInvoice.getEarnedPoint());
        }
        req.setAttribute("lblMessage", "Thanh toán thành công.");
        req.getRequestDispatcher(VIEW + "printTicket4.jsp").forward(req, resp);
    }

    // Trang chuyển khoản tự gửi sau vài giây (giả lập ngân hàng báo có); ghế vừa bị bán thì không lưu
    private void confirmTransfer(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Invoice4 invoice = (Invoice4) session.getAttribute("invoice");
        if (invoice.getId() > 0) {
            req.getRequestDispatcher(VIEW + "printTicket4.jsp").forward(req, resp);
            return;
        }
        session.removeAttribute("imgQrCode");
        InvoiceDAO4 invoiceDAO = new InvoiceDAO4();
        Invoice4 savedInvoice = invoiceDAO.saveInvoice(invoice);
        if (savedInvoice == null) {
            req.setAttribute("lblMessage", "Có ghế vừa được bán ở quầy khác trong lúc chờ chuyển khoản,"
                    + " hoàn tiền cho khách và chọn lại ghế.");
            req.getRequestDispatcher(VIEW + "payment4.jsp").forward(req, resp);
            return;
        }
        session.setAttribute("invoice", savedInvoice);
        session.removeAttribute("listDraftTicket");
        MembershipCard4 card = (MembershipCard4) session.getAttribute("card");
        if (card != null) {
            MembershipCardDAO4 membershipCardDAO = new MembershipCardDAO4();
            membershipCardDAO.addLoyaltyPoint(card, savedInvoice.getEarnedPoint());
        }
        req.setAttribute("lblMessage", "Đã nhận chuyển khoản, thanh toán thành công.");
        req.getRequestDispatcher(VIEW + "printTicket4.jsp").forward(req, resp);
    }

    // Chưa có gì trong CSDL nên không gọi DAO
    private void cancelTransfer(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Invoice4 invoice = (Invoice4) session.getAttribute("invoice");
        if (invoice.getId() > 0) {
            req.getRequestDispatcher(VIEW + "printTicket4.jsp").forward(req, resp);
            return;
        }
        invoice.setPaymentMethod(null);
        session.removeAttribute("imgQrCode");
        req.setAttribute("lblMessage", "Đã huỷ giao dịch chuyển khoản.");
        req.getRequestDispatcher(VIEW + "payment4.jsp").forward(req, resp);
    }

    // Kết thúc, hoặc Quay lại từ trang tìm phim: xoá dữ liệu bán vé khỏi phiên
    private void finish(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String[] names = {"listMovie", "txtTitle", "txtShowDate", "movie", "listShowtime", "mapSoldCount",
            "showtime", "listSoldTicket", "listSeat", "listPrice", "listDraftTicket", "txtCardCode", "invoice",
            "card", "imgQrCode"};
        for (String name : names) {
            session.removeAttribute(name);
        }
        req.getRequestDispatcher(VIEW + "salerHome4.jsp").forward(req, resp);
    }
}
