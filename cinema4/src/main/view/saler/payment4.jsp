<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Saler4, model.Invoice4, model.MembershipCard4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Thanh toán</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
.screen { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px 30px; box-shadow: 0 1px 2px rgba(25, 27, 40, .04), 0 12px 32px -18px rgba(25, 27, 40, .25); }
h1 { font: 800 34px/1 var(--display); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 20px; padding-bottom: 14px; border-bottom: 2px solid var(--ink); }
.info { display: grid; grid-template-columns: max-content 1fr; align-items: baseline; gap: 6px 20px; margin: 4px 0 18px; }
table + .info { margin-top: 10px; padding-top: 16px; border-top: 1.5px solid var(--line); }
.info span:nth-child(odd) { color: var(--muted); font-size: 13.5px; }
.info span:nth-child(even) { font-weight: 600; }
.field { display: grid; grid-template-columns: 170px 1fr; align-items: center; gap: 12px; margin: 12px 0; }
.field > label { font-size: 14px; font-weight: 500; }
.radio { display: flex; flex-wrap: wrap; gap: 8px; }
.radio label { display: inline-flex; align-items: center; gap: 8px; padding: 9px 16px; cursor: pointer; border: 1.5px solid var(--line); border-radius: 999px; font-weight: 500; transition: border-color .15s, background .15s; }
.radio label:hover { border-color: #c4c8d6; }
.radio label:has(input:checked) { border-color: var(--velvet); background: var(--velvet-soft); color: var(--velvet-dark); }
.radio input { accent-color: var(--velvet); margin: 0; }
.btn { display: inline-flex; align-items: center; justify-content: center; min-width: 120px; min-height: 44px; padding: 0 22px; font: 600 15px var(--body); text-decoration: none; cursor: pointer; color: #fff; background: var(--velvet); border: 1.5px solid var(--velvet); border-radius: 8px; transition: background .15s, transform .1s; }
.btn:hover:not([disabled]):not(.off) { background: var(--velvet-dark); border-color: var(--velvet-dark); }
.btn:active:not([disabled]) { transform: translateY(1px); }
.btn.sec { color: var(--ink); background: #fff; border-color: #c4c8d6; }
.btn.sec:hover { background: var(--paper) !important; border-color: var(--ink) !important; }
.btn[disabled] { color: var(--off-text); background: var(--off); border-color: var(--off); cursor: not-allowed; }
.actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; }
:focus-visible { outline: 3px solid var(--bulb); outline-offset: 2px; }
.msg { margin: 12px 0 0; padding: 10px 14px; border-radius: 8px; font-size: 14px; color: var(--err); background: #fbeceb; }
.msg:empty { display: none; }
table { width: 100%; border-collapse: collapse; margin: 6px 0; font-size: 14px; }
th { text-align: left; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); padding: 8px 10px; border-bottom: 1.5px solid var(--line); }
td { padding: 11px 10px; border-bottom: 1px solid var(--line); }
tr:last-child td { border-bottom: 0; }
#lblFinalAmount { font: 800 26px/1 var(--display); color: var(--velvet); letter-spacing: .02em; }
@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
}
@media print {
  html, body { background: #fff; }
  .screen { border: 0; box-shadow: none; padding: 0; }
  .actions, .msg { display: none; }
}
</style></head>
<body>
<div class="screen">
  <h1>Thanh toán</h1>
  <c:set var="invoice" value="${sessionScope.invoice}"/>
  <c:set var="showtime" value="${sessionScope.showtime}"/>
  <div class="info"><span>Phim:</span><span id="lblMovieTitle"><c:out value="${showtime.movie.title}"/></span>
    <span>Suất chiếu:</span><span id="lblShowtime">${showtime.startTime} ${showtime.showDate.dayOfMonth}/${showtime.showDate.monthValue}/${showtime.showDate.year}</span>
    <span>Phòng:</span><span id="lblRoom">${showtime.room.roomCode}</span></div>
  <table id="tblTicket">
    <tr><th>TT</th><th>Ghế</th><th>Loại ghế</th><th>Giá vé</th></tr>
    <c:forEach var="ticket" items="${invoice.listTicket}" varStatus="row">
      <tr><td>${row.count}</td><td>${ticket.seat.seatCode}</td><td>${ticket.seat.seatType}</td>
        <td><fmt:formatNumber value="${ticket.price}" pattern="#,##0"/> đ</td></tr>
    </c:forEach>
  </table>
  <div class="info">
    <span>Khách hàng:</span><span id="lblCustomerName"><c:out value="${empty invoice.customer ? '(khách lẻ)' : invoice.customer.fullName}"/><c:if test="${not empty sessionScope.card}">, thẻ ${sessionScope.card.cardCode} hạng ${sessionScope.card.cardTier}</c:if></span>
    <span>Tổng tiền:</span><span id="lblTotalAmount"><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,##0"/> đ</span>
    <span>Giảm giá:</span><span id="lblDiscount"><fmt:formatNumber value="${invoice.discount}" pattern="#,##0"/> đ</span>
    <span>Thành tiền:</span><span id="lblFinalAmount"><fmt:formatNumber value="${invoice.finalAmount}" pattern="#,##0"/> đ</span>
  </div>
  <p class="msg" id="lblMessage">${lblMessage}</p>
  <form method="post" action="${pageContext.request.contextPath}/sellTicket">
    <input type="hidden" name="action" value="pay">
    <div class="field"><label>Hình thức thanh toán</label>
      <div class="radio" id="rdoPaymentMethod">
        <label><input type="radio" name="rdoPaymentMethod" value="Tiền mặt" required onchange="unlockPay()"> Tiền mặt</label>
        <label><input type="radio" name="rdoPaymentMethod" value="Chuyển khoản" onchange="unlockPay()"> Chuyển khoản</label>
      </div></div>
    <div class="actions">
      <a class="btn sec" id="btnBack" href="${pageContext.request.contextPath}/sellTicket?action=selectShowtime&showtimeId=${showtime.id}">Quay lại</a>
      <button class="btn" type="submit" id="btnPay" disabled>Thanh toán</button>
    </div>
  </form>
</div>
<script>
  // Mở khoá Thanh toán khi đã chọn hình thức thanh toán
  function unlockPay() {
    document.getElementById('btnPay').disabled = false;
  }
</script>
</body>
</html>
