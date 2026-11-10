# Cinema4: Hệ thống quản lý rạp chiếu phim

Mã nguồn bài tập lớn môn Phân tích thiết kế hệ thống (đề 14, mã sinh viên B23DCDT044). Ứng dụng web cài đặt hai modul của hệ thống quản lý chuỗi rạp chiếu phim:

- **Đăng ký hội viên** (`Register Member 4`): khách nhập thông tin cá nhân và tài khoản, hệ thống kiểm tra hợp lệ, kiểm tra trùng, lưu rồi đưa khách về trang chủ ở trạng thái đã đăng nhập.
- **Bán vé tại quầy** (`Sell Ticket At Counter 4`): nhân viên bán vé tìm phim theo tên và ngày chiếu, chọn phim, chọn suất, chọn ghế trên sơ đồ, nhập mã thẻ hội viên (nếu có) để được giảm giá, thanh toán bằng tiền mặt hoặc chuyển khoản (mã VietQR), rồi in vé và hoá đơn.

Các chức năng khác của hệ thống (tìm phim và mua vé online cho khách, cấp thẻ hội viên, thống kê...) chưa cài đặt và hiện là nút bị khoá trên giao diện.

## Công nghệ

- Java 17, Servlet 3.1, JSP 2.3 + JSTL 1.2, chạy trên Apache Tomcat 8.5
- MySQL 8, JDBC (`mysql-connector-j`), không dùng framework
- ZXing để sinh mã QR chuyển khoản
- Maven (đóng gói WAR), JUnit 4

## Kiến trúc

J2EE Model 2 MVC + DAO, bốn tầng, mỗi tầng một gói, phụ thuộc một chiều từ trên xuống:

```
view (JSP) -> controller (Servlet) -> dao (JDBC) -> model (POJO)
```

- `view`: trang JSP chỉ hiển thị (EL + JSTL, không có scriptlet), chia thư mục con theo actor. JSP không gọi DAO.
- `controller`: mỗi modul một Servlet, mỗi bước của kịch bản một phương thức xử lý. GET chỉ đọc, POST thay đổi dữ liệu. Dữ liệu giữa các bước giữ trong `HttpSession`.
- `dao`: lớp trừu tượng `DAO4` giữ kết nối dùng chung, mỗi lớp thực thể một DAO chứa toàn bộ nghiệp vụ truy xuất.
- `model`: lớp thực thể chỉ có thuộc tính và get/set.

Mọi trang JSP chỉ mở được qua Servlet: `web.xml` chặn yêu cầu mở thẳng địa chỉ `*.jsp`.

## Cấu trúc thư mục

```
cinema4/
├── db/
│   ├── create-db.sql        tạo CSDL và tài khoản MySQL (chạy một lần bằng root)
│   ├── schema.sql           tạo bảng
│   └── seed.sql             dữ liệu mẫu
├── pom.xml
└── src/
    ├── main/
    │   ├── config/web.xml
    │   ├── java/
    │   │   ├── controller/  HomeServlet4, RegisterMemberServlet4, LoginServlet4, SellTicketServlet4
    │   │   ├── dao/         DAO4 và 9 lớp DAO
    │   │   └── model/       13 lớp thực thể
    │   ├── resources/db.properties
    │   └── view/
    │       ├── customer/    home4.jsp, registerMember4.jsp
    │       ├── member/      login4.jsp
    │       ├── saler/       7 trang bán vé, từ salerHome4.jsp tới printTicket4.jsp
    │       └── img/poster/
    └── test/java/unittest/  test các phương thức DAO trên dữ liệu mẫu
```

## Cài đặt và chạy

Cần JDK 17, Maven, MySQL 8 và Tomcat 8.5.

1. Tạo CSDL và tài khoản `cinema4` (mật khẩu `cinema4`), chạy bằng tài khoản root của MySQL:

   ```bash
   mysql -uroot -p < cinema4/db/create-db.sql
   ```

2. Tạo bảng và nạp dữ liệu mẫu (chạy lại bất cứ lúc nào để đưa CSDL về trạng thái ban đầu):

   ```bash
   cd cinema4/db
   mysql -ucinema4 -pcinema4 --default-character-set=utf8mb4 cinema4 -e "source schema.sql; source seed.sql;"
   ```

3. Đóng gói. Unit test chạy trên CSDL mẫu nên cần làm bước 2 trước; muốn bỏ qua test thì thêm `-DskipTests`:

   ```bash
   cd cinema4
   mvn clean package
   ```

4. Chép `target/cinema4.war` vào thư mục `webapps` của Tomcat, khởi động Tomcat rồi mở `http://localhost:8080/cinema4/`.

Thông tin kết nối CSDL nằm trong `src/main/resources/db.properties`; sửa file này nếu MySQL không chạy ở `localhost:3306`.

## Dữ liệu mẫu

| Vai trò | Tên đăng nhập | Mật khẩu |
|---|---|---|
| Nhân viên bán vé (Trần Thị B, quầy số 2) | `banve.b` | `123456` |
| Nhân viên quản lý | `quanly.c` | `123456` |
| Khách hàng (Nguyễn Văn A) | `nguyenvana` | `123456` |

- Thẻ hội viên `HV0000123` hạng Vàng của khách Nguyễn Văn A, được giảm 10% (Bạc 5%, Vàng 10%, Kim cương 15%).
- 16 phim, 15 phim đang chiếu (`PH020` đã hết chiếu). `PH001`, `PH009`, `PH014` có suất hôm nay; 12 phim lấy từ TMDB (`PH021` tới `PH032`) mỗi phim có hai suất trong hôm nay và hai ngày tới. Ngày 08/09/2026 có các suất của kịch bản mẫu (phim `PH001`, suất `SC0082`).
- Chỉ tài khoản nhân viên bán vé đăng nhập được vào modul bán vé.

## Kiểm thử

```bash
cd cinema4
mvn test
```

13 test trên dữ liệu mẫu, gồm: kiểm tra trùng và lưu khách hàng, đăng nhập (đúng vai trò, sai mật khẩu), tìm phim theo ngày chiếu, suất chiếu và số vé đã bán, sơ đồ ghế và giá, ghế hỏng không bán được, thẻ hội viên và chủ thẻ, thanh toán tiền mặt có giảm giá, chuyển khoản (đọc lại nội dung mã QR, chỉ lưu khi tiền về), ghế bị bán ở quầy khác trong lúc chờ chuyển khoản, hai quầy cùng bán một ghế. Test tự dọn dữ liệu đã ghi.

## Ghi chú

- Thanh toán chuyển khoản chưa nối ngân hàng thật: trang chuyển khoản chờ 5 giây rồi coi như đã nhận tiền. Tài khoản nhận tiền trong mã QR là tài khoản mẫu.
- Hoá đơn và vé chỉ được lưu khi khách đã trả tiền; trước đó không giữ ghế nào trong CSDL.
- Dữ liệu phim và poster lấy từ [TMDB](https://www.themoviedb.org/). This product uses the TMDB API but is not endorsed or certified by TMDB.
