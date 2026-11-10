package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import model.MembershipCard4;

public class MembershipCardDAO4 extends DAO4 {

    public MembershipCardDAO4() {
        super();
    }

    // Điểm không có cột trong CSDL: tính lại từ các hoá đơn đã thanh toán của chủ thẻ
    public MembershipCard4 getCardByCode(String cardCode) {
        MembershipCard4 result = null;
        String sql = "SELECT * FROM tblMembershipCard4"
                + " WHERE cardCode = ? AND status = 'Đang dùng' AND expiryDate >= CURDATE()";
        String sqlPoint = "SELECT COALESCE(SUM(FLOOR((x.totalAmount - x.discount) / 10000)), 0) AS point"
                + " FROM (SELECT i.id, i.discount, SUM(p.amount) AS totalAmount"
                + " FROM tblInvoice4 i"
                + " JOIN tblTicket4 t ON t.invoiceId = i.id AND t.status IN ('Đã bán', 'Đã sử dụng')"
                + " JOIN tblTicketPrice4 p ON p.id = t.ticketPriceId"
                + " WHERE i.customerId = ? AND i.status = 'Đã thanh toán' GROUP BY i.id, i.discount) x";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cardCode == null ? "" : cardCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result = new MembershipCard4();
                    result.setId(rs.getInt("id"));
                    result.setCardCode(rs.getString("cardCode"));
                    result.setIssueDate(rs.getDate("issueDate").toLocalDate());
                    result.setExpiryDate(rs.getDate("expiryDate").toLocalDate());
                    result.setCardTier(rs.getString("cardTier"));
                    result.setStatus(rs.getString("status"));
                    try (PreparedStatement psPoint = con.prepareStatement(sqlPoint)) {
                        psPoint.setInt(1, rs.getInt("customerId"));
                        try (ResultSet rsPoint = psPoint.executeQuery()) {
                            if (rsPoint.next()) {
                                result.setLoyaltyPoint(rsPoint.getInt("point"));
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }

    // Chỉ cộng vào đối tượng trong phiên, không ghi CSDL
    public int addLoyaltyPoint(MembershipCard4 card, int earnedPoint) {
        card.setLoyaltyPoint(card.getLoyaltyPoint() + earnedPoint);
        return card.getLoyaltyPoint();
    }
}
