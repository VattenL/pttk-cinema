<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Saler4, model.Movie4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Tìm phim</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
body { max-width: 760px; }
.screen { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px 30px; box-shadow: 0 1px 2px rgba(25, 27, 40, .04), 0 12px 32px -18px rgba(25, 27, 40, .25); }
h1 { font: 800 34px/1 var(--display); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 20px; padding-bottom: 14px; border-bottom: 2px solid var(--ink); }
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
.movies { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 18px 16px; margin: 20px 0 6px; }
.movie { display: block; color: var(--ink); text-decoration: none; border-radius: var(--radius); }
.movie .poster { display: flex; align-items: center; justify-content: center; aspect-ratio: 2 / 3; overflow: hidden; border-radius: var(--radius); background: var(--off); color: var(--muted); font-size: 13px; box-shadow: 0 6px 18px -10px rgba(25, 27, 40, .5); transition: transform .2s, box-shadow .2s; }
.movie .poster img { width: 100%; height: 100%; object-fit: cover; display: block; }
.movie b { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; margin-top: 10px; font-size: 14.5px; line-height: 1.3; }
.movie small { display: block; margin-top: 3px; color: var(--muted); font-size: 13px; }
.movie:hover .poster { transform: translateY(-4px); box-shadow: 0 14px 26px -12px rgba(155, 29, 63, .55); }
.movie:hover b { color: var(--velvet); }
body { max-width: 1040px; }
.screen.bare { display: grid; grid-template-columns: 2fr 1fr auto; align-items: end; gap: 0 16px; padding: 0; background: none; border: 0; box-shadow: none; }
.bare > * { grid-column: 1 / -1; }
.bare > .field { grid-column: auto; display: flex; flex-direction: column; align-items: stretch; gap: 6px; margin: 0; }
.bare > .field + .field + .actions { grid-column: auto; margin: 0; }
.bare .movies { grid-template-columns: repeat(4, 1fr); gap: 32px 24px; margin-top: 28px; }
.bare .movie b { font-size: 16px; margin-top: 12px; }
.bare .movie small { font-size: 13.5px; }
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
<form class="screen bare" method="get" action="${pageContext.request.contextPath}/sellTicket">
  <h1>Tìm phim</h1>
  <div class="field"><label for="txtTitle">Tên phim</label>
    <input class="box" type="text" id="txtTitle" name="txtTitle" value="<c:out value='${sessionScope.txtTitle}'/>"></div>
  <div class="field"><label for="txtShowDate">Ngày chiếu</label>
    <input class="box" type="date" id="txtShowDate" name="txtShowDate" value="${sessionScope.txtShowDate}"></div>
  <div class="actions"><button class="btn" type="submit" id="btnSearch" name="action" value="searchMovie">Tìm</button></div>
  <div class="movies" id="tblMovie">
    <c:forEach var="movie" items="${sessionScope.listMovie}">
      <a class="movie lnkSelectMovie" id="lnkSelectMovie${movie.id}"
         href="${pageContext.request.contextPath}/sellTicket?action=selectMovie&movieId=${movie.id}">
        <span class="poster">
          <c:choose>
            <c:when test="${fn:startsWith(movie.poster, 'http')}">
              <img src="<c:out value='${movie.poster}'/>" alt="<c:out value='${movie.title}'/>">
            </c:when>
            <c:when test="${not empty movie.poster}">
              <img src="${pageContext.request.contextPath}/${movie.poster}" alt="<c:out value='${movie.title}'/>">
            </c:when>
            <c:otherwise>Chưa có poster</c:otherwise>
          </c:choose>
        </span>
        <b><c:out value="${movie.title}"/></b>
        <small>${movie.duration} phút · ${movie.ageRating}</small>
      </a>
    </c:forEach>
  </div>
  <c:if test="${sessionScope.listMovie != null and empty sessionScope.listMovie}">
    <p class="msg">Không có phim nào có suất chiếu vào ngày đã chọn và khớp tên đã nhập.</p>
  </c:if>
  <div class="actions"><button class="btn sec" type="submit" id="btnBack" name="action" value="finish" formmethod="post">Quay lại</button></div>
</form>
</body>
</html>
