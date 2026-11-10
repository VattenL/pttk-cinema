<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDate, java.time.LocalDateTime, java.time.format.DateTimeFormatter, model.Saler4, model.Movie4, model.Showtime4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Chọn suất chiếu</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
body { max-width: 760px; }
.screen { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px 30px; box-shadow: 0 1px 2px rgba(25, 27, 40, .04), 0 12px 32px -18px rgba(25, 27, 40, .25); }
h1 { font: 800 34px/1 var(--display); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 20px; padding-bottom: 14px; border-bottom: 2px solid var(--ink); }
.info { display: grid; grid-template-columns: max-content 1fr; align-items: baseline; gap: 6px 20px; margin: 4px 0 18px; }
table + .info { margin-top: 10px; padding-top: 16px; border-top: 1.5px solid var(--line); }
.info span:nth-child(odd) { color: var(--muted); font-size: 13.5px; }
.info span:nth-child(even) { font-weight: 600; }
.btn { display: inline-flex; align-items: center; justify-content: center; min-width: 120px; min-height: 44px; padding: 0 22px; font: 600 15px var(--body); text-decoration: none; cursor: pointer; color: #fff; background: var(--velvet); border: 1.5px solid var(--velvet); border-radius: 8px; transition: background .15s, transform .1s; }
.btn:hover:not([disabled]):not(.off) { background: var(--velvet-dark); border-color: var(--velvet-dark); }
.btn:active:not([disabled]) { transform: translateY(1px); }
.btn.sec { color: var(--ink); background: #fff; border-color: #c4c8d6; }
.btn.sec:hover { background: var(--paper) !important; border-color: var(--ink) !important; }
.btn.off, .btn[disabled] { color: var(--off-text); background: var(--off); border-color: var(--off); cursor: not-allowed; }
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
td.act a { display: inline-block; padding: 6px 16px; font: 600 13px var(--body); text-decoration: none; cursor: pointer; color: #fff; background: var(--velvet); border: 0; border-radius: 999px; }
td.act a:hover { background: var(--velvet-dark); }
tr.off td { color: var(--off-text); }
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
  <h1>Chọn suất chiếu</h1>
  <c:set var="now" value="${LocalDateTime.now()}"/>
  <c:set var="showDateText" value="${LocalDate.parse(sessionScope.txtShowDate).format(DateTimeFormatter.ofPattern('dd/MM/yyyy'))}"/>
  <div class="info"><span>Phim:</span><span id="lblMovieTitle"><c:out value="${sessionScope.movie.title}"/></span>
    <span>Ngày chiếu:</span><span id="lblShowDate">${showDateText}</span></div>
  <table id="tblShowtime">
    <tr><th>TT</th><th>Mã suất</th><th>Giờ bắt đầu</th><th>Phòng</th><th>Định dạng</th><th>Ghế trống</th><th>Chọn</th></tr>
    <c:forEach var="showtime" items="${sessionScope.listShowtime}" varStatus="row">
      <c:set var="free" value="${showtime.room.capacity - sessionScope.mapSoldCount[showtime.id]}"/>
      <c:set var="started" value="${showtime.showDate.atTime(showtime.startTime).isBefore(now)}"/>
      <tr class="${started or free le 0 ? 'off' : ''}">
        <td>${row.count}</td>
        <td>${showtime.showtimeCode}</td>
        <td>${showtime.startTime}</td>
        <td>${showtime.room.roomCode}</td>
        <td>${showtime.format}</td>
        <td>${free}/${showtime.room.capacity}</td>
        <td class="act"><c:choose>
          <c:when test="${started}">(đã chiếu)</c:when>
          <c:when test="${free le 0}">(hết ghế)</c:when>
          <c:otherwise><a class="lnkSelectShowtime" id="lnkSelectShowtime${showtime.id}"
              href="${pageContext.request.contextPath}/sellTicket?action=selectShowtime&showtimeId=${showtime.id}">Chọn</a></c:otherwise>
        </c:choose></td>
      </tr>
    </c:forEach>
    <c:if test="${empty sessionScope.listShowtime}"><tr><td colspan="7">Phim không có suất chiếu trong ngày.</td></tr></c:if>
  </table>
  <p class="msg" id="lblMessage">${lblMessage}</p>
  <c:url var="backUrl" value="/sellTicket">
    <c:param name="action" value="searchMovie"/>
    <c:param name="txtTitle" value="${sessionScope.txtTitle}"/>
    <c:param name="txtShowDate" value="${sessionScope.txtShowDate}"/>
  </c:url>
  <div class="actions"><a class="btn sec" id="btnBack" href="${backUrl}">Quay lại</a></div>
</div>
</body>
</html>
