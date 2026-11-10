-- Du lieu mau trung voi kich ban: phim PH001 Spider-Man, suat SC0082 19:30 08/09/2026 phong P01,
-- ghe G07, G08 (VIP 105.000 d), the HV0000123 hang Vang cua Nguyen Van A (KH0001234),
-- hoa don ke tiep HD0005678, ve ke tiep VE0012345. Them cac suat chieu ngay hom nay de chay thu.
-- Mat khau mau cua moi tai khoan: 123456 (luu SHA-256).
-- Trang thai: ghe Con dung duoc / Dang hong / Dang bao tri; the Dang dung / Het han / Bi khoa;
-- hoa don Da thanh toan / Da huy (chi luu khi da tra tien); ve Da ban / Da huy / Da su dung.
-- Chay sau db/schema.sql: mysql -ucinema4 -pcinema4 cinema4 < db/seed.sql

SET NAMES utf8mb4;

-- ===== Thanh vien: quan ly, nhan vien ban ve, khach hang =====
INSERT INTO tblMember4 (id, username, password, fullName, dateOfBirth, gender, email, phone) VALUES
  (1, 'quanly.c', SHA2('123456', 256), 'Lê Văn C', '1985-03-12', 'Nam', 'levanc@cinema4.vn', '0901000001'),
  (2, 'banve.b', SHA2('123456', 256), 'Trần Thị B', '1998-07-21', 'Nữ', 'tranthib@cinema4.vn', '0901000002'),
  (3, 'nguyenvana', SHA2('123456', 256), 'Nguyễn Văn A', '2000-05-15', 'Nam', 'nguyenvana@gmail.com', '0912345678');

INSERT INTO tblEmployee4 (memberId, employeeCode, hireDate) VALUES
  (1, 'NV0001', '2020-01-02'),
  (2, 'NV0002', '2023-06-01');
INSERT INTO tblManagementStaff4 (memberId) VALUES (1);
INSERT INTO tblSaler4 (memberId, counter) VALUES (2, 'Quầy số 2');
INSERT INTO tblCustomer4 (memberId, customerCode, registerDate) VALUES (3, 'KH0001234', '2025-12-20');
INSERT INTO tblMembershipCard4 (cardCode, issueDate, expiryDate, cardTier, status, customerId) VALUES
  ('HV0000123', '2026-01-10', '2027-01-10', 'Vàng', 'Đang dùng', 3);
-- Khach dang ky moi nhan ma KH + id 7 chu so: KH0001235 tro di
ALTER TABLE tblMember4 AUTO_INCREMENT = 1235;

-- ===== Rap, phong, ghe =====
INSERT INTO tblTheater4 (id, theaterCode, name, address, phone, description) VALUES
  (1, 'RAP01', 'Rạp Cinema4 Hà Đông', '96A Trần Phú, Hà Đông, Hà Nội', '02433000004', NULL);
INSERT INTO tblScreeningRoom4 (id, roomCode, name, roomType, description, theaterId) VALUES
  (1, 'P01', 'Phòng 01', '2D', NULL, 1),
  (2, 'P02', 'Phòng 02', '2D', NULL, 1),
  (3, 'P03', 'Phòng 03', 'IMAX', NULL, 1);

-- P01: hang A-H x 10 ghe (A-E thuong, F-G VIP, H doi); P02: A-F x 10; P03: A-L x 10 (I-K VIP, L doi)
INSERT INTO tblSeat4 (rowLabel, seatNumber, seatType, status, screeningRoomId)
WITH RECURSIVE n AS (SELECT 1 AS k UNION ALL SELECT k + 1 FROM n WHERE k < 10),
r AS (SELECT 'A' AS lbl, 1 AS pos UNION ALL SELECT CHAR(ASCII(lbl) + 1), pos + 1 FROM r WHERE pos < 12)
SELECT r.lbl, n.k,
  CASE
    WHEN room.id = 1 AND r.lbl IN ('F', 'G') THEN 'VIP'
    WHEN room.id = 1 AND r.lbl = 'H' THEN 'Đôi'
    WHEN room.id = 2 AND r.lbl IN ('E', 'F') THEN 'VIP'
    WHEN room.id = 3 AND r.lbl IN ('I', 'J', 'K') THEN 'VIP'
    WHEN room.id = 3 AND r.lbl = 'L' THEN 'Đôi'
    ELSE 'Thường'
  END,
  'Còn dùng được', room.id
FROM tblScreeningRoom4 room, r, n
WHERE (room.id = 1 AND r.pos <= 8) OR (room.id = 2 AND r.pos <= 6) OR (room.id = 3 AND r.pos <= 12)
ORDER BY room.id, r.pos, n.k;

-- ===== The loai, phim =====
-- Phim lay tu TMDB bang tools/seed_tmdb.py (This product uses the TMDB API but is not endorsed or certified by TMDB).
INSERT INTO tblGenre4 (id, genreCode, name, description) VALUES
  (1, 'TL01', 'Hành động', NULL),
  (2, 'TL02', 'Hoạt hình', NULL),
  (3, 'TL03', 'Tâm lý', NULL),
  (4, 'TL04', 'Tình cảm', NULL),
  (5, 'TL05', 'Kinh dị', NULL);

INSERT INTO tblMovie4 (id, movieCode, title, duration, director, mainActor, language, ageRating, releaseDate, endDate, description, poster) VALUES
  (1, 'PH001', 'Spider-Man', 133, 'Jon Watts', 'Tom Holland, Michael Keaton', 'Tiếng Anh, phụ đề Việt', 'T13', '2026-08-01', '2026-12-31', 'Tạm biệt hai franchise về thời sinh viên, Spider-Man: Homecoming sẽ lần đầu tiên đưa các khán giả đến với cuộc sống trung học của Peter Paker – siêu anh hùng Người Nhện. Liệu một cậu bé chưa trưởng thành sẽ làm thế nào để cân bằng cuộc sống bình thường và trách nhiệm của một anh hùng giải cứu thế giới. Đây cũng là lần đầu tiên, series Người Nhện có sự tham gia sản xuất của Marvel Studio và sự xuất hiện của Iron Man – Robert Downey Jr.', 'img/poster/PH001.jpg'),
  (9, 'PH009', 'Spider-Man: Du Hành Vũ Trụ Nhện', 140, 'Justin K. Thompson, Kemp Powers, Joaquim Dos Santos', 'Shameik Moore, Hailee Steinfeld', 'Tiếng Anh, phụ đề Việt', 'K', '2026-08-15', '2026-12-31', 'Miles Morales tái xuất trong phần tiếp theo của bom tấn hoạt hình từng đoạt giải Oscar - Spider-Man: Across the Spider-Verse. Sau khi gặp lại Gwen Stacy, chàng Spider-Man thân thiện đến từ Brooklyn phải du hành qua đa vũ trụ và gặp một nhóm Người Nhện chịu trách nhiệm bảo vệ các thế giới song song. Nhưng khi nhóm siêu anh hùng xung đột về cách xử lý một mối đe dọa mới, Miles buộc phải đọ sức với các Người Nhện khác và phải xác định lại ý nghĩa của việc trở thành một người hùng để có thể cứu những người cậu yêu thương nhất.', 'img/poster/PH009.jpg'),
  (14, 'PH014', 'Bố Già', 128, 'Trấn Thành, Vũ Ngọc Đãng', 'Trấn Thành, Tuấn Trần', 'Tiếng Việt', 'K', '2026-08-20', '2026-12-31', 'Trong phim, Trấn Thành vào vai ông Tư – một tài xế xe ôm quần quật làm việc qua ngày để chăm lo cho gia đình của mình. Mặc dù khá bảo thủ, nóng nảy, thường xuyên quát tháo nhưng thực chất ông Tư lại là một người rất giàu lòng yêu thương – không chỉ với người thân mà còn có hàng xóm, bạn bè xung quanh và thậm chí là cả những người xa lạ.', 'img/poster/PH014.jpg'),
  (20, 'PH020', 'Ngôi Nhà Ma Ám', 112, 'James Wan', 'Vera Farmiga, Patrick Wilson', 'Tiếng Anh, phụ đề Việt', 'T18', '2026-06-01', '2026-07-31', 'Ed và Lorraine Warren, là những nhà điều tra các hiện tượng siêu nhiên xảy ra trên nước Mỹ. Những báo cáo của họ còn truyền cảm hứng cho cuốn tiểu thuyết Amityville Horror. Trong phim hai vợ chồng Warren là những người điều tra các hiện tượng siêu nhiên, họ đến để hỗ trợ gia đình Perron đang trải qua các sự kiện ngày càng đáng lo ngại trong trang trại của họ ở Harrisville, Rhode Island vào năm 1971.', 'img/poster/PH020.jpg'),
  (21, 'PH021', 'Godzilla Trừ Không', 135, 'Takashi Yamazaki', 'Kamiki Ryunosuke, Hamabe Minami', 'Tiếng Nhật, phụ đề Việt', 'T18', '2026-11-06', '2026-12-31', 'War reduced Japan to zero, and Godzilla plunged it into minus. Two years have passed since then, and the country has faced agonizing struggles to achieve recovery and finally reclaim its daily life. Just as humanity managed to cling to a hard-won peace, a new threat strikes, crushing hope in an instant. There is no third time. Everything ends here.', 'https://image.tmdb.org/t/p/w342/okxuQ9YDNiW6cAVOvDaco2J9y6A.jpg'),
  (22, 'PH022', 'Verity: Bí Mật Bị Chôn Vùi', 117, 'Michael Showalter', 'Dakota Johnson, Anne Hathaway', 'Tiếng Anh, phụ đề Việt', 'T18', '2026-10-02', '2026-12-31', 'Lowen Ashleigh được Jeremy Crawford thuê để viết tiếp các tiểu thuyết dang dở cho vợ anh là Verity, một nữ nhà văn nổi tiếng không còn khả năng hoàn thành công việc sau tai nạn. Trong thời gian sống tại nhà Crawford để làm việc, Lowen dần phát hiện những bí mật rùng rợn xoay quanh Verity.', 'https://image.tmdb.org/t/p/w342/54MwktkK2i2GJM8fYU9jNXGaHk.jpg'),
  (23, 'PH023', 'Ramayana: Khởi Nguồn Một Huyền Thoại', 201, 'Nitesh Tiwari', 'रणबीर कपूर, Yash', 'Tiếng Hindi, phụ đề Việt', 'T13', '2026-11-06', '2026-12-31', 'Dựa trên sử thi cổ đại lừng danh được hàng tỷ người biết đến, tác phẩm Ramayana: Khởi Nguồn Một Huyền Thoại của Namit Malhotra kể về câu chuyện của Rama, một vị hoàng tử gắn liền với sự hy sinh và Ravana, một vị vua bất tử bị thôi thúc bởi lòng báo thù; cùng lời tiên tri đã gắn kết số phận của họ lại với nhau.', 'https://image.tmdb.org/t/p/w342/dI0jgiSu7yy26tUGi7P1fxRpRIz.jpg'),
  (24, 'PH024', 'Clayface', 109, 'James Watkins', 'Tom Rhys Harries, Naomi Ackie', 'Tiếng Anh, phụ đề Việt', 'T18', '2026-10-30', '2026-12-31', 'Bộ phim theo chân hành trình sa ngã kinh hoàng của một diễn viên triển vọng ở Hollywood khi anh dần biến thành một quái vật bị thôi thúc bởi lòng thù hận, qua đó phơi bày sự đánh mất bản ngã và nhân tính, những tàn phá của tình yêu độc hại và mặt tối của tham vọng khoa học.', 'https://image.tmdb.org/t/p/w342/vyQJ8ER4DYKVrCeraQ1VGQf7Olt.jpg'),
  (25, 'PH025', 'Người Mẹ Khác', 93, 'Rob Savage', 'Jessica Chastain, Jay Duplass', 'Tiếng Anh, phụ đề Việt', 'T18', '2026-10-09', '2026-12-31', 'Một cô bé cùng gia đình và ngôi nhà của mình bị ám bởi một thực thể tà ác, kẻ quyết tâm chiếm lấy thân xác cô để trú ngụ vĩnh viễn. Nhưng trước hết, nó cần thuyết phục cô bé tự nguyện mở cửa — và cho phép nó bước vào.', 'https://image.tmdb.org/t/p/w342/nZYi7HeXJVfJmZ0kprb1cJBHN2g.jpg'),
  (26, 'PH026', 'Phim Street Fighter', 120, 'Kitao Sakurai', 'Andrew Koji, Noah Centineo', 'Tiếng Anh, phụ đề Việt', 'T13', '2026-10-16', '2026-12-31', 'Lấy bối cảnh năm 1993, Ryu và Ken, hai đấu sĩ từng xa cách bị kéo trở lại chiến đấu khi Chun-Li chiêu mộ họ tham gia giải Chiến Binh Thế Giới đầy khốc liệt. Nhưng đằng sau đó là một âm mưu chết chóc, buộc họ phải đối đầu với nhau và quá khứ của chính mình, nếu không tất cả sẽ CHẤM HẾT! Dưới sự chỉ đạo của đạo diễn Kitao Sakurai, Street Fighter mang những trận chiến game thùng lên màn ảnh rộng với các đòn thế quen thuộc cùng dàn nhân vật được yêu thích.', 'https://image.tmdb.org/t/p/w342/lnaGK9y2Dw1cwRz8e7X5plvYVdI.jpg'),
  (27, 'PH027', 'Cá Voi Nuốt Chửng', 106, 'Brian Duffield', 'Austin Abrams, Josh Brolin', 'Tiếng Anh, phụ đề Việt', 'T13', '2026-10-16', '2026-12-31', 'Một thợ lặn biển đang tìm kiếm hài cốt của người cha quá cố thì bị một con cá nhà táng dài 80 foot, nặng 60 tấn nuốt chửng, và chỉ còn 1 giờ để thoát ra trước khi cạn oxy. Sau khi gần như buông xuôi mạng sống, chàng trai trẻ bất ngờ tìm lại được lý do để tiếp tục sống ở nơi nguy hiểm và không tưởng nhất.', 'https://image.tmdb.org/t/p/w342/t644ur9Yj3ypD2r4y82c5GssPj3.jpg'),
  (28, 'PH028', 'Phán Xét Sự Thật', 113, 'Aaron Sorkin', 'Mikey Madison, Jeremy Allen White', 'Tiếng Anh, phụ đề Việt', 'T18', '2026-10-09', '2026-12-31', 'Frances Haugen, a young Facebook engineer, enlists the help of Jeff Horwitz, a Wall Street Journal reporter, to go on a dangerous journey that ends up blowing the whistle on the social network''s most guarded secrets.', 'https://image.tmdb.org/t/p/w342/yPFKOAqUs6AxhLNT1igcBULvWLq.jpg'),
  (29, 'PH029', 'Shaun the Sheep: "Quái Lạ" Ghé Nhà', 81, 'Steve Cox, Matthew Walker', 'Justin Fletcher, John Sparkes', 'Tiếng Anh, phụ đề Việt', 'K', '2026-10-10', '2026-12-31', 'Những chú cừu thông minh đã sẵn sàng cho một ngày bình thường… cho đến khi một vị khách không-mấy-bình-thường xuất hiện.', 'https://image.tmdb.org/t/p/w342/4XDUPhEjxLRyCUU5uB4XgE6kOBE.jpg'),
  (30, 'PH030', 'Chuyện Nàng Công Chúa Kaguya', 137, 'Takahata Isao', 'Kora Kengo, Takahata Atsuko', 'Tiếng Nhật, phụ đề Việt', 'K', '2026-10-09', '2026-12-31', 'Câu chuyện bắt đầu khi một ông lão đốn tre (do Takeo Chii lồng tiếng) tìm thấy một cô bé tí hon lấp lánh bên trong một thân cây tre phát sáng. Tin rằng đây là một món quà từ trời, ông và vợ (do Nobuko Miyamoto lồng tiếng) quyết định nuôi dưỡng cô bé, đặt tên là Kaguya. Kaguya lớn lên nhanh chóng một cách phi thường, trở thành một thiếu nữ xinh đẹp tuyệt trần với vẻ duyên dáng tự nhiên.', 'https://image.tmdb.org/t/p/w342/5EM4TE9wlLfvA9yQaQZdKR5RwrR.jpg'),
  (31, 'PH031', 'Đơn Hàng Ma Ám', 98, 'Dinna Jasanti', 'Fatih Unru, Yasamin Jasem', 'Tiếng Indonesia, phụ đề Việt', 'K', '2026-11-06', '2026-12-31', 'Khi nhận hàng online trở thành án tử! Một nhóm sinh viên nhận được những kiện hàng bí ẩn không rõ nguồn gốc. Sự tò mò thôi thúc họ mở từng kiện hàng, nhưng cũng chính là lúc cơn ác mộng bắt đầu… Những cái chết kỳ dị liên tiếp xảy ra: thi thể bị đàn ong vây kín, tai nạn quái dị và sự mất kiểm soát tâm trí. Giữa vòng xoáy nghi kỵ, họ bàng hoàng nhận ra sự thật lạnh sống lưng: Mỗi lần nhận hàng đều có thể dẫn đến cái chết. Lời nguyền này đến từ đâu, ai là kẻ chủ mưu giật dây cho cuộc tàn sát đẫm máu? Một cuộc đua sinh tồn nghẹt thở, nơi lòng tin vỡ vụn và cái chết chực chờ sau mỗi lần mở đơn hàng online.', 'https://image.tmdb.org/t/p/w342/5XQyttCSqAYnTXrZR48XFnYO2qo.jpg'),
  (32, 'PH032', 'Always Lalisa', 100, 'Sue Kim', 'ลิซ่า', 'Tiếng Anh, phụ đề Việt', 'K', '2026-10-12', '2026-12-31', 'Đằng sau ánh hào quang của một siêu sao toàn cầu là hành trình đi tìm chính mình.  Always Lalisa đưa khán giả bước vào một năm đặc biệt trong cuộc đời LISA – khi cô tạm rời Blackpink để lần đầu tiên thực sự bước đi trên con đường solo, đối diện với những câu hỏi chưa từng có lời giải: Nếu không có Blackpink, LISA là ai? Và cô muốn trở thành ai?  Từ những khoảnh khắc trong phòng thu khi cô tạo nên album solo đầu tay Alter Ego, đến bước ngoặt diễn xuất trong The White Lotus và màn trình diễn solo tại Coachella 2025, bộ phim hé lộ hành trình phía sau những sân khấu rực rỡ – nơi LISA phải đối mặt với áp lực, sự kỳ vọng và ánh nhìn không ngừng của thế giới.  Sinh ra tại Thái Lan, rời quê nhà từ năm 14 tuổi để theo đuổi giấc mơ K-pop tại Hàn Quốc, LISA đã đi một chặng đường dài để trở thành biểu tượng toàn cầu. Nhưng khi tự mình bước ra khỏi vùng an toàn, cô phải học cách viết lại câu chuyện của chính mình – bằng âm nhạc, bằng những lựa chọn táo bạo và bằng chính con người thật của mình.', 'https://image.tmdb.org/t/p/w342/o2s3QoaBQCbGQd72d7dgLbuJE0z.jpg');

INSERT INTO tblMovieGenre4 (movieId, genreId) VALUES (1, 1), (9, 2), (14, 3), (14, 4), (20, 5), (21, 5), (21, 1), (23, 1), (24, 5), (25, 5), (26, 1), (28, 3), (29, 2), (30, 2), (30, 3), (31, 5);

-- ===== Suat chieu: ba suat cua kich ban (08/09/2026, thu Ba) va cac suat hom nay =====
INSERT INTO tblShowtime4 (showtimeCode, showDate, startTime, endTime, format, status, movieId, screeningRoomId, managementStaffId) VALUES
  ('SC0071', '2026-09-08', '14:00', '16:30', '2D', 'Đã lên lịch', 1, 1, 1),
  ('SC0082', '2026-09-08', '19:30', '22:00', '2D', 'Đã lên lịch', 1, 1, 1),
  ('SC0083', '2026-09-08', '21:45', '00:20', 'IMAX', 'Đã lên lịch', 1, 3, 1),
  ('SC0084', '2026-09-08', '17:00', '19:35', '2D', 'Đã lên lịch', 9, 2, 1),
  ('SC0101', CURDATE(), '10:00', '12:30', '2D', 'Đã lên lịch', 1, 1, 1),
  ('SC0102', CURDATE(), '19:30', '22:00', '2D', 'Đã lên lịch', 1, 1, 1),
  ('SC0103', CURDATE(), '21:45', '00:20', 'IMAX', 'Đã lên lịch', 1, 3, 1),
  ('SC0104', CURDATE(), '15:00', '17:35', '2D', 'Đã lên lịch', 9, 2, 1),
  ('SC0105', CURDATE(), '20:00', '22:25', '2D', 'Đã lên lịch', 14, 2, 1);

-- ===== Suat chieu cua phim them tu TMDB (tools/seed_tmdb.py) =====
INSERT INTO tblShowtime4 (showtimeCode, showDate, startTime, endTime, format, status, movieId, screeningRoomId, managementStaffId) VALUES
  ('SC0201', CURDATE(), '09:00', '11:30', '2D', 'Đã lên lịch', 21, 2, 1),
  ('SC0202', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:00', '11:30', '2D', 'Đã lên lịch', 21, 1, 1),
  ('SC0203', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:00', '11:15', '2D', 'Đã lên lịch', 22, 2, 1),
  ('SC0204', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00', '11:15', '2D', 'Đã lên lịch', 22, 2, 1),
  ('SC0205', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00', '12:40', 'IMAX', 'Đã lên lịch', 23, 3, 1),
  ('SC0206', CURDATE(), '09:00', '12:40', 'IMAX', 'Đã lên lịch', 23, 3, 1),
  ('SC0207', CURDATE(), '11:30', '13:35', '2D', 'Đã lên lịch', 24, 2, 1),
  ('SC0208', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:00', '11:05', 'IMAX', 'Đã lên lịch', 24, 3, 1),
  ('SC0209', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:15', '13:05', '2D', 'Đã lên lịch', 25, 2, 1),
  ('SC0210', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00', '10:50', '2D', 'Đã lên lịch', 25, 1, 1),
  ('SC0211', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '11:00', '13:15', '2D', 'Đã lên lịch', 26, 1, 1),
  ('SC0212', CURDATE(), '12:30', '14:45', '2D', 'Đã lên lịch', 26, 1, 1),
  ('SC0213', CURDATE(), '12:45', '14:50', 'IMAX', 'Đã lên lịch', 27, 3, 1),
  ('SC0214', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:15', '13:20', 'IMAX', 'Đã lên lịch', 27, 3, 1),
  ('SC0215', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:30', '13:40', '2D', 'Đã lên lịch', 28, 1, 1),
  ('SC0216', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '11:15', '13:25', '2D', 'Đã lên lịch', 28, 2, 1),
  ('SC0217', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '12:45', '14:25', 'IMAX', 'Đã lên lịch', 29, 3, 1),
  ('SC0218', CURDATE(), '14:45', '16:25', '2D', 'Đã lên lịch', 29, 1, 1),
  ('SC0219', CURDATE(), '15:00', '17:35', 'IMAX', 'Đã lên lịch', 30, 3, 1),
  ('SC0220', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '13:15', '15:50', '2D', 'Đã lên lịch', 30, 2, 1),
  ('SC0221', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '13:30', '15:25', 'IMAX', 'Đã lên lịch', 31, 3, 1),
  ('SC0222', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '13:15', '15:10', '2D', 'Đã lên lịch', 31, 1, 1),
  ('SC0223', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '13:30', '15:25', '2D', 'Đã lên lịch', 32, 2, 1),
  ('SC0224', CURDATE(), '16:30', '18:25', '2D', 'Đã lên lịch', 32, 1, 1);

-- ===== Bang gia: theo loai ghe, dinh dang, loai ngay; mot dong cu da ngung =====
INSERT INTO tblTicketPrice4 (priceCode, seatType, format, dayType, amount, effectiveFrom, effectiveTo, status) VALUES
  ('GV2D-NT-T-25', 'Thường', '2D', 'Ngày thường', 80000, '2025-01-01', '2025-12-31', 'Ngưng'),
  ('GV2D-NT-T', 'Thường', '2D', 'Ngày thường', 85000, '2026-01-01', NULL, 'Áp dụng'),
  ('GV2D-NT-V', 'VIP', '2D', 'Ngày thường', 105000, '2026-01-01', NULL, 'Áp dụng'),
  ('GV2D-NT-D', 'Đôi', '2D', 'Ngày thường', 135000, '2026-01-01', NULL, 'Áp dụng'),
  ('GV2D-CT-T', 'Thường', '2D', 'Cuối tuần', 95000, '2026-01-01', NULL, 'Áp dụng'),
  ('GV2D-CT-V', 'VIP', '2D', 'Cuối tuần', 115000, '2026-01-01', NULL, 'Áp dụng'),
  ('GV2D-CT-D', 'Đôi', '2D', 'Cuối tuần', 145000, '2026-01-01', NULL, 'Áp dụng'),
  ('GVIM-NT-T', 'Thường', 'IMAX', 'Ngày thường', 110000, '2026-01-01', NULL, 'Áp dụng'),
  ('GVIM-NT-V', 'VIP', 'IMAX', 'Ngày thường', 130000, '2026-01-01', NULL, 'Áp dụng'),
  ('GVIM-NT-D', 'Đôi', 'IMAX', 'Ngày thường', 160000, '2026-01-01', NULL, 'Áp dụng'),
  ('GVIM-CT-T', 'Thường', 'IMAX', 'Cuối tuần', 120000, '2026-01-01', NULL, 'Áp dụng'),
  ('GVIM-CT-V', 'VIP', 'IMAX', 'Cuối tuần', 140000, '2026-01-01', NULL, 'Áp dụng'),
  ('GVIM-CT-D', 'Đôi', 'IMAX', 'Cuối tuần', 170000, '2026-01-01', NULL, 'Áp dụng');

-- ===== Hoa don va ve da ban =====
-- HD0005600: 34 ve cua SC0082 (hang A-C va D4, D5, D6, E7), con 46/80 ghe trong nhu kich ban
-- HD0005601: khach Nguyen Van A mua 2 ve SC0071 (E1, E2), giam 10%, sinh 15 diem
-- HD0005602: 20 ve suat SC0102 hom nay (hang A-B)
INSERT INTO tblInvoice4 (id, invoiceCode, createdDate, discount, paymentMethod, status, salerId, customerId) VALUES
  (5600, 'HD0005600', '2026-09-08 18:05:00', 0, 'Tiền mặt', 'Đã thanh toán', 2, NULL),
  (5601, 'HD0005601', '2026-09-08 13:40:00', 17000, 'Chuyển khoản', 'Đã thanh toán', 2, 3),
  (5602, 'HD0005602', CONCAT(CURDATE(), ' 09:00:00'), 0, 'Tiền mặt', 'Đã thanh toán', 2, NULL);

INSERT INTO tblTicket4 (ticketCode, status, invoiceId, showtimeId, seatId, ticketPriceId)
SELECT CONCAT('T', st.id, '-', s.id), 'Đã bán', 5600, st.id, s.id, p.id
FROM tblShowtime4 st
JOIN tblSeat4 s ON s.screeningRoomId = st.screeningRoomId
JOIN tblTicketPrice4 p ON p.priceCode = 'GV2D-NT-T'
WHERE st.showtimeCode = 'SC0082'
  AND (s.rowLabel IN ('A', 'B', 'C') OR (s.rowLabel = 'D' AND s.seatNumber IN (4, 5, 6)) OR (s.rowLabel = 'E' AND s.seatNumber = 7))
ORDER BY s.id;

INSERT INTO tblTicket4 (ticketCode, status, invoiceId, showtimeId, seatId, ticketPriceId)
SELECT CONCAT('T', st.id, '-', s.id), 'Đã bán', 5601, st.id, s.id, p.id
FROM tblShowtime4 st
JOIN tblSeat4 s ON s.screeningRoomId = st.screeningRoomId
JOIN tblTicketPrice4 p ON p.priceCode = 'GV2D-NT-T'
WHERE st.showtimeCode = 'SC0071' AND s.rowLabel = 'E' AND s.seatNumber IN (1, 2)
ORDER BY s.id;

INSERT INTO tblTicket4 (ticketCode, status, invoiceId, showtimeId, seatId, ticketPriceId)
SELECT CONCAT('T', st.id, '-', s.id), 'Đã bán', 5602, st.id, s.id,
  (SELECT p.id FROM tblTicketPrice4 p
   WHERE p.seatType = s.seatType AND p.format = st.format AND p.status = 'Áp dụng'
     AND p.dayType = IF(DAYOFWEEK(st.showDate) IN (1, 7), 'Cuối tuần', 'Ngày thường'))
FROM tblShowtime4 st
JOIN tblSeat4 s ON s.screeningRoomId = st.screeningRoomId
WHERE st.showtimeCode = 'SC0102' AND s.rowLabel IN ('A', 'B')
ORDER BY s.id;

UPDATE tblTicket4 SET ticketCode = CONCAT('VE', LPAD(id, 7, '0'));

-- Ma ke tiep dung nhu kich ban: hoa don HD0005678, ve VE0012345
ALTER TABLE tblInvoice4 AUTO_INCREMENT = 5678;
ALTER TABLE tblTicket4 AUTO_INCREMENT = 12345;
