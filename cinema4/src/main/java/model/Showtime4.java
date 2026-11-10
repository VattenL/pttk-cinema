package model;

import java.time.LocalDate;
import java.time.LocalTime;

public class Showtime4 {
    private int id;
    private String showtimeCode;
    private LocalDate showDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private String format;
    private String status;
    private Movie4 movie;
    private ScreeningRoom4 room;
    private ManagementStaff4 manager;

    public Showtime4() {
        super();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getShowtimeCode() {
        return showtimeCode;
    }

    public void setShowtimeCode(String showtimeCode) {
        this.showtimeCode = showtimeCode;
    }

    public LocalDate getShowDate() {
        return showDate;
    }

    public void setShowDate(LocalDate showDate) {
        this.showDate = showDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Movie4 getMovie() {
        return movie;
    }

    public void setMovie(Movie4 movie) {
        this.movie = movie;
    }

    public ScreeningRoom4 getRoom() {
        return room;
    }

    public void setRoom(ScreeningRoom4 room) {
        this.room = room;
    }

    public ManagementStaff4 getManager() {
        return manager;
    }

    public void setManager(ManagementStaff4 manager) {
        this.manager = manager;
    }
}
