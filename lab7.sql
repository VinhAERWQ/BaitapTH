--1--
create procedure bh_NhapHangsx(
@mahangsx nvarchar(50),
@tenhang nvarchar(50),
@diachi nvarchar(50), 
@sodt nvarchar(50), 
@email nvarchar(50)
)

as
begin 
	if(exists(select * from Hangsx where tenhang = @tenhang))
		print 'Tên hãng không tồn tại,mời bạn nhập tên khác !!!'
	else
		insert into Hangsx values (@mahangsx,@tenhang,@diachi,@sodt,@email)
end
exec bh_NhapHangsx 'HSX01', 'Samsung', 'Hàn Quốcc', '0123456789', 'contact@samsung.com'
--2--
create procedure bh_NhapSanpham(
@masp nvarchar(50), 
@mahangsx nvarchar(50), 
@tensp nvarchar(50), 
@soluong nvarchar(50), 
@mausac nvarchar(50), 
@giaban nvarchar(50), 
@donvitinh nvarchar(50), 
@mota nvarchar(50)
)
as
begin 
	if(exists(select * from Sanpham where masp = @masp))
	begin
        update sanpham 
        set mahangsx = @mahangsx, tensp = @tensp, soluong = @soluong, mausac = @mausac, giaban = @giaban, donvitinh = @donvitinh, mota = @mota 
        where masp = @masp
        print 'Đã cập nhật thông tin sản phẩm có mã ' + @masp
	end
	else
	begin
		insert into Sanpham values (@masp,@mahangsx,@tensp,@soluong,@mausac,@giaban,@donvitinh,@mota)
		print 'Đã thêm sản phẩm có mã ' + @masp
	end
end
exec bh_NhapSanpham 'SP01', 'H02', 'F1 Plus', 100, 'Xám', 7000000, 'Chiếc', 'Hàng cận cảo cấp'
--3--
create procedure bh_DeleteHangSX
    @tenhang nvarchar(50)
as
begin
    
    if not exists (select * from Hangsx where tenhang = @tenhang)
    begin
        print 'Hãng không tồn tại trong bảng'
        return
    end

    begin transaction

    delete from Sanpham where mahangsx = (select mahangsx from Hangsx where tenhang = @tenhang)

    
    delete from Hangsx where tenhang = @tenhang

    commit transaction
end

---Câu 4---
create procedure bh_NhapNhanVien
    @manv varchar(10),
    @tennv nvarchar(50),
    @gioitinh nvarchar(3),
    @diachi nvarchar(100),
    @sodt varchar(20),
    @email nvarchar(50),
    @phong nvarchar(50),
    @flag bit
as
begin
    if @flag = 0
    begin
        update Nhanvien
        set tennv = @tennv,
            gioitinh = @gioitinh,
            diachi = @diachi,
            sodt = @sodt,
            email = @email,
            phong = @phong
        where manv = @manv;
    end
    else
    begin
        if exists (select * from Nhanvien where manv = @manv)
        begin
            raiserror('mã nhân viên đã tồn tại!', 16, 1);
            return;
        end
        insert into Nhanvien values (@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    end
end

---câu 5---

create procedure ThemNhap(@sohdn varchar(20), @masp varchar(20), @manv varchar(20), @ngaynhap date, @soluongn int, @dongian float)
as
begin
    
    if not exists(select * from Sanpham where masp = @masp)
    begin
        print 'mã sản phẩmm không tồn tại'
        return
    end
    if not exists(select * from Nhanvien where manv = @manv)
    begin
        print 'mã nhân viên không tồn tại'
        return
    end

  
    if exists(select * from Nhap where sohdn = @sohdn)
    begin
        update Nhap set masp = @masp, manv = @manv, ngaynhap = @ngaynhap, soluongn = @soluongn, dongian = @dongian
        where sohdn = @sohdn
    end
    else 
    begin
        insert into Nhap values(@sohdn, @masp, @manv, @ngaynhap, @soluongn, @dongian)
    end

   
    if exists(select * from Xuat where sohdx = @sohdn)
    begin
        update Xuat set masp = @masp, manv = @manv, ngayxuat = @ngaynhap, soluongx = @soluongn
        where sohdx = @sohdn
    end
    else 
    begin
        declare @sohdx varchar(20)
        set @sohdx = 'x' + @sohdn
        insert into Xuat(sohdx, masp, manv, ngayxuat, soluongx)
        values(@sohdx, @masp, @manv, @ngaynhap, @soluongn)
    end
end

---câu 6---
create procedure Them_Capnhat_Xuat 
(
    @sohdx int,
    @masp int,
    @manv int,
    @ngayxuat date,
    @soluongx int
)
as
begin
    
    if not exists (select * from Sanpham where masp = @masp)
    begin
        print 'mã sản phẩm không tồn tại trong bảng sanpham.'
        return
    end
    
    
    if not exists (select * from Nhanvien where manv = @manv)
    begin
        print 'mã nhân viên không tồn tại trong bảng nhanvien.'
        return
    end
    
    
    if @soluongx > (select soluong from Sanpham where masp = @masp)
    begin
        print 'số lượng xuất vật quá số lượng tônf kho.'
        return
    end
    
    
    if exists (select * from Xuat where sohdx = @sohdx)
    begin
        update Xuat 
        set masp = @masp, manv = @manv, ngayxuat = @ngayxuat, soluongx = @soluongx 
        where sohdx = @sohdx
        print 'cập nhật dữ liệu bảng xuat thành công.'
    end
    else
    begin
        insert into Xuat(sohdx, masp, manv, ngayxuat, soluongx)
        values (@sohdx, @masp, @manv, @ngayxuat, @soluongx)
        print 'thêm dữ liệu vào bảng xuat thành công.'
    end
end

---câu 7---
create procedure bh_DeleteNhanvien 
    @manv int
as
begin
    
    if not exists(select * from Nhanvien where manv = @manv)
    begin
        print 'không tìm thấy nhân viên với mã ' + cast(@manv as nvarchar)
        return
    end

   
    delete from Nhap where manv = @manv
    delete from Xuat where manv = @manv

 
    delete from Nhanvien where manv = @manv

    print 'Đã xóa nhân viên với mã ' + cast(@manv as nvarchar)
end


---câu 8---
create procedure bh_DeleteSanpham
  @masp varchar(10)
as
begin
  set nocount on;

  if not exists (select 1 from Sanpham where masp = @masp)
  begin
    print 'không tìm thấy sẩn phẩm ?? xóa!'
    return;
  end

  begin try
    begin transaction

  
    delete from Nhap where masp = @masp;

    
    delete from Xuat where masp = @masp;

   
    delete from Sanpham where masp = @masp;

    commit transaction
    print 'Đã Xóa sản phẩm ' + @masp
  end try
  begin catch
    rollback transaction
    print 'Đã xảy ra lỗi trong quá trình xóa sản phẩm!'
  end catch
end