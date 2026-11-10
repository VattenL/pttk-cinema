package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;

import model.Seat4;
import model.Showtime4;
import model.Ticket4;
import model.TicketPrice4;

// Vé chiếm ghế khi đã bán hoặc đã sử dụng; vé đã huỷ trả ghế
public class TicketDAO4 extends DAO4 {
    private static final String OCCUPYING = "t.status IN ('Đã bán', 'Đã sử dụng')";

    public TicketDAO4() {
        super();
    }

    public HashMap<Integer, Integer> countSoldTickets(ArrayList<Showtime4> listShowtime) {
        HashMap<Integer, Integer> result = new HashMap<>();
        if (listShowtime == null || listShowtime.isEmpty()) {
            return result;
        }
        StringBuilder ids = new StringBuilder();
        for (Showtime4 showtime : listShowtime) {
            ids.append(ids.length() == 0 ? "?" : ", ?");
            result.put(showtime.getId(), 0);
        }
        String sql = "SELECT t.showtimeId, COUNT(*) AS sold FROM tblTicket4 t"
                + " WHERE " + OCCUPYING + " AND t.showtimeId IN (" + ids + ") GROUP BY t.showtimeId";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < listShowtime.size(); i++) {
                ps.setInt(i + 1, listShowtime.get(i).getId());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("showtimeId"), rs.getInt("sold"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }

    public ArrayList<Ticket4> getSoldSeats(Showtime4 showtime) {
        ArrayList<Ticket4> result = new ArrayList<>();
        String sql = "SELECT t.id, t.ticketCode, t.status, s.id AS seatId, s.rowLabel, s.seatNumber, s.seatType"
                + " FROM tblTicket4 t JOIN tblSeat4 s ON s.id = t.seatId"
                + " WHERE t.showtimeId = ? AND " + OCCUPYING;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, showtime.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ticket4 ticket = new Ticket4();
                    ticket.setId(rs.getInt("id"));
                    ticket.setTicketCode(rs.getString("ticketCode"));
                    ticket.setStatus(rs.getString("status"));
                    ticket.setShowtime(showtime);
                    Seat4 seat = new Seat4();
                    seat.setId(rs.getInt("seatId"));
                    seat.setRowLabel(rs.getString("rowLabel"));
                    seat.setSeatNumber(rs.getInt("seatNumber"));
                    seat.setSeatCode(String.format("%s%02d", seat.getRowLabel(), seat.getSeatNumber()));
                    seat.setSeatType(rs.getString("seatType"));
                    ticket.setSeat(seat);
                    result.add(ticket);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }

    public boolean checkSeatAvailable(Showtime4 showtime, Seat4 seat) {
        boolean result = false;
        String sql = "SELECT (SELECT status FROM tblSeat4 WHERE id = ?) AS seatStatus,"
                + " (SELECT COUNT(*) FROM tblTicket4 t"
                + " WHERE t.showtimeId = ? AND t.seatId = ? AND " + OCCUPYING + ") AS taken";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, seat.getId());
            ps.setInt(2, showtime.getId());
            ps.setInt(3, seat.getId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result = "Còn dùng được".equals(rs.getString("seatStatus")) && rs.getInt("taken") == 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = false;
        }
        return result;
    }

    // Không truy cập CSDL: các dòng giá đã lấy sẵn khi mở sơ đồ ghế
    public Ticket4 calculatePrice(Seat4 seat, ArrayList<TicketPrice4> listPrice) {
        Ticket4 result = null;
        for (TicketPrice4 price : listPrice) {
            if (price.getSeatType().equals(seat.getSeatType())) {
                result = new Ticket4();
                result.setSeat(seat);
                result.setTicketPrice(price);
                result.setPrice(price.getAmount());
                break;
            }
        }
        return result;
    }
}
