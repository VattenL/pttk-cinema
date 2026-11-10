package model;

import java.time.LocalDate;

public class Customer4 extends Member4 {
    private String customerCode;
    private LocalDate registerDate;
    private MembershipCard4 membershipCard;

    public Customer4() {
        super();
    }

    public String getCustomerCode() {
        return customerCode;
    }

    public void setCustomerCode(String customerCode) {
        this.customerCode = customerCode;
    }

    public LocalDate getRegisterDate() {
        return registerDate;
    }

    public void setRegisterDate(LocalDate registerDate) {
        this.registerDate = registerDate;
    }

    public MembershipCard4 getMembershipCard() {
        return membershipCard;
    }

    public void setMembershipCard(MembershipCard4 membershipCard) {
        this.membershipCard = membershipCard;
    }
}
