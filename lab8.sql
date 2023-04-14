--1--
create procedure sp_themmoinhanvien
    @manv int,
    @tennv nvarchar(50),
    @gioitinh nvarchar(10),
    @diachi nvarchar(100),
    @sodt varchar(20),
    @email varchar(50),
    @phong nvarchar(50),
    @flag int
as
begin
    set nocount on;
    
   
    if @gioitinh not in ('Nam', 'Nữ')
    begin
        return 1;
    end
    
   
    if @flag = 0 
    begin
        insert into Nhanvien(manv, tennv, gioitinh, diachi, sodt, email, phong)
        values(@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    end
    else
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
    
    return 0;
end
--2--
create procedure bh_themmoisanpham 
	@masp int, 
	@tenhang varchar(50), 
	@tensp varchar(50), 
	@soluong int, 
	@mausac varchar(20), 
	@giaban float, 
	@donvitinh varchar(20), 
	@mota varchar(100), 
	@flag int
as
begin
    set nocount on;

 
    if not exists(select * from hangsx where tenhang = @tenhang)
    begin
        select 1 as 'maloi', 'không tìm thấy tên hãng sản xuất' as 'motaloi'
        return
    end

    
    if @soluong < 0
    begin
        select 2 as 'maloi', 'số lượng sản phẩm phải lớn hơn hoặc bằng 0' as 'motaloi'
        return
    end

    
    if @flag = 0
    begin
        insert into Sanpham (masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        values (@masp, (select mahangsx from hangsx where tenhang = @tenhang), @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)

        select 0 as 'maloi', 'thêm mới sản phẩm thành công' as 'motaloi'
    end
    else 
    begin
        update Sanpham
        set mahangsx = (select mahangsx from hangsx where tenhang = @tenhang), 
            tensp = @tensp, 
            soluong = @soluong, 
            mausac = @mausac, 
            giaban = @giaban, 
            donvitinh = @donvitinh, 
            mota = @mota
        where masp = @masp

        select 0 as 'maloi', 'cập nhật sản phẩm thành công' as 'motaloi'
    end
end
--3--
create procedure bh_xoanhanvien 
    @manv int
as
begin
   
    if not exists (select * from Nhanvien where manv = @manv)
    begin
        return 1;
    end

    begin transaction;

    
    delete from Nhap where manv = @manv;

    delete from Xuat where manv = @manv;

    
    delete from Nhanvien where manv = @manv;

    commit transaction; 

    return 0;
end
--4--
create procedure bh_xoasanpham
    @masp varchar(10),
    @errorcode int output
as
begin
    
    if not exists (select * from Sanpham where masp = @masp)
    begin
        set @errorcode = 1;
        return;
    end
    

    delete from Sanpham where masp = @masp;
    
    
    delete from Nhap where masp = @masp;
    delete from Xuat where masp = @masp;
    
    set @errorcode = 0;
--5--
create procedure bh_themmoiHangsx 
	@mahangsx int,
	@tenhang nvarchar(50),
    @diachi nvarchar(50),
    @sodt nvarchar(50),
    @email nvarchar(50),
as
begin
    
    if exists (select * from Hangsx where tenhang = @tenhang)
    begin
        return 1; 
    end

  
    insert into Hangsx values(@mahangsx, @tenhang, @diachi, @sodt, @email)

    return 0; 
end
--6--create procedure sp_nhapxuat_xuat
    @sohdx int,
    @masp int,
    @manv int,
    @ngayxuat date,
    @soluongx int
as
begin
    
    if not exists(select * from sanpham where masp = @masp)
    begin
        return 1 
    end
    
    
    if not exists(select * from nhanvien where manv = @manv)
    begin
        return 2 
		end
    
    
    if @soluongx > (select soluong from sanpham where masp = @masp)
    begin
        return 3 
    end
    
    
    if exists(select * from xuat where sohdx = @sohdx)
    begin
        
        update xuat
        set masp = @masp,
            manv = @manv,
            ngayxuat = @ngayxuat,
            soluongx = @soluongx
        where sohdx = @sohdx
    end
    else
    begin
        
        insert into xuat(sohdx, masp, manv, ngayxuat, soluongx)
        values(@sohdx, @masp, @manv, @ngayxuat, @soluongx)
    end
    
    
    return 0
end