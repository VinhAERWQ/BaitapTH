--câu3a--
create trigger trg_nhatkybanhang_insert
on Nhatkybanhang
after insert
as
begin
	update Mathang
	set soluong = Mathang.soluong - inserted.soluong
	from Mathang
	inner join inserted on Mathang.mahang = inserted.mahang
	end;

--cau3b--
create trigger trg_nhatkybanhang_update
on Nhatkybanhang
after update
as
begin
	if update(soluong)
	begin
	update Mathang
	set soluong = Mathang.soluong + deleted.soluong - inserted.soluong
	from Mathang
	inner join deleted on Mathang.mahang = deleted.mahang
	inner join inserted on Mathang.mahang = inserted.mahang
end
end;

--cau3c--
create trigger trg_nhatkybanhang_insert
on Nhatkybanhang
for insert
as
begin
	declare @mahang int, @soluong int, @soluong_hien_co int

	select @mahang = mahang, @soluong = soluong
	from inserted

	select @soluong_hien_co = soluong
	from Mathang
	where mahang = @mahang

	if @soluong <= @soluong_hien_co
	begin
		update Mathang
		set soluong = soluong - @soluong
		where mahang = @mahang
		end
		else
		begin
		raiserror('số lượng hàng bán ra phải nhỏ hơn hoặc bằng số lượng hàng hiện có!', 16, 1)
		rollback transaction
	end
end;

--cau3d--
create trigger trg_nhatkybanhang_updatee
on Nhatkybanhang
for update
as
begin
if (select count(*) from inserted) > 1
begin
	raiserror('chỉ được cập nhật 1 bản ghi tại một thời điểm!', 16, 1)
	rollback transaction
	end
	else
	begin
		declare @mahang int, @soluong int, @soluong_hien_co int
		select @mahang = mahang, @soluong = soluong
		from inserted

		select @soluong_hien_co = soluong
		from Mathang
		where mahang = @mahang

		update Mathang
		set soluong = soluong + (select soluong from deleted) - @soluong
		where mahang = @mahang
	end
end;

--cau3e--
create trigger trg_nhatkybanhang_delete
on Nhatkybanhang
for delete
as
begin
	if (select count(*) from deleted) > 1
	begin
		raiserror('chỉ được xóa 1 bản ghi tại một thời điểm!', 16, 1)
		rollback transaction
		end
		else
		begin
		declare @mahang int, @soluong int
		select @mahang = mahang, @soluong = soluong
		from deleted
		update Mathang
		set soluong = soluong + @soluong
		where mahang = @mahang
	end
end;

--cau3f--
create trigger trg_nhatkybanhang_update
on Nhatkybanhang
for update
as
begin
	declare @mahang int, @soluong int, @soluong_hien_co int

	select @mahang = mahang, @soluong = soluong
	from inserted

	select @soluong_hien_co = soluong
	from Mathang
	where mahang = @mahang

	if @soluong > @soluong_hien_co
	begin
		raiserror('số lượng cập nhật không được vượt quá số lượng hiện có!', 16, 1)
		rollback transaction
	end
	else if @soluong = @soluong_hien_co
	begin
		raiserror('không cần cập nhật số lượng!', 16, 1)
		rollback transaction
	end
	else
	begin
		update Mathang
		set soluong = soluong + (select soluong from deleted) - @soluong
		where mahang = @mahang
	end
end;

--cau3g--
create procedure sp_xoa_mathang
@mahang int
as
begin
if not exists (select * from Mathang where mahang = @mahang)
begin
print 'mã hàng không tồn tại!'
return
end

begin transaction

delete from Nhatkybanhang where mahang = @mahang
delete from Mathang where mahang = @mahang

commit transaction

print 'xóa mặt hàng thành công!'
end

--cau3h--
create function fn_tongtien_hang
(@tenhang nvarchar(50))
returns money
as
begin
declare @tongtien money

select @tongtien = sum(tongtien)
from Nhatkybanhang nk
join Mathang mh on nk.mahang = mh.mahang
where mh.tenhang = @tenhang

return @tongtien
end
--câu3i--
-- test cho câu 2
select * from Mathang
select * from Nhatkybanhang
-- test cho câu 3a
insert into Nhatkybanhang (stt, ngay, nguoimua, mahang, soluong, giaban)
values
(6, '2022-04-22', 'nguyễn thị f', 1, 3, 15000)
select * from Mathang
-- test cho câu 3b
update Nhatkybanhang set soluong = 2 where stt = 2
select * from Mathang
-- test cho câu 3c
insert into Nhatkybanhang (stt, ngay, nguoimua, mahang, soluong, giaban)
values
(7, '2022-04-23', 'trương văn g', 2, 10, 12000)
select * from Mathang
-- test cho câu 3d
update Nhatkybanhang set soluong = 1 where stt = 3
select * from Mathang
-- test cho câu 3e
delete from Nhatkybanhang where stt = 4
select * from Mathang
-- test cho câu 3f
update Nhatkybanhang set soluong = 7 where stt = 5
select * from Mathang
-- test cho câu 3g
exec sp_xoa_mathang 3
select * from Mathang
select * from Nhatkybanhang