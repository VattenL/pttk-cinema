package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.DayOfWeek;
import java.util.ArrayList;

import model.Showtime4;
import model.TicketPrice4;

public class TicketPriceDAO4 extends DAO4 {

    public TicketPriceDAO4() {
        super();
    }

    // Thứ Bảy, Chủ nhật là cuối tuần, các ngày còn lại là ngày thường
    public ArrayList<TicketPrice4> getPricesOfShowtime(Showtime4 showtime) {
        ArrayList<TicketPrice4> result = new ArrayList<>();
        DayOfWeek day = showtime.getShowDate().getDayOfWeek();
        String dayType = (day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY) ? "Cuối tuần" : "Ngày thường";
        String sql = "SELECT * FROM tblTicketPrice4"
                + " WHERE format = ? AND dayType = ? AND status = 'Áp dụng'"
                + " AND effectiveFrom <= ? AND (effectiveTo IS NULL OR effectiveTo >= ?)"
                + " ORDER BY amount";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, showtime.getFormat());
            ps.setString(2, dayType);
            ps.setDate(3, Date.valueOf(showtime.getShowDate()));
            ps.setDate(4, Date.valueOf(showtime.getShowDate()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TicketPrice4 price = new TicketPrice4();
                    price.setId(rs.getInt("id"));
                    price.setPriceCode(rs.getString("priceCode"));
                    price.setSeatType(rs.getString("seatType"));
                    price.setFormat(rs.getString("format"));
                    price.setDayType(rs.getString("dayType"));
                    price.setAmount(rs.getDouble("amount"));
                    price.setEffectiveFrom(rs.getDate("effectiveFrom").toLocalDate());
                    Date effectiveTo = rs.getDate("effectiveTo");
                    price.setEffectiveTo(effectiveTo == null ? null : effectiveTo.toLocalDate());
                    price.setStatus(rs.getString("status"));
                    result.add(price);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
