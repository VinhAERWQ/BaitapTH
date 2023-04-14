--1a--
INSERT INTO Nhanvien (manv, tennv,gioitinh, diachi, sodt, email, phong)
VALUES ('N002', 'Nguyen Van B','Nam', 'Ha Noi', '0982654321', 'nva@example.com','Vật tư')

--Thực hiện-- full backup:

BACKUP DATABASE QLBanHang TO DISK = 'C:\bk\QLBH.bak' WITH INIT
--1b--
INSERT INTO dbo.Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES ('NV06', N'Nguyen Van Tan', N'Nam', N'Ho Chi Minh', '0987654452', 'ndv@example.com', N'Thủ kho')

--Thực hiện different backup:

BACKUP DATABASE QLBanHang TO DISK = 'C:\bk\QLBH_Diff.bak' WITH DIFFERENTIAL
--1c--
INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES ('N008', N'Nguyen Kieu Trinh', N'Nu', N'Lao Cai', '0987654007', 'KieuTrinh@example.com', N'Thủ kho')

--Thực hiện log backup lần 1:

BACKUP DATABASE QLBanHang TO DISK = 'C:\bk\QLBH.trn' WITH INIT
--1d--
INSERT INTO dbo.Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES ('NV08', N'Trinh Thanh Cong', N'Nam', N'Long An', '0987654213', 'kds@example.com', N'Kế Toán')

--Thực hiện log backup lần 2:

BACKUP DATABASE QLBanHang TO DISK = 'C:\bk\QLBH.trn' WITH INIT