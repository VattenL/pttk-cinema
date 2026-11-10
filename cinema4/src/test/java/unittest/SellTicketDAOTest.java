package unittest;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

import javax.imageio.ImageIO;

import org.junit.After;
import org.junit.Test;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

import dao.CustomerDAO4;
import dao.InvoiceDAO4;
import dao.MemberDAO4;
import dao.MembershipCardDAO4;
import dao.MovieDAO4;
import dao.SeatDAO4;
import dao.ShowtimeDAO4;
import dao.TicketDAO4;
import dao.TicketPriceDAO4;
import model.Customer4;
import model.Invoice4;
import model.Member4;
import model.MembershipCard4;
import model.Movie4;
import model.Saler4;
import model.Seat4;
import model.Showtime4;
import model.Ticket4;
import model.TicketPrice4;

// Dữ liệu theo kịch bản: PH001, SC0082 08/09/2026, ghế G07 G08, thẻ HV0000123 hạng Vàng
public class SellTicketDAOTest {
    private static final LocalDate SHOW_DATE = LocalDate.of(2026, 9, 8);

    @After
    public void cleanUp() throws Exception {
        TestDB.execute(
                "DELETE FROM tblTicket4 WHERE invoiceId >= 5678",
                "DELETE FROM tblInvoice4 WHERE id >= 5678",
                "ALTER TABLE tblInvoice4 AUTO_INCREMENT = 5678",
                "ALTER TABLE tblTicket4 AUTO_INCREMENT = 12345",
                "UPDATE tblSeat4 SET status = 'Còn dùng được'");
    }

    private Movie4 spiderMan() {
        for (Movie4 m : new MovieDAO4().searchShowingMovies("Spider", SHOW_DATE)) {
            if (m.getMovieCode().equals("PH001")) {
                return m;
            }
        }
        return null;
    }

    private Showtime4 sc0082() {
        for (Showtime4 s : new ShowtimeDAO4().getShowtimesOfMovie(spiderMan(), SHOW_DATE)) {
            if (s.getShowtimeCode().equals("SC0082")) {
                return s;
            }
        }
        return null;
    }

    private Seat4 seat(Showtime4 showtime, String code) {
        for (Seat4 s : new SeatDAO4().getSeatsOfRoom(showtime.getRoom())) {
            if (s.getSeatCode().equals(code)) {
                return s;
            }
        }
        return null;
    }

    private Saler4 saler() {
        Member4 login = new Member4() {
        };
        login.setUsername("banve.b");
        login.setPassword("123456");
        return (Saler4) new MemberDAO4().checkLogin(login);
    }

    private Invoice4 invoice(String paymentMethod, String... seats) {
        Showtime4 showtime = sc0082();
        ArrayList<TicketPrice4> prices = new TicketPriceDAO4().getPricesOfShowtime(showtime);
        ArrayList<Ticket4> tickets = new ArrayList<>();
        for (String code : seats) {
            Ticket4 t = new TicketDAO4().calculatePrice(seat(showtime, code), prices);
            t.setShowtime(showtime);
            tickets.add(t);
        }
        Invoice4 invoice = new Invoice4();
        invoice.setListTicket(tickets);
        invoice.setSaler(saler());
        MembershipCard4 card = new MembershipCardDAO4().getCardByCode("HV0000123");
        invoice.setCustomer(new CustomerDAO4().getCustomerOfCard(card));
        new InvoiceDAO4().calculateDiscount(invoice, card);
        invoice.setPaymentMethod(paymentMethod);
        return invoice;
    }

    @Test
    public void searchShowingMoviesByTitle() {
        // Ngày của kịch bản chỉ có suất của PH001, PH009; hôm nay 11 phim có suất (seed.sql)
        assertEquals(2, new MovieDAO4().searchShowingMovies("", SHOW_DATE).size());
        assertEquals(11, new MovieDAO4().searchShowingMovies("", LocalDate.now()).size());
        ArrayList<Movie4> spider = new MovieDAO4().searchShowingMovies("Spider", SHOW_DATE);
        assertEquals(2, spider.size());
        assertEquals("PH001", spider.get(0).getMovieCode());
        assertEquals(0, new MovieDAO4().searchShowingMovies("Không có phim này", SHOW_DATE).size());
        // Phim hết chiếu (PH020) hoặc không có suất trong ngày thì không hiện
        assertEquals(0, new MovieDAO4().searchShowingMovies("Ngôi Nhà Ma Ám", SHOW_DATE).size());
    }

    @Test
    public void showtimesAndSoldCount() {
        ArrayList<Showtime4> list = new ShowtimeDAO4().getShowtimesOfMovie(spiderMan(), SHOW_DATE);
        assertEquals(3, list.size());
        Showtime4 sc0082 = sc0082();
        assertEquals(80, sc0082.getRoom().getCapacity());
        HashMap<Integer, Integer> sold = new TicketDAO4().countSoldTickets(list);
        assertEquals(46, sc0082.getRoom().getCapacity() - sold.get(sc0082.getId()));
    }

    @Test
    public void seatMapAndPrice() {
        Showtime4 showtime = sc0082();
        ArrayList<Ticket4> soldSeats = new TicketDAO4().getSoldSeats(showtime);
        assertEquals(34, soldSeats.size());
        assertEquals(80, new SeatDAO4().getSeatsOfRoom(showtime.getRoom()).size());
        ArrayList<TicketPrice4> prices = new TicketPriceDAO4().getPricesOfShowtime(showtime);
        assertEquals(3, prices.size());
        Seat4 g07 = seat(showtime, "G07");
        assertEquals("VIP", g07.getSeatType());
        assertTrue(new TicketDAO4().checkSeatAvailable(showtime, g07));
        assertFalse(new TicketDAO4().checkSeatAvailable(showtime, seat(showtime, "A01")));
        Ticket4 ticket = new TicketDAO4().calculatePrice(g07, prices);
        assertEquals(105000, ticket.getPrice(), 0);
        assertEquals("GV2D-NT-V", ticket.getTicketPrice().getPriceCode());
    }

    @Test
    public void brokenSeatIsNotAvailable() throws Exception {
        Showtime4 showtime = sc0082();
        Seat4 g09 = seat(showtime, "G09");
        TestDB.execute("UPDATE tblSeat4 SET status = 'Đang hỏng' WHERE id = " + g09.getId());
        assertFalse(new TicketDAO4().checkSeatAvailable(showtime, g09));
        assertNull(new InvoiceDAO4().saveInvoice(invoice("Tiền mặt", "G09")));
    }

    @Test
    public void cardAndCustomer() {
        MembershipCardDAO4 cardDAO = new MembershipCardDAO4();
        assertNull(cardDAO.getCardByCode("HV9999999"));
        MembershipCard4 card = cardDAO.getCardByCode("HV0000123");
        assertEquals("Vàng", card.getCardTier());
        assertEquals(15, card.getLoyaltyPoint());
        Customer4 customer = new CustomerDAO4().getCustomerOfCard(card);
        assertEquals("KH0001234", customer.getCustomerCode());
        assertEquals("Nguyễn Văn A", customer.getFullName());
        assertEquals(33, cardDAO.addLoyaltyPoint(card, 18));
    }

    @Test
    public void payCashWithGoldCard() {
        Invoice4 invoice = invoice("Tiền mặt", "G07", "G08");
        assertEquals(210000, invoice.getTotalAmount(), 0);
        assertEquals(21000, invoice.getDiscount(), 0);
        assertEquals(189000, invoice.getFinalAmount(), 0);
        Invoice4 saved = new InvoiceDAO4().saveInvoice(invoice);
        assertNotNull(saved);
        assertEquals("HD0005678", saved.getInvoiceCode());
        assertEquals("Đã thanh toán", saved.getStatus());
        assertEquals("VE0012345", saved.getListTicket().get(0).getTicketCode());
        assertEquals("Đã bán", saved.getListTicket().get(0).getStatus());
        assertEquals(18, saved.getEarnedPoint());
        assertEquals(33, new MembershipCardDAO4().getCardByCode("HV0000123").getLoyaltyPoint());
        Showtime4 showtime = sc0082();
        assertFalse(new TicketDAO4().checkSeatAvailable(showtime, seat(showtime, "G07")));
        // Bán lại đúng hai ghế đó: giao dịch bị huỷ
        assertNull(new InvoiceDAO4().saveInvoice(invoice("Tiền mặt", "G07", "G08")));
    }

    @Test
    public void transferSavesOnlyWhenMoneyArrives() throws Exception {
        InvoiceDAO4 invoiceDAO = new InvoiceDAO4();
        Invoice4 invoice = invoice("Chuyển khoản", "G07", "G08");

        // QR tạo trước khi lưu: số tiền 189000, nội dung mã nhân viên + thời điểm, CRC đúng
        String qr = invoiceDAO.createTransferQr(invoice);
        assertTrue(qr.startsWith("data:image/png;base64,"));
        BufferedImage image = ImageIO.read(new ByteArrayInputStream(
                Base64.getDecoder().decode(qr.substring("data:image/png;base64,".length()))));
        String payload = new QRCodeReader().decode(new BinaryBitmap(new HybridBinarizer(
                new BufferedImageLuminanceSource(image)))).getText();
        assertTrue(payload.startsWith("000201010212"));
        assertTrue(payload.contains("0010A000000727"));
        assertTrue(payload.contains("5406189000"));
        assertTrue(payload.matches(".*62240820NV0002\\d{14}6304.*"));
        int crc = 0xFFFF;
        for (byte b : payload.substring(0, payload.length() - 4).getBytes(StandardCharsets.US_ASCII)) {
            crc ^= (b & 0xFF) << 8;
            for (int i = 0; i < 8; i++) {
                crc = ((crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1) & 0xFFFF;
            }
        }
        assertEquals(String.format("%04X", crc), payload.substring(payload.length() - 4));

        // Chờ tiền về: chưa có gì trong CSDL, ghế vẫn trống, chưa cộng điểm
        Showtime4 showtime = sc0082();
        assertTrue(new TicketDAO4().checkSeatAvailable(showtime, seat(showtime, "G07")));
        assertEquals(34, new TicketDAO4().getSoldSeats(showtime).size());
        assertEquals(15, new MembershipCardDAO4().getCardByCode("HV0000123").getLoyaltyPoint());

        // Tiền về: lưu như hoá đơn tiền mặt
        Invoice4 saved = invoiceDAO.saveInvoice(invoice);
        assertEquals("HD0005678", saved.getInvoiceCode());
        assertEquals("Chuyển khoản", saved.getPaymentMethod());
        assertEquals("Đã thanh toán", saved.getStatus());
        assertEquals("Đã bán", saved.getListTicket().get(0).getStatus());
        assertEquals(36, new TicketDAO4().getSoldSeats(showtime).size());
        assertEquals(33, new MembershipCardDAO4().getCardByCode("HV0000123").getLoyaltyPoint());
    }

    @Test
    public void seatSoldWhileWaitingForTransfer() {
        InvoiceDAO4 invoiceDAO = new InvoiceDAO4();
        Invoice4 transfer = invoice("Chuyển khoản", "G07");
        assertNotNull(invoiceDAO.createTransferQr(transfer));
        // Quầy khác bán mất G07 trong lúc khách đang chuyển khoản
        assertNotNull(invoiceDAO.saveInvoice(invoice("Tiền mặt", "G07")));
        assertNull(invoiceDAO.saveInvoice(transfer));
    }

    @Test
    public void twoCountersCannotSellTheSameSeat() throws Exception {
        Invoice4 first = invoice("Tiền mặt", "E05");
        Invoice4 second = invoice("Chuyển khoản", "E05");
        CountDownLatch start = new CountDownLatch(1);
        AtomicInteger saved = new AtomicInteger();
        Thread[] threads = new Thread[2];
        Invoice4[] invoices = {first, second};
        for (int i = 0; i < 2; i++) {
            Invoice4 inv = invoices[i];
            threads[i] = new Thread(() -> {
                try {
                    start.await();
                } catch (InterruptedException e) {
                    return;
                }
                if (new InvoiceDAO4().saveInvoice(inv) != null) {
                    saved.incrementAndGet();
                }
            });
            threads[i].start();
        }
        start.countDown();
        for (Thread t : threads) {
            t.join();
        }
        assertEquals(1, saved.get());
        Showtime4 showtime = sc0082();
        assertEquals(35, new TicketDAO4().getSoldSeats(showtime).size());
    }
}
