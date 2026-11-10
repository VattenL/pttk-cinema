package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import model.ScreeningRoom4;
import model.Seat4;

public class SeatDAO4 extends DAO4 {

    public SeatDAO4() {
        super();
    }

    public ArrayList<Seat4> getSeatsOfRoom(ScreeningRoom4 room) {
        ArrayList<Seat4> result = new ArrayList<>();
        String sql = "SELECT * FROM tblSeat4 WHERE screeningRoomId = ? ORDER BY rowLabel, seatNumber";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, room.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Seat4 seat = new Seat4();
                    seat.setId(rs.getInt("id"));
                    seat.setRowLabel(rs.getString("rowLabel"));
                    seat.setSeatNumber(rs.getInt("seatNumber"));
                    seat.setSeatCode(String.format("%s%02d", seat.getRowLabel(), seat.getSeatNumber()));
                    seat.setSeatType(rs.getString("seatType"));
                    seat.setStatus(rs.getString("status"));
                    result.add(seat);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
