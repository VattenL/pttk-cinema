package model;

import java.time.LocalDate;

// loyaltyPoint là thuộc tính dẫn xuất, không có cột trong CSDL
public class MembershipCard4 {
    private int id;
    private String cardCode;
    private LocalDate issueDate;
    private LocalDate expiryDate;
    private String cardTier;
    private int loyaltyPoint;
    private String status;

    public MembershipCard4() {
        super();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCardCode() {
        return cardCode;
    }

    public void setCardCode(String cardCode) {
        this.cardCode = cardCode;
    }

    public LocalDate getIssueDate() {
        return issueDate;
    }

    public void setIssueDate(LocalDate issueDate) {
        this.issueDate = issueDate;
    }

    public LocalDate getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(LocalDate expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getCardTier() {
        return cardTier;
    }

    public void setCardTier(String cardTier) {
        this.cardTier = cardTier;
    }

    public int getLoyaltyPoint() {
        return loyaltyPoint;
    }

    public void setLoyaltyPoint(int loyaltyPoint) {
        this.loyaltyPoint = loyaltyPoint;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
