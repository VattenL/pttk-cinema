<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Saler4, model.Showtime4, model.Seat4, model.Ticket4, model.TicketPrice4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Chọn ghế</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
body { max-width: 880px; }
.screen { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px 30px; box-shadow: 0 1px 2px rgba(25, 27, 40, .04), 0 12px 32px -18px rgba(25, 27, 40, .25); }
h1 { font: 800 34px/1 var(--display); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 20px; padding-bottom: 14px; border-bottom: 2px solid var(--ink); }
h2 { font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--muted); margin: 24px 0 8px; }
.info { display: grid; grid-template-columns: max-content 1fr; align-items: baseline; gap: 6px 20px; margin: 4px 0 18px; }
table + .info { margin-top: 10px; padding-top: 16px; border-top: 1.5px solid var(--line); }
.info span:nth-child(odd) { color: var(--muted); font-size: 13.5px; }
.info span:nth-child(even) { font-weight: 600; }
.field { display: grid; grid-template-columns: 170px 1fr; align-items: center; gap: 12px; margin: 12px 0; }
.field > label { font-size: 14px; font-weight: 500; }
.box { width: 100%; height: 42px; padding: 0 12px; font: inherit; color: var(--ink); background: #fff; border: 1.5px solid var(--line); border-radius: 8px; transition: border-color .15s, box-shadow .15s; }
.box:hover { border-color: #c4c8d6; }
.box:focus { outline: none; border-color: var(--velvet); box-shadow: 0 0 0 3px var(--velvet-soft); }
.box::placeholder { color: var(--off-text); }
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
tr:has(td.act a):hover td { background: #fafafc; }
table:has(td.act) th:last-child { text-align: right; }
td.act { text-align: right; white-space: nowrap; color: var(--muted); font-size: 13px; }
td.act form { display: inline; margin: 0; }
td.act a, td.act button { display: inline-block; padding: 6px 16px; font: 600 13px var(--body); text-decoration: none; cursor: pointer; color: #fff; background: var(--velvet); border: 0; border-radius: 999px; }
td.act a:hover { background: var(--velvet-dark); }
td.act button { color: var(--err); background: transparent; border: 1.5px solid #ecc9c6; }
td.act button:hover { background: #fbeceb; }
.hall { margin: 4px -8px 0; padding: 26px 22px 18px; background: var(--house); border-radius: 14px; color: #c9cbe0; }
.screenbar { position: relative; margin: 0 9% 34px; height: 30px; text-align: center; font-size: 11px; font-weight: 600; letter-spacing: .4em; text-transform: uppercase; color: #8d90ab; padding-top: 12px; border-top: 3px solid #e9eaff; border-radius: 50% 50% 0 0 / 100% 100% 0 0; box-shadow: 0 -10px 28px -6px rgba(200, 205, 255, .45); background: linear-gradient(to bottom, rgba(200, 205, 255, .14), transparent); }
.seats { display: grid; grid-template-columns: 20px repeat(10, 1fr); gap: 7px 6px; margin: 0 auto; max-width: 620px; }
.seats b { align-self: center; font-size: 12px; color: #6f7290; text-align: center; }
.seats button { height: 30px; padding: 0; font: 600 11px var(--body); cursor: pointer; color: var(--ink); background: #e3e5ef; border: 0; border-radius: 8px 8px 4px 4px; box-shadow: inset 0 -4px 0 rgba(0, 0, 0, .12); transition: transform .1s, background .15s; }
.seats button[data-type="VIP"] { background: #e7a9ba; }
.seats button[data-type="Đôi"] { background: #a9c1ea; }
.seats button:hover:not(.sold) { transform: translateY(-2px); }
.seats button.pick { background: var(--bulb); box-shadow: 0 0 0 2px #fff3d6, 0 0 16px rgba(245, 184, 61, .8); }
.seats button.sold { color: #5d6080; background: #2b2d40; box-shadow: none; cursor: not-allowed; }
.legend { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 18px; margin: 22px 0 0; font-size: 12.5px; }
.legend i { display: inline-block; width: 16px; height: 14px; margin-right: 6px; vertical-align: -2px; border-radius: 5px 5px 2px 2px; background: #e3e5ef; }
.legend i.vip { background: #e7a9ba; }
.legend i.couple { background: #a9c1ea; }
.legend i.pick { background: var(--bulb); }
.legend i.sold { background: #2b2d40; outline: 1px solid #44475f; }
#lblPrice { flex-basis: 100%; color: #9fa2bd; }
.total { display: flex; justify-content: flex-end; align-items: baseline; gap: 12px; margin: 12px 0 4px; color: var(--muted); }
#lblTempTotal { font-size: 16px; font-weight: 600; color: var(--ink); }
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
  <h1>Chọn ghế</h1>
  <c:set var="showtime" value="${sessionScope.showtime}"/>
  <div class="info"><span>Phim:</span><span id="lblMovieTitle"><c:out value="${showtime.movie.title}"/></span>
    <span>Suất chiếu:</span><span id="lblShowtime">${showtime.showtimeCode}, ${showtime.startTime} ${showtime.showDate.dayOfMonth}/${showtime.showDate.monthValue}/${showtime.showDate.year}</span>
    <span>Phòng:</span><span id="lblRoom">${showtime.room.roomCode} (${showtime.format})</span></div>
  <div class="hall">
  <div class="screenbar">Màn hình</div>
  <form method="post" action="${pageContext.request.contextPath}/sellTicket">
    <input type="hidden" name="action" value="selectSeat">
    <div class="seats">
      <c:forEach var="seat" items="${sessionScope.listSeat}">
        <c:if test="${seat.seatNumber == 1}"><b>${seat.rowLabel}</b></c:if>
        <c:set var="sold" value="${seat.status != 'Còn dùng được'}"/>
        <c:forEach var="t" items="${sessionScope.listSoldTicket}"><c:if test="${t.seat.id == seat.id}"><c:set var="sold" value="${true}"/></c:if></c:forEach>
        <c:set var="pick" value="${false}"/>
        <c:forEach var="t" items="${sessionScope.listDraftTicket}"><c:if test="${t.seat.id == seat.id}"><c:set var="pick" value="${true}"/></c:if></c:forEach>
        <button type="submit" name="btnSeat" value="${seat.id}" title="${seat.seatCode} ${seat.seatType}" data-type="${seat.seatType}"
                class="${sold ? 'sold' : (pick ? 'pick' : '')}" ${sold ? 'disabled' : ''}>${seat.seatNumber}</button>
      </c:forEach>
    </div>
  </form>
  <div class="legend"><span><i></i>Thường</span><span><i class="vip"></i>VIP</span><span><i class="couple"></i>Đôi</span><span><i class="pick"></i>Đang chọn</span><span><i class="sold"></i>Đã bán</span>
    <span id="lblPrice">Giá: <c:forEach var="price" items="${sessionScope.listPrice}" varStatus="p">${p.first ? '' : ', '}ghế ${price.seatType} <fmt:formatNumber value="${price.amount}" pattern="#,##0"/> đ</c:forEach></span></div>
  </div>
  <p class="msg" id="lblMessage">${lblMessage}</p>
  <h2>Vé đang chọn</h2>
  <table id="tblDraftTicket">
    <tr><th>TT</th><th>Ghế</th><th>Loại ghế</th><th>Giá vé</th><th>Xoá</th></tr>
    <c:set var="tempTotal" value="${0}"/>
    <c:forEach var="ticket" items="${sessionScope.listDraftTicket}" varStatus="row">
      <c:set var="tempTotal" value="${tempTotal + ticket.price}"/>
      <tr>
        <td>${row.count}</td>
        <td>${ticket.seat.seatCode}</td>
        <td>${ticket.seat.seatType}</td>
        <td><fmt:formatNumber value="${ticket.price}" pattern="#,##0"/> đ</td>
        <td class="act"><form method="post" action="${pageContext.request.contextPath}/sellTicket">
          <input type="hidden" name="action" value="removeDraftTicket">
          <input type="hidden" name="seatId" value="${ticket.seat.id}">
          <button type="submit" class="btnRemoveTicket" id="btnRemoveTicket${ticket.seat.id}">Xoá</button></form></td>
      </tr>
    </c:forEach>
  </table>
  <div class="total" id="lblTempTotal">Tạm tính: <fmt:formatNumber value="${tempTotal}" pattern="#,##0"/> đ</div>
  <form method="post" action="${pageContext.request.contextPath}/sellTicket">
    <input type="hidden" name="action" value="confirmPurchase">
    <div class="field"><label for="txtCardCode">Mã thẻ hội viên</label>
      <input class="box" type="text" id="txtCardCode" name="txtCardCode" placeholder="(nếu có)"
             value="<c:out value='${sessionScope.txtCardCode}'/>"></div>
    <div class="actions">
      <a class="btn sec" id="btnBack" href="${pageContext.request.contextPath}/sellTicket?action=selectMovie&movieId=${showtime.movie.id}">Quay lại</a>
      <button class="btn" type="submit" id="btnConfirm">Xác nhận mua</button>
    </div>
  </form>
</div>
</body>
</html>
