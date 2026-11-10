package dao;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Base64;
import java.util.EnumMap;
import java.util.Map;
import java.util.function.BiFunction;

import javax.imageio.ImageIO;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import model.Invoice4;
import model.MembershipCard4;
import model.Ticket4;

// Hoá đơn chỉ lưu khi đã trả tiền; trước đó không giữ ghế nào trong CSDL
public class InvoiceDAO4 extends DAO4 {
    // Tài khoản nhận tiền mẫu (BIN 970436), chỉ để demo
    private static final String BANK_BIN = "970436";
    private static final String BANK_ACCOUNT = "1234567890";

    public InvoiceDAO4() {
        super();
    }

    // Giảm theo hạng thẻ: Bạc 5%, Vàng 10%, Kim cương 15%; không truy cập CSDL
    public Invoice4 calculateDiscount(Invoice4 invoice, MembershipCard4 card) {
        double totalAmount = 0;
        for (Ticket4 ticket : invoice.getListTicket()) {
            totalAmount += ticket.getPrice();
        }
        double rate = 0;
        if (card != null) {
            switch (card.getCardTier()) {
                case "Bạc":
                    rate = 0.05;
                    break;
                case "Vàng":
                    rate = 0.10;
                    break;
                case "Kim cương":
                    rate = 0.15;
                    break;
                default:
                    rate = 0;
            }
        }
        double discount = Math.round(totalAmount * rate);
        invoice.setTotalAmount(totalAmount);
        invoice.setDiscount(discount);
        invoice.setFinalAmount(totalAmount - discount);
        return invoice;
    }

    // Khoá từng ghế (FOR UPDATE) và kiểm tra lại; một ghế không đạt thì huỷ cả giao dịch
    public Invoice4 saveInvoice(Invoice4 invoice) {
        Invoice4 result = null;
        if (invoice.getListTicket() == null || invoice.getListTicket().isEmpty()) {
            return null;
        }
        String invoiceStatus = "Đã thanh toán";
        String ticketStatus = "Đã bán";
        String sqlSeat = "SELECT status FROM tblSeat4 WHERE id = ? FOR UPDATE";
        String sqlCheck = "SELECT t.id FROM tblTicket4 t WHERE t.showtimeId = ? AND t.seatId = ?"
                + " AND t.status IN ('Đã bán', 'Đã sử dụng') FOR UPDATE";
        String sqlInvoice = "INSERT INTO tblInvoice4 (invoiceCode, createdDate, discount, paymentMethod, status,"
                + " salerId, customerId) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String sqlInvoiceCode = "UPDATE tblInvoice4 SET invoiceCode = ? WHERE id = ?";
        String sqlTicket = "INSERT INTO tblTicket4 (ticketCode, status, invoiceId, showtimeId, seatId, ticketPriceId)"
                + " VALUES (?, ?, ?, ?, ?, ?)";
        String sqlTicketCode = "UPDATE tblTicket4 SET ticketCode = ? WHERE id = ?";
        synchronized (DAO4.class) {
            try {
                con.setAutoCommit(false);
                LocalDateTime createdDate = LocalDateTime.now().truncatedTo(ChronoUnit.SECONDS);
                for (Ticket4 ticket : invoice.getListTicket()) {
                    try (PreparedStatement psSeat = con.prepareStatement(sqlSeat)) {
                        psSeat.setInt(1, ticket.getSeat().getId());
                        try (ResultSet rs = psSeat.executeQuery()) {
                            if (!rs.next() || !"Còn dùng được".equals(rs.getString("status"))) {
                                throw new IllegalStateException("Ghế " + ticket.getSeat().getSeatCode() + " không dùng được");
                            }
                        }
                    }
                    try (PreparedStatement psCheck = con.prepareStatement(sqlCheck)) {
                        psCheck.setInt(1, ticket.getShowtime().getId());
                        psCheck.setInt(2, ticket.getSeat().getId());
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (rs.next()) {
                                throw new IllegalStateException("Ghế " + ticket.getSeat().getSeatCode() + " vừa được bán");
                            }
                        }
                    }
                }
                int invoiceId;
                try (PreparedStatement psInvoice = con.prepareStatement(sqlInvoice, Statement.RETURN_GENERATED_KEYS)) {
                    psInvoice.setString(1, "TMP" + System.nanoTime() % 100000000000000L);
                    psInvoice.setTimestamp(2, Timestamp.valueOf(createdDate));
                    psInvoice.setDouble(3, invoice.getDiscount());
                    psInvoice.setString(4, invoice.getPaymentMethod());
                    psInvoice.setString(5, invoiceStatus);
                    psInvoice.setObject(6, invoice.getSaler() == null ? null : invoice.getSaler().getId());
                    psInvoice.setObject(7, invoice.getCustomer() == null ? null : invoice.getCustomer().getId());
                    psInvoice.executeUpdate();
                    try (ResultSet keys = psInvoice.getGeneratedKeys()) {
                        keys.next();
                        invoiceId = keys.getInt(1);
                    }
                }
                String invoiceCode = String.format("HD%07d", invoiceId);
                try (PreparedStatement psCode = con.prepareStatement(sqlInvoiceCode)) {
                    psCode.setString(1, invoiceCode);
                    psCode.setInt(2, invoiceId);
                    psCode.executeUpdate();
                }
                ArrayList<Integer> ticketIds = new ArrayList<>();
                for (Ticket4 ticket : invoice.getListTicket()) {
                    int ticketId;
                    try (PreparedStatement psTicket = con.prepareStatement(sqlTicket, Statement.RETURN_GENERATED_KEYS)) {
                        psTicket.setString(1, "TMP" + System.nanoTime() % 100000000000000L);
                        psTicket.setString(2, ticketStatus);
                        psTicket.setInt(3, invoiceId);
                        psTicket.setInt(4, ticket.getShowtime().getId());
                        psTicket.setInt(5, ticket.getSeat().getId());
                        psTicket.setInt(6, ticket.getTicketPrice().getId());
                        psTicket.executeUpdate();
                        try (ResultSet ticketKeys = psTicket.getGeneratedKeys()) {
                            ticketKeys.next();
                            ticketId = ticketKeys.getInt(1);
                        }
                    }
                    try (PreparedStatement psTicketCode = con.prepareStatement(sqlTicketCode)) {
                        psTicketCode.setString(1, String.format("VE%07d", ticketId));
                        psTicketCode.setInt(2, ticketId);
                        psTicketCode.executeUpdate();
                    }
                    ticketIds.add(ticketId);
                }
                con.commit();
                for (int i = 0; i < ticketIds.size(); i++) {
                    Ticket4 ticket = invoice.getListTicket().get(i);
                    ticket.setId(ticketIds.get(i));
                    ticket.setTicketCode(String.format("VE%07d", ticketIds.get(i)));
                    ticket.setStatus(ticketStatus);
                    ticket.setIssuedAt(createdDate);
                }
                invoice.setId(invoiceId);
                invoice.setInvoiceCode(invoiceCode);
                invoice.setCreatedDate(createdDate);
                invoice.setStatus(invoiceStatus);
                invoice.setChannel(invoice.getSaler() == null ? "Trực tuyến" : "Tại quầy");
                invoice.setEarnedPoint((int) Math.floor(invoice.getFinalAmount() / 10000));
                result = invoice;
            } catch (Exception e) {
                e.printStackTrace();
                try {
                    con.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                result = null;
            } finally {
                try {
                    con.setAutoCommit(true);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
        return result;
    }

    // VietQR (EMVCo); nội dung là mã nhân viên + thời điểm vì hoá đơn chưa có mã; trả ảnh PNG data URI
    public String createTransferQr(Invoice4 invoice) {
        String result = null;
        String reference = invoice.getSaler().getEmployeeCode()
                + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        BiFunction<String, String, String> tlv = (id, value) -> id + String.format("%02d", value.length()) + value;
        String beneficiary = tlv.apply("00", BANK_BIN) + tlv.apply("01", BANK_ACCOUNT);
        String merchant = tlv.apply("00", "A000000727") + tlv.apply("01", beneficiary) + tlv.apply("02", "QRIBFTTA");
        String payload = tlv.apply("00", "01") + tlv.apply("01", "12") + tlv.apply("38", merchant)
                + tlv.apply("53", "704") + tlv.apply("54", String.valueOf(Math.round(invoice.getFinalAmount())))
                + tlv.apply("58", "VN") + tlv.apply("62", tlv.apply("08", reference)) + "6304";
        int crc = 0xFFFF;
        for (byte b : payload.getBytes(StandardCharsets.US_ASCII)) {
            crc ^= (b & 0xFF) << 8;
            for (int i = 0; i < 8; i++) {
                crc = ((crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1) & 0xFFFF;
            }
        }
        payload += String.format("%04X", crc);
        try {
            Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
            hints.put(EncodeHintType.MARGIN, 2);
            BitMatrix matrix = new QRCodeWriter().encode(payload, BarcodeFormat.QR_CODE, 240, 240, hints);
            BufferedImage image = new BufferedImage(matrix.getWidth(), matrix.getHeight(), BufferedImage.TYPE_INT_RGB);
            for (int x = 0; x < matrix.getWidth(); x++) {
                for (int y = 0; y < matrix.getHeight(); y++) {
                    image.setRGB(x, y, matrix.get(x, y) ? 0x000000 : 0xFFFFFF);
                }
            }
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ImageIO.write(image, "png", out);
            result = "data:image/png;base64," + Base64.getEncoder().encodeToString(out.toByteArray());
        } catch (Exception e) {
            e.printStackTrace();
            result = null;
        }
        return result;
    }
}
