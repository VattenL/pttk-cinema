<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Saler4, model.Invoice4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>In vé và hoá đơn</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
body { max-width: 760px; }
.screen { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px 30px; box-shadow: 0 1px 2px rgba(25, 27, 40, .04), 0 12px 32px -18px rgba(25, 27, 40, .25); }
h1 { font: 800 34px/1 var(--display); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 20px; padding-bottom: 14px; border-bottom: 2px solid var(--ink); }
h2 { font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin: 24px 0 8px; }
.btn { display: inline-flex; align-items: center; justify-content: center; min-width: 120px; min-height: 44px; padding: 0 22px; font: 600 15px var(--body); text-decoration: none; cursor: pointer; color: #fff; background: var(--velvet); border: 1.5px solid var(--velvet); border-radius: 8px; transition: background .15s, transform .1s; }
.btn:hover:not([disabled]):not(.off) { background: var(--velvet-dark); border-color: var(--velvet-dark); }
.btn:active:not([disabled]) { transform: translateY(1px); }
.btn[disabled] { color: var(--off-text); background: var(--off); border-color: var(--off); cursor: not-allowed; }
.actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; }
:focus-visible { outline: 3px solid var(--bulb); outline-offset: 2px; }
.msg { margin: 12px 0 0; padding: 10px 14px; border-radius: 8px; font-size: 14px; color: var(--err); background: #fbeceb; }
.msg.ok { color: var(--ok); background: #e8f4ee; }
.msg:empty { display: none; }
table { width: 100%; border-collapse: collapse; margin: 6px 0; font-size: 14px; }
th { text-align: left; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); padding: 8px 10px; border-bottom: 1.5px solid var(--line); }
td { padding: 11px 10px; border-bottom: 1px solid var(--line); }
tr:last-child td { border-bottom: 0; }
#tblInvoice td:first-child { color: var(--muted); width: 42%; }
#tblInvoice tr:nth-last-child(3) td:last-child { font-weight: 700; }
@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
}
@media print {
  html, body { background: #fff; }
  .screen { border: 0; box-shadow: none; padding: 0; }
  .actions, .msg { display: none; }
}
</style></head>
<body onload="window.print()">
<div class="screen">
  <h1>In vé và hoá đơn</h1>
  <p class="msg ok" id="lblMessage">${lblMessage}</p>
  <c:set var="invoice" value="${sessionScope.invoice}"/>
  <table id="tblPrintedTicket">
    <tr><th>Mã vé</th><th>Phim</th><th>Suất chiếu</th><th>Phòng</th><th>Ghế</th><th>Giá vé</th></tr>
    <c:forEach var="ticket" items="${invoice.listTicket}">
      <c:set var="st" value="${ticket.showtime}"/>
      <tr><td>${ticket.ticketCode}</td><td><c:out value="${st.movie.title}"/></td>
        <td>${st.startTime} ${st.showDate.dayOfMonth}/${st.showDate.monthValue}/${st.showDate.year}</td>
        <td>${st.room.roomCode}</td><td>${ticket.seat.seatCode}</td>
        <td><fmt:formatNumber value="${ticket.price}" pattern="#,##0"/> đ</td></tr>
    </c:forEach>
  </table>
  <h2>Hoá đơn</h2>
  <table id="tblInvoice">
    <tr><td>Mã hoá đơn</td><td>${invoice.invoiceCode}</td></tr>
    <tr><td>Ngày lập</td><td>${invoice.createdDate.dayOfMonth}/${invoice.createdDate.monthValue}/${invoice.createdDate.year} ${invoice.createdDate.toLocalTime()}</td></tr>
    <tr><td>Nhân viên lập</td><td><c:out value="${invoice.saler.fullName}"/> (${invoice.saler.counter})</td></tr>
    <tr><td>Khách hàng</td><td><c:choose>
      <c:when test="${empty invoice.customer}">(khách lẻ)</c:when>
      <c:otherwise><c:out value="${invoice.customer.fullName}"/> (${invoice.customer.customerCode}), thẻ ${invoice.customer.membershipCard.cardCode} hạng ${invoice.customer.membershipCard.cardTier}</c:otherwise>
    </c:choose></td></tr>
    <tr><td>Số vé</td><td>${invoice.listTicket.size()}</td></tr>
    <tr><td>Tổng tiền</td><td><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,##0"/> đ</td></tr>
    <tr><td>Giảm giá</td><td><fmt:formatNumber value="${invoice.discount}" pattern="#,##0"/> đ</td></tr>
    <tr><td>Thành tiền</td><td><fmt:formatNumber value="${invoice.finalAmount}" pattern="#,##0"/> đ</td></tr>
    <tr><td>Hình thức thanh toán</td><td>${invoice.paymentMethod}</td></tr>
    <tr><td>Điểm tích luỹ cộng thêm</td><td>${empty invoice.customer ? 0 : invoice.earnedPoint} điểm<c:if test="${not empty sessionScope.card}">, tổng điểm thẻ ${sessionScope.card.loyaltyPoint}</c:if></td></tr>
  </table>
  <form class="actions" method="post" action="${pageContext.request.contextPath}/sellTicket">
    <input type="hidden" name="action" value="finish">
    <button class="btn" type="submit" id="btnFinish">Kết thúc</button>
  </form>
</div>
</body>
</html>
