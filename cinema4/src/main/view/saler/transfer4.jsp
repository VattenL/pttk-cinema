<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Saler4, model.Invoice4" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><title>Chuyển khoản</title>
<style>
@import url("https://fonts.googleapis.com/css2?family=Big+Shoulders+Display:wght@700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap");
:root { --paper: #f3f4f8; --card: #ffffff; --ink: #191b28; --muted: #646a82; --line: #dfe2ec; --velvet: #9b1d3f; --velvet-dark: #7a1430; --velvet-soft: #f6e7ec; --bulb: #f5b83d; --house: #161724; --ok: #1e7a4b; --err: #b3261e; --off: #e6e7ee; --off-text: #9a9db0; --radius: 10px; --display: "Big Shoulders Display", "Arial Narrow", sans-serif; --body: "Be Vietnam Pro", "Segoe UI", Arial, sans-serif; }
* { box-sizing: border-box; }
html { background: var(--paper); }
body { max-width: 640px; margin: 32px auto; padding: 0 16px; font: 15px/1.5 var(--body); color: var(--ink); background: var(--paper); font-variant-numeric: tabular-nums; }
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
:focus-visible { outline: 3px solid var(--bulb); outline-offset: 2px; }
.msg { margin: 12px 0 0; padding: 10px 14px; border-radius: 8px; font-size: 14px; color: var(--err); background: #fbeceb; }
.msg.ok { color: var(--ok); background: #e8f4ee; }
.msg.wait { color: var(--muted); background: var(--paper); }
.msg:empty { display: none; }
#lblFinalAmount { font: 800 26px/1 var(--display); color: var(--velvet); letter-spacing: .02em; }
.qr { text-align: center; margin: 8px 0 18px; }
.qr img { padding: 10px; background: #fff; border: 1.5px solid var(--line); border-radius: 12px; }
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
  <h1>Chuyển khoản</h1>
  <c:set var="invoice" value="${sessionScope.invoice}"/>
  <div class="info"><span>Nhân viên:</span><span id="lblSalerName"><c:out value="${sessionScope.saler.fullName}"/></span></div>
  <div class="qr"><img id="imgQrCode" src="${sessionScope.imgQrCode}" alt="Mã QR chuyển khoản" width="240" height="240"></div>
  <div class="info">
    <span>Số tiền:</span><span id="lblFinalAmount"><fmt:formatNumber value="${invoice.finalAmount}" pattern="#,##0"/> đ</span>
    <span>Nội dung:</span><span id="lblTransferContent">(điền sẵn trong mã QR)</span>
  </div>
  <p class="msg wait" id="lblStatus">Đang chờ khách quét mã và chuyển khoản. Hoá đơn được lưu khi tiền về.</p>
  <form method="post" action="${pageContext.request.contextPath}/sellTicket">
    <input type="hidden" name="action" value="cancelTransfer">
    <div class="actions"><button class="btn sec" type="submit" id="btnCancel">Huỷ giao dịch</button></div>
  </form>
  <form name="confirmTransfer" method="post" action="${pageContext.request.contextPath}/sellTicket">
    <input type="hidden" name="action" value="confirmTransfer">
  </form>
</div>
<script>
  // Giả lập ngân hàng: sau 5 giây coi như đã nhận tiền rồi gửi xác nhận
  setTimeout(function () {
    var status = document.getElementById('lblStatus');
    status.textContent = 'Đã nhận chuyển khoản.';
    status.className = 'msg ok';
    setTimeout(function () { document.forms['confirmTransfer'].submit(); }, 1500);
  }, 5000);
</script>
</body>
</html>
