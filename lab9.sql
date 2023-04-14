go
use QLBanHang
go

go
-----cau1-------

create trigger trg_Nhap_checkconstraints
on Nhap
after insert
as
begin
    declare @masp nvarchar(10)
    declare @manv nvarchar(10)
    declare @soluongn int
    declare @dongian float

    select @masp = masp, @manv = manv, @soluongn = soluongn, @dongia = dongian
    from inserted
    
    -- kiểm tra masp có trong bảng sanpham chưa
    if not exists (select * from Sanpham where masp = @masp)
    begin
        raiserror('lỗi: masp không tồn tại trong bảng sanpham', 16, 1)
        rollback transaction
        return
    end
    
    -- kiểm tra manv có trong bảng nhanvien chưa
    if not exists (select * from Nhanvien where manv = @manv)
    begin
        raiserror('lỗi: manv không tồn tại trong bảng nhanvien', 16, 1)
        rollback transaction
        return
    end
    
    -- kiểm tra ràng buộc dữ liệu
    if @soluongn <= 0 or @dongian <= 0
    begin
        raiserror('lỗi: soluongn và dongian phải lớn hơn 0', 16, 1)
        rollback transaction
        return
    end
    
    -- cập nhật số lượng sản phẩm trong bảng sanpham
    update Sanpham
    set soluong = soluong + @soluongn
    where masp = @masp
end

go

go
---cau 2-----
create trigger checkXuat
on Xuat
after insert
as
begin
    -- kiểm tra ràng buộc toàn vẹn
    if not exists (select masp from Sanpham where masp = (select masp from inserted))
    begin
        raiserror('mã sản phẩm không tồn tại trong bảng sanpham', 16, 1)
        rollback transaction
        return
    end

    if not exists (select manv from Nhanvien where manv = (select manv from inserted))
    begin
        raiserror('mã nhân viên không tồn tại trong bảng nhanvien', 16, 1)
        rollback transaction
        return
    end
    
    -- kiểm tra ràng buộc dữ liệu
    declare @soluongx int
    select @soluongx = soluongx from inserted
    
    declare @soluong int
    select @soluong = soluong from Sanpham where masp = (select masp from inserted)
    
    if (@soluongx > @soluong)
    begin
        raiserror('số lượng xuất vượt quá số lượng trong kho', 16, 1)
        rollback transaction
        return
    end
    
    -- cập nhật số lượng trong bảng sanpham
    update Sanpham
    set soluong = soluong - @soluongx
    where masp = (select masp from inserted)
end
go

go
---cau 3----
create trigger updateslxoaphieuxuat
on Xuat
after delete
as
begin
    -- cập nhật số lượng hàng trong bảng sanpham tương ứng với sản phẩm đã xuất
    update Sanpham
    set soluong = Sanpham.soluong + deleted.soluongx
    from Sanpham
    join deleted on Sanpham.masp = deleted.masp
end
go

go
----cau 4----------
create trigger update_xuat_slg_trigger
on Xuat
after update
as
begin
    -- kiểm tra xem có ít nhất 2 bản ghi bị update hay không
    if (select count(*) from inserted) < 2
    begin
declare @old_soluong int, @new_soluong int, @masp nvarchar(10)

        select @masp = i.masp, @old_soluong = d.soluongx, @new_soluong = i.soluongx
        from deleted d inner join inserted i on d.sohdx = i.sohdx and d.masp = i.masp

        -- kiểm tra số lượng xuất mới có nhỏ hơn số lượng tồn kho hay không
        if (@new_soluong <= (select soluong from Sanpham where masp = @masp))
        begin
            update Xuat set soluongx = @new_soluong where sohdx in (select sohdx from inserted)
            update Sanpham set soluong = soluong + @old_soluong - @new_soluong where masp = @masp
        end
    end
end

go

go
----cau 5----
create trigger tr_updateNhap
on Nhap
after update
as
begin
    -- kiểm tra số bản ghi thay đổi
    if (select count(*) from inserted) > 1
    begin
        raiserror('chỉ được phép cập nhật 1 bản ghi tại một thời điểm', 16, 1)
        rollback
    end
    
    -- kiểm tra số lượng nhập
    declare @masp int
    declare @soluongn int
    declare @soluong int
    
    select @masp = i.masp, @soluongn = i.soluongn, @soluong = s.soluong
    from inserted i
    inner join Sanpham s on i.masp = s.masp
    
    if (@soluongn > @soluong)
    begin
        raiserror('số lượng nhập không được vượt quá số lượng hiện có trong kho', 16, 1)
        rollback
    end
    
    -- cập nhật số lượng trong bảng sanpham
    update Sanpham
    set soluong = soluong + (@soluongn - (select soluongn from deleted where masp = @masp))
    where masp = @masp
end
--6--
create trigger update_soluong_sp 
on Nhap
after delete
as

begin
    
    update Sanpham
    set soluong = Sanpham.soluong - deleted.soluongn
    from Sanpham
    join deleted on Sanpham.masp = deleted.masp
end