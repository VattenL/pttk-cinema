package model;

import java.time.LocalDate;
import java.time.LocalDateTime;

// price là giá chốt lúc bán, lấy từ dòng giá ticketPrice
public class Ticket4 {
    private int id;
    private String ticketCode;
    private double price;
    private LocalDateTime issuedAt;
    private String status;
    private Showtime4 showtime;
    private Seat4 seat;
    private TicketPrice4 ticketPrice;

    public Ticket4() {
        super();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTicketCode() {
        return ticketCode;
    }

    public void setTicketCode(String ticketCode) {
        this.ticketCode = ticketCode;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public LocalDateTime getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(LocalDateTime issuedAt) {
        this.issuedAt = issuedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Showtime4 getShowtime() {
        return showtime;
    }

    public void setShowtime(Showtime4 showtime) {
        this.showtime = showtime;
    }

    public Seat4 getSeat() {
        return seat;
    }

    public void setSeat(Seat4 seat) {
        this.seat = seat;
    }

    public TicketPrice4 getTicketPrice() {
        return ticketPrice;
    }

    public void setTicketPrice(TicketPrice4 ticketPrice) {
        this.ticketPrice = ticketPrice;
    }
}
