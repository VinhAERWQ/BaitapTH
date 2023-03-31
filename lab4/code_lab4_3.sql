--1.--:Thống kê số loại sản phẩm của mỗi hãng sản xuất:
create view tksp_hangsx as 
SELECT Hangsx.mahangsx, Hangsx.tenhang, COUNT(Sanpham.masp) AS SoLoaiSanPham
FROM Hangsx
LEFT JOIN Sanpham ON Hangsx.mahangsx = Sanpham.mahangsx
GROUP BY Hangsx.mahangsx, Hangsx.tenhang;
GROUP BY Hangsx.mahangsx, Hangsx.tenhang;

--2.--:Thống kê tổng tiền nhập của mỗi sản phẩm trong năm 2018:

create view tkttnhap_sanpham as 
SELECT Sanpham.masp, Sanpham.tensp, SUM(Nhap.soluongN * Nhap.dongiaN) AS TongTienNhap
FROM Sanpham
INNER JOIN Nhap ON Sanpham.masp = Nhap.masp
WHERE YEAR(Nhap.ngaynhap) = 2018
GROUP BY Sanpham.masp, Sanpham.tensp;

--3.--:Thống kê các sản phẩm có tổng số lượng xuất năm 2018 là lớn hơn 10.000 sản phẩm của hãng Samsung:

create view tksp_slxuat as 
SELECT Sanpham.masp, Sanpham.tensp, SUM(Xuat.soluongX) AS TongSoLuongXuat
FROM Sanpham
INNER JOIN Xuat ON Sanpham.masp = Xuat.masp
WHERE YEAR(Xuat.ngayxuat) = 2018 AND Sanpham.mahangsx = 'SAMSUNG' 
GROUP BY Sanpham.masp, Sanpham.tensp
HAVING SUM(Xuat.soluongX) > 10000;

--4.--:Thống kê số lượng nhân viên nam của mỗi phòng ban:

create view tk_slgnvnam as 
SELECT Nhanvien.phong, COUNT(*) AS SoLuongNhanVienNam
FROM Nhanvien
WHERE Nhanvien.gioitinh = N'Nam'
GROUP BY Nhanvien.phong;

--5.--: Thống kê tổng số lượng nhập của mỗi hãng sản xuất trong năm 2018.

create view soluongnhap_hangsx as 
SELECT Hangsx.tenhang, SUM(Nhap.soluongN) AS TongSoLuongNhap
FROM Hangsx
INNER JOIN Sanpham ON Hangsx.mahangsx = Sanpham.mahangsx
INNER JOIN Nhap ON Sanpham.masp = Nhap.masp
WHERE YEAR(Nhap.ngaynhap) = 2018
GROUP BY Hangsx.tenhang

