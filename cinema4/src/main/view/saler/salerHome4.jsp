<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Saler4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Trang chủ nhân viên bán vé</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
body { max-width: 500px; }
.screen { background: var(--card); border: 1px solid var(--line); border-radius: 16px; padding: 28px 32px 30px; box-shadow: 0 1px 2px rgba(25, 27, 40, .04), 0 12px 32px -18px rgba(25, 27, 40, .25); }
h1 { font: 800 34px/1 var(--display); text-transform: uppercase; letter-spacing: .02em; margin: 0 0 20px; padding-bottom: 14px; border-bottom: 2px solid var(--ink); }
.info { display: grid; grid-template-columns: max-content 1fr; align-items: baseline; gap: 6px 20px; margin: 4px 0 18px; }
.info span:nth-child(odd) { color: var(--muted); font-size: 13.5px; }
.info span:nth-child(even) { font-weight: 600; }
.btn { display: inline-flex; align-items: center; justify-content: center; min-width: 120px; min-height: 44px; padding: 0 22px; font: 600 15px var(--body); text-decoration: none; cursor: pointer; color: #fff; background: var(--velvet); border: 1.5px solid var(--velvet); border-radius: 8px; transition: background .15s, transform .1s; }
.btn:hover:not([disabled]):not(.off) { background: var(--velvet-dark); border-color: var(--velvet-dark); }
.btn:active:not([disabled]) { transform: translateY(1px); }
.btn.sec { color: var(--ink); background: #fff; border-color: #c4c8d6; }
.btn.sec:hover { background: var(--paper) !important; border-color: var(--ink) !important; }
.btn[disabled] { color: var(--off-text); background: var(--off); border-color: var(--off); cursor: not-allowed; }
.actions { display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; }
.menu { display: flex; flex-direction: column; gap: 10px; margin: 8px auto 4px; max-width: 320px; }
.menu .btn { width: 100%; min-height: 50px; font-size: 16px; }
.menu form { margin: 0; }
:focus-visible { outline: 3px solid var(--bulb); outline-offset: 2px; }
@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
}
@media print {
  html, body { background: #fff; }
  .screen { border: 0; box-shadow: none; padding: 0; }
  .actions { display: none; }
}
</style></head>
<body>
<div class="screen">
  <h1>Trang chủ nhân viên bán vé</h1>
  <div class="info"><span>Nhân viên:</span><span id="lblSalerName"><c:out value="${sessionScope.saler.fullName}"/></span>
    <span>Quầy:</span><span id="lblCounter">${sessionScope.saler.counter}</span></div>
  <div class="menu">
    <a class="btn" id="lnkSellTicket" href="${pageContext.request.contextPath}/sellTicket?action=openSearchMovie">Bán vé</a>
    <button class="btn" type="button" id="btnIssueCard" disabled title="Chức năng chưa mở">Cấp thẻ hội viên</button>
  </div>
  <form class="actions" method="post" action="${pageContext.request.contextPath}/login">
    <input type="hidden" name="action" value="logout">
    <button class="btn sec" type="submit" id="btnLogout">Đăng xuất</button>
  </form>
</div>
</body>
</html>
