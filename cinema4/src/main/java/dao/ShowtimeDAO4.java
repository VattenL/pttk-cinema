package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;

import model.Movie4;
import model.ScreeningRoom4;
import model.Showtime4;

public class ShowtimeDAO4 extends DAO4 {

    public ShowtimeDAO4() {
        super();
    }

    // Sức chứa phòng là số ghế, không có cột trong CSDL
    public ArrayList<Showtime4> getShowtimesOfMovie(Movie4 movie, LocalDate showDate) {
        ArrayList<Showtime4> result = new ArrayList<>();
        String sql = "SELECT st.*, r.roomCode, r.name AS roomName, r.roomType,"
                + " (SELECT COUNT(*) FROM tblSeat4 s WHERE s.screeningRoomId = r.id) AS capacity"
                + " FROM tblShowtime4 st JOIN tblScreeningRoom4 r ON r.id = st.screeningRoomId"
                + " WHERE st.movieId = ? AND st.showDate = ? AND st.status <> 'Đã huỷ'"
                + " ORDER BY st.startTime";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movie.getId());
            ps.setDate(2, Date.valueOf(showDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Showtime4 showtime = new Showtime4();
                    showtime.setId(rs.getInt("id"));
                    showtime.setShowtimeCode(rs.getString("showtimeCode"));
                    showtime.setShowDate(rs.getDate("showDate").toLocalDate());
                    showtime.setStartTime(rs.getTime("startTime").toLocalTime());
                    showtime.setEndTime(rs.getTime("endTime").toLocalTime());
                    showtime.setFormat(rs.getString("format"));
                    showtime.setStatus(rs.getString("status"));
                    showtime.setMovie(movie);
                    ScreeningRoom4 room = new ScreeningRoom4();
                    room.setId(rs.getInt("screeningRoomId"));
                    room.setRoomCode(rs.getString("roomCode"));
                    room.setName(rs.getString("roomName"));
                    room.setRoomType(rs.getString("roomType"));
                    room.setCapacity(rs.getInt("capacity"));
                    showtime.setRoom(room);
                    result.add(showtime);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
