-- CSDL he thong quan ly rap chieu phim (de 14, B23DCDT044), dung theo ERD Hinh 2 cua tai lieu thiet ke.
-- Khoa chinh dau bang, khoa ngoai cuoi bang; khong luu thuoc tinh dan xuat.
-- Chay lai duoc bang tai khoan cinema4 (CSDL va tai khoan tao mot lan bang db/create-db.sql):
--   mysql -ucinema4 -pcinema4 cinema4 < db/schema.sql

DROP TABLE IF EXISTS tblTicket4, tblInvoice4, tblTicketPrice4, tblShowtime4, tblMovieGenre4, tblMovie4,
  tblGenre4, tblSeat4, tblScreeningRoom4, tblTheater4, tblMembershipCard4, tblManagementStaff4,
  tblSaler4, tblEmployee4, tblCustomer4, tblMember4;

CREATE TABLE tblMember4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  fullName VARCHAR(100) NOT NULL,
  dateOfBirth DATE NOT NULL,
  gender VARCHAR(10) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (username),
  UNIQUE (email),
  UNIQUE (phone)
) ENGINE = InnoDB;

CREATE TABLE tblCustomer4 (
  memberId INT(10) NOT NULL,
  customerCode VARCHAR(20) NOT NULL,
  registerDate DATE NOT NULL,
  PRIMARY KEY (memberId),
  UNIQUE (customerCode),
  FOREIGN KEY (memberId) REFERENCES tblMember4 (id)
) ENGINE = InnoDB;

CREATE TABLE tblEmployee4 (
  memberId INT(10) NOT NULL,
  employeeCode VARCHAR(20) NOT NULL,
  hireDate DATE NOT NULL,
  PRIMARY KEY (memberId),
  UNIQUE (employeeCode),
  FOREIGN KEY (memberId) REFERENCES tblMember4 (id)
) ENGINE = InnoDB;

CREATE TABLE tblSaler4 (
  memberId INT(10) NOT NULL,
  counter VARCHAR(20) NOT NULL,
  PRIMARY KEY (memberId),
  FOREIGN KEY (memberId) REFERENCES tblEmployee4 (memberId)
) ENGINE = InnoDB;

CREATE TABLE tblManagementStaff4 (
  memberId INT(10) NOT NULL,
  PRIMARY KEY (memberId),
  FOREIGN KEY (memberId) REFERENCES tblEmployee4 (memberId)
) ENGINE = InnoDB;

CREATE TABLE tblMembershipCard4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  cardCode VARCHAR(20) NOT NULL,
  issueDate DATE NOT NULL,
  expiryDate DATE NOT NULL,
  cardTier VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  customerId INT(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (cardCode),
  FOREIGN KEY (customerId) REFERENCES tblCustomer4 (memberId)
) ENGINE = InnoDB;

CREATE TABLE tblTheater4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  theaterCode VARCHAR(20) NOT NULL,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  description VARCHAR(500) NULL,
  PRIMARY KEY (id),
  UNIQUE (theaterCode)
) ENGINE = InnoDB;

CREATE TABLE tblScreeningRoom4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  roomCode VARCHAR(20) NOT NULL,
  name VARCHAR(50) NOT NULL,
  roomType VARCHAR(20) NOT NULL,
  description VARCHAR(500) NULL,
  theaterId INT(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (roomCode),
  FOREIGN KEY (theaterId) REFERENCES tblTheater4 (id)
) ENGINE = InnoDB;

CREATE TABLE tblSeat4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  rowLabel VARCHAR(2) NOT NULL,
  seatNumber INT(3) NOT NULL,
  seatType VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  screeningRoomId INT(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (screeningRoomId, rowLabel, seatNumber),
  FOREIGN KEY (screeningRoomId) REFERENCES tblScreeningRoom4 (id)
) ENGINE = InnoDB;

CREATE TABLE tblGenre4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  genreCode VARCHAR(20) NOT NULL,
  name VARCHAR(50) NOT NULL,
  description VARCHAR(500) NULL,
  PRIMARY KEY (id),
  UNIQUE (genreCode)
) ENGINE = InnoDB;

CREATE TABLE tblMovie4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  movieCode VARCHAR(20) NOT NULL,
  title VARCHAR(255) NOT NULL,
  duration INT(4) NOT NULL,
  director VARCHAR(100) NOT NULL,
  mainActor VARCHAR(255) NOT NULL,
  language VARCHAR(50) NOT NULL,
  ageRating VARCHAR(10) NOT NULL,
  releaseDate DATE NOT NULL,
  endDate DATE NOT NULL,
  description VARCHAR(2000) NULL,
  poster VARCHAR(255) NULL,
  PRIMARY KEY (id),
  UNIQUE (movieCode)
) ENGINE = InnoDB;

CREATE TABLE tblMovieGenre4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  movieId INT(10) NOT NULL,
  genreId INT(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (movieId, genreId),
  FOREIGN KEY (movieId) REFERENCES tblMovie4 (id),
  FOREIGN KEY (genreId) REFERENCES tblGenre4 (id)
) ENGINE = InnoDB;

CREATE TABLE tblShowtime4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  showtimeCode VARCHAR(20) NOT NULL,
  showDate DATE NOT NULL,
  startTime TIME NOT NULL,
  endTime TIME NOT NULL,
  format VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  movieId INT(10) NOT NULL,
  screeningRoomId INT(10) NOT NULL,
  managementStaffId INT(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (showtimeCode),
  FOREIGN KEY (movieId) REFERENCES tblMovie4 (id),
  FOREIGN KEY (screeningRoomId) REFERENCES tblScreeningRoom4 (id),
  FOREIGN KEY (managementStaffId) REFERENCES tblManagementStaff4 (memberId)
) ENGINE = InnoDB;

CREATE TABLE tblTicketPrice4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  priceCode VARCHAR(20) NOT NULL,
  seatType VARCHAR(20) NOT NULL,
  format VARCHAR(20) NOT NULL,
  dayType VARCHAR(20) NOT NULL,
  amount DECIMAL(12,0) NOT NULL,
  effectiveFrom DATE NOT NULL,
  effectiveTo DATE NULL,
  status VARCHAR(20) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (priceCode)
) ENGINE = InnoDB;

CREATE TABLE tblInvoice4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  invoiceCode VARCHAR(20) NOT NULL,
  createdDate DATETIME NOT NULL,
  discount DECIMAL(12,0) NOT NULL,
  paymentMethod VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  salerId INT(10) NULL,
  customerId INT(10) NULL,
  PRIMARY KEY (id),
  UNIQUE (invoiceCode),
  FOREIGN KEY (salerId) REFERENCES tblSaler4 (memberId),
  FOREIGN KEY (customerId) REFERENCES tblCustomer4 (memberId)
) ENGINE = InnoDB;

-- (showtimeId, seatId) duy nhat tren cac ve dang chiem ghe (da ban, da su dung; ve chi duoc luu khi hoa don
-- da thanh toan, ve da huy tra ghe): MySQL khong co chi muc duy nhat co dieu kien, nen kiem tra trong
-- TicketDAO4.checkSeatAvailable() va khoa SELECT ... FOR UPDATE trong giao dich InvoiceDAO4.saveInvoice();
-- chi muc thuong duoi day phuc vu khoa do.
CREATE TABLE tblTicket4 (
  id INT(10) NOT NULL AUTO_INCREMENT,
  ticketCode VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  invoiceId INT(10) NOT NULL,
  showtimeId INT(10) NOT NULL,
  seatId INT(10) NOT NULL,
  ticketPriceId INT(10) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (ticketCode),
  INDEX idxShowtimeSeat (showtimeId, seatId),
  FOREIGN KEY (invoiceId) REFERENCES tblInvoice4 (id),
  FOREIGN KEY (showtimeId) REFERENCES tblShowtime4 (id),
  FOREIGN KEY (seatId) REFERENCES tblSeat4 (id),
  FOREIGN KEY (ticketPriceId) REFERENCES tblTicketPrice4 (id)
) ENGINE = InnoDB;
