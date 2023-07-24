use DB109;

GO
create procedure SelectGACustomers 
	@gaCode INT
as
	select count(C.custCode)
	from Customer C
	where @gaCode = C.gaCode;
	
GO
exec SelectGACustomers 1009;
