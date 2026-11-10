package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;

// totalAmount, finalAmount, earnedPoint, channel là thuộc tính dẫn xuất, không có cột trong CSDL
public class Invoice4 {
    private int id;
    private String invoiceCode;
    private LocalDateTime createdDate;
    private String channel;
    private double totalAmount;
    private double discount;
    private double finalAmount;
    private String paymentMethod;
    private String status;
    private int earnedPoint;
    private ArrayList<Ticket4> listTicket;
    private Saler4 saler;
    private Customer4 customer;

    public Invoice4() {
        super();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getInvoiceCode() {
        return invoiceCode;
    }

    public void setInvoiceCode(String invoiceCode) {
        this.invoiceCode = invoiceCode;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public double getDiscount() {
        return discount;
    }

    public void setDiscount(double discount) {
        this.discount = discount;
    }

    public double getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(double finalAmount) {
        this.finalAmount = finalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getEarnedPoint() {
        return earnedPoint;
    }

    public void setEarnedPoint(int earnedPoint) {
        this.earnedPoint = earnedPoint;
    }

    public ArrayList<Ticket4> getListTicket() {
        return listTicket;
    }

    public void setListTicket(ArrayList<Ticket4> listTicket) {
        this.listTicket = listTicket;
    }

    public Saler4 getSaler() {
        return saler;
    }

    public void setSaler(Saler4 saler) {
        this.saler = saler;
    }

    public Customer4 getCustomer() {
        return customer;
    }

    public void setCustomer(Customer4 customer) {
        this.customer = customer;
    }
}
