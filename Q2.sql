use DB109;

GO
create procedure SelectSupplies 
	@prCode INT, 
	@date1 DATE, 
	@date2 DATE
as
begin

	declare 
	@prDescr VARCHAR(100),
	@supCode INT,
	@sDate DATE,
	@sQuantity INT;

	declare curs cursor for
		select P.prDescr, S.supCode, S.sDate, S.sQuantity
		from Product P
		inner join Supplies S on P.prCode = S.prCode
		where @prCode = P.prCode and S.sDate between @date1 and @date2
		group by P.prDescr, S.supCode, S.sDate, S.sQuantity;

	open curs;																 /* ξεκιναει να τρεχει*/
	fetch next from curs into @prDescr, @supCode, @sDate, @sQuantity;    /* ιδιος τυπος του select*/
	while @@FETCH_STATUS=0                                              /* οσο υπαρχει επομενη γραμμη */
	begin
		print 'Product: ' + @prDescr
		print 'Supply code:' + str(@supCode)
		print 'Supply quantity:' + str(@sQuantity)
		print 'Supply date: ' + cast(@sDate as varchar)
		print ' '
		fetch next from curs into @prDescr, @supCode, @sDate, @sQuantity;
	end;
	close curs;
	deallocate curs;
end;

GO
exec SelectSupplies 2018, '2010-01-23', '2020-06-15';