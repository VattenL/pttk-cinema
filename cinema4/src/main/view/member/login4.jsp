<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Đăng nhập</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
body { max-width: 500px; }
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
<form class="screen" method="post" action="${pageContext.request.contextPath}/login">
  <h1>Đăng nhập</h1>
  <div class="field"><label for="txtUsername">Tên đăng nhập</label>
    <input class="box" type="text" id="txtUsername" name="txtUsername" required></div>
  <div class="field"><label for="txtPassword">Mật khẩu</label>
    <input class="box" type="password" id="txtPassword" name="txtPassword" required></div>
  <p class="msg" id="lblError">${lblError}</p>
  <div class="actions">
    <a class="btn sec" id="btnBack" href="${pageContext.request.contextPath}/">Quay lại</a>
    <button class="btn" type="submit" id="btnLogin">Đăng nhập</button>
  </div>
</form>
</body>
</html>
