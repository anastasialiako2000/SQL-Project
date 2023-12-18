/*---------------- Query to create a view of distinct months with payments made------------------ */
GO
create view PaymentMonths (m) as
select distinct month(pDate) as m
from Payment;

/*----------------- Query to create a view of distinct months with orders made-------------------- */
GO
create view OrderMonths (m) as
select distinct month(orDate) as m
from Orders;


/*---------------- Query 1: Retrieve customer information----------------- */

GO
select custCode, custAfm, custName, custRoad,  custNum, custCity, custZip, custPhone
from Customer;

/*--------------- Query 2: Retrieve customers and their payment amounts within a specific date range-------------- */

GO
select R.custCode, P.amount
from Regular R
inner join Payment P on R.custCode = P.custCode
where P.pDate>='2012/05/12' and P.pDate<='2012/05/22';

/*------------ Query 3: Retrieve order date, order code, and product code from Orders and Includes tables--------------- */

GO
select O.orDate, O.ordCode, I.prCode
from Orders O, Includes I
where O.ordCode=I.ordCode;

/*------------ Query 4: Update product prices by increasing them by 3%----------------- */
GO
update Product
set price = price*1.03;

/*------------- Query 5: Calculate summary and average payment amounts per month in 2012 ---------------*/

GO
select PM.m as months, sum(amount) as summary, avg(amount) as average
from Payment P, PaymentMonths PM
where month(P.pDate)=PM.m and year(P.pDate)='2012'
group by PM.m

/*----------- Query 6: Retrieve customers whose total purchase exceeds $2500 in January 2013-------------- */

GO
select C.custAfm, C.custName
from Customer C
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on I.prCode=P.prCode
where year(O.orDate)='2013' and month(O.orDate)='01'
group by C.custAfm, C.custName
having sum(P.price*I.orQuant)>2500;

/*------------- Query 7: Retrieve total sales by customer and category---------------- */

GO
select distinct C.custCode, P.catCode, sum(P.price*I.orQuant) as summary
from Customer C												
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on I.prCode=P.prCode
group by C.custCode, P.catCode, P.prCode;

/*---------------- Query 8: Create views V4 and V5, and retrieve average prices per geo area and category-------------- */

GO
create view V4 (gaCode, custCode, ordCode, price, orQuant) as
select GA.gaCode, C.custCode, O.ordCode,P.price,I.orQuant
from GeoArea GA													
inner join Customer C on GA.gaCode=C.gaCode						
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on I.prCode=P.prCode
group by GA.gaCode, C.custCode, O.ordCode,P.price,I.orQuant;

GO
create view V5 (catCode, ordCode, price, orQuant) as
select C.catCode, I.ordCode, P.price, I.orQuant
from Category C													
inner join Product P on C.catCode=P.catCode
inner join Includes I on P.prCode=I.prCode
group by C.catCode, I.ordCode, P.price, I.orQuant;

GO
select GA.gaCode, avg(V4.price*V4.orQuant)
from GeoArea GA, V4
where GA.gaCode=V4.gaCode
group by GA.gaCode;

GO
select distinct C.catCode, avg(V5.price*V5.orQuant)
from Category C, V5
where C.catCode=V5.catCode
group by C.catCode;

/*-------------------- Query 9: Calculate percentage of sales for each month in 2012---------------- */

GO
create view V6(summary) as
select sum(P.price*I.orQuant)      
from Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2012';

GO 
create view V7(months,summary) as 
select OM.m, sum(P.price*I.orQuant)
from OrderMonths OM, Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2012' and month(O.orDate)= OM.m
group by OM.m;

GO
select OM.m as months, V7.summary/V6.summary*100 as percentage
from V6, V7, OrderMonths OM               
where OM.m=V7.months;

/*------------------ Query 10: Compare average prices per month for customers---------------------- */

GO 
create view V8(months,average) as 
select OM.m, avg(P.price*I.orQuant)
from OrderMonths OM, Customer C				
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where month(O.orDate)= OM.m
group by OM.m;

GO 
create view V9(months, custCode, average) as 
select OM.m, C.custCode, avg(P.price*I.orQuant)  
from OrderMonths OM, Customer C 
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where month(O.orDate)= OM.m
group by C.custCode, OM.m;

GO
select V8.months, count(V9.custCode)  
from V8, V9
where V8.months=V9.months and V9.average>V8.average   
group by V8.months;

/*------------------------ Query 11: Calculate the percentage of sales for each month in 2011------------------------ */

GO 
create view V10(months,summary) as
select OM.m, sum(P.price*I.orQuant)
from OrderMonths OM, Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2011' and month(O.orDate)= OM.m
group by OM.m;

GO
select V7.months, V7.summary/V10.summary*100 as percentage
from V7
inner join V10 on V7.months=V10.months
group by V7.months, V7.summary/V10.summary*100;    


/*--------------------- Query 12: Compare average prices in 2012 per month--------------------------- */

GO
create view V11(months,average) as
select OM.m, avg(P.price*I.orQuant)
from OrderMonths OM, Orders O      
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2012' and month(O.orDate)= OM.m
group by OM.m;

GO
create view V12(months,average) as
select OM.m, avg(P.price*I.orQuant)
from OrderMonths OM, Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2012' and month(O.orDate)< OM.m    
group by OM.m;										

GO
select OM.m, V11.average, V12.average
from OrderMonths OM, V11				
left join V12 on V11.months=V12.months   
where OM.m = V11.months
group by OM.m, V11.average, V12.average

/*------------------------- Query 13: Identify orders with specific conditions on suppliers-------------------------- */

GO 
create view V50 (prCode, suppliersNumber) as
select distinct P.prCode, COUNT(S.sCode) as suppliersNumber
from Product P
inner join Supplies Sup on P.prCode = Sup.prCode
inner join Supplier S on Sup.sCode = S.sCode
group by P.prCode

GO 
create view V14 (prCode, suppliersNumber) as 
select distinct P.prCode, count(S.sCode) as suppliersNumber
from Product P
inner join Supplies Sup on P.prCode = Sup.prCode
inner join Supplier S on Sup.sCode = S.sCode                
left join Supplies Sup2 on P.prCode = Sup2.prCode          
inner join Supplier S2 on Sup2.sCode = S2.sCode
where S.sCode != S2.sCode and S.gaCode = S2.gaCode
group by P.prCode, S.sCode, S.gaCode;

GO
select distinct V14.prCode
from V50, V14
where V50.prCode = V14.prCode and V14.suppliersNumber +1  = V50.suppliersNumber       
  

/*----------------------- Query 14: Identify orders meeting specific criteria based on product and supplier----------------------- */

GO
create view V15 (ordCode, prCode, sCode) as
select I.ordCode, P.prCode, Su.sCode
from Includes I						
inner join Product P on P.prCode=I.prCode   
inner join Supplies S on P.prCode=S.prCode
inner join Supplier Su on S.sCode=Su.sCode;
Go

select V15.ordCode    
from V15
left join V15 as V16 on V15.ordCode = V16.ordCode  
left join V15 as V17 on V16.ordCode = V17.ordCode  
where V15.prCode!=V16.prCode and V16.prCode!=V17.prCode and V15.prCode!=V17.prCode and V15.sCode=V16.sCode and V16.sCode=V17.sCode
group by V15.ordCode
