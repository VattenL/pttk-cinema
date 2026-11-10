package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;

import model.Movie4;

public class MovieDAO4 extends DAO4 {

    public MovieDAO4() {
        super();
    }

    // Phim trong thời gian chiếu và có suất vào ngày đó; suất chiếu chỉ dùng để lọc
    public ArrayList<Movie4> searchShowingMovies(String title, LocalDate showDate) {
        ArrayList<Movie4> result = new ArrayList<>();
        String sql = "SELECT * FROM tblMovie4 m"
                + " WHERE m.releaseDate <= ? AND m.endDate >= ? AND m.title LIKE ?"
                + " AND EXISTS (SELECT 1 FROM tblShowtime4 st WHERE st.movieId = m.id AND st.showDate = ?)"
                + " ORDER BY m.movieCode";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            java.sql.Date day = java.sql.Date.valueOf(showDate);
            ps.setDate(1, day);
            ps.setDate(2, day);
            ps.setString(3, "%" + (title == null ? "" : title.trim()) + "%");
            ps.setDate(4, day);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Movie4 movie = new Movie4();
                    movie.setId(rs.getInt("id"));
                    movie.setMovieCode(rs.getString("movieCode"));
                    movie.setTitle(rs.getString("title"));
                    movie.setDuration(rs.getInt("duration"));
                    movie.setDirector(rs.getString("director"));
                    movie.setMainActor(rs.getString("mainActor"));
                    movie.setLanguage(rs.getString("language"));
                    movie.setAgeRating(rs.getString("ageRating"));
                    movie.setReleaseDate(rs.getDate("releaseDate").toLocalDate());
                    movie.setEndDate(rs.getDate("endDate").toLocalDate());
                    movie.setDescription(rs.getString("description"));
                    movie.setPoster(rs.getString("poster"));
                    result.add(movie);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
