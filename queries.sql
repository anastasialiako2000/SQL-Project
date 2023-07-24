/*for qusetions with months
----to get the months in which payments have been made*/
GO
create view PaymentMonths (m) as
select distinct month(pDate) as m
from Payment;
/*----to get the months in which orders have been made, pwlhseis*/
GO
create view OrderMonths (m) as
select distinct month(orDate) as m
from Orders;

/*--------Q1--------*/

GO
select custCode, custAfm, custName, custRoad,  custNum, custCity, custZip, custPhone
from Customer;

/*--------Q2--------*/

GO
select R.custCode, P.amount
from Regular R
inner join Payment P on R.custCode = P.custCode
where P.pDate>='2012/05/12' and P.pDate<='2012/05/22';

/*--------Q3--------*/

GO
select O.orDate, O.ordCode, I.prCode
from Orders O, Includes I
where O.ordCode=I.ordCode;

/*--------Q4--------*/

GO
update Product
set price = price*1.03;

/*--------Q5--------*/

GO
select PM.m as months, sum(amount) as summary, avg(amount) as average
from Payment P, PaymentMonths PM
where month(P.pDate)=PM.m and year(P.pDate)='2012'
group by PM.m

/*--------Q6--------*/

GO
select C.custAfm, C.custName
from Customer C
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on I.prCode=P.prCode
where year(O.orDate)='2013' and month(O.orDate)='01'
group by C.custAfm, C.custName
having sum(P.price*I.orQuant)>2500;

/*--------Q7--------*/

GO
select distinct C.custCode, P.catCode, sum(P.price*I.orQuant) as summary
from Customer C													/*sumpsifizei ta catcodes mazi, mhn emfanizei 2 fores gia ena custcode kai idia catcodes se diaforetikes grammes ta sum*/
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on I.prCode=P.prCode
group by C.custCode, P.catCode, P.prCode;

/*--------Q8--------*/

/*  epd gia catcode kai ana gacode einai diaforetiko to avg theloume views*/ 


GO
create view V4 (gaCode, custCode, ordCode, price, orQuant) as
select GA.gaCode, C.custCode, O.ordCode,P.price,I.orQuant
from GeoArea GA													/* ta organwnw ana gacode kai custcode ta price kai ta orQuant*/
inner join Customer C on GA.gaCode=C.gaCode						/* xreiazomazte to custcode giati sundeetai cutomer-orders, kai Geoarea-customer*/
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on I.prCode=P.prCode
group by GA.gaCode, C.custCode, O.ordCode,P.price,I.orQuant;

GO
create view V5 (catCode, ordCode, price, orQuant) as
select C.catCode, I.ordCode, P.price, I.orQuant
from Category C													/* ordcode gia na emfanizontai gia kathe catcode oles oi paraggelies*/
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

/*--------Q9--------*/

GO
create view V6(summary) as
select sum(P.price*I.orQuant)      /*sunolikes ethsies pwlhseis toy 2012*/
from Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2012';

GO /*σύνολο πωλήσεων ανά μήνα του 2012*/
create view V7(months,summary) as 
select OM.m, sum(P.price*I.orQuant)
from OrderMonths OM, Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2012' and month(O.orDate)= OM.m
group by OM.m;

GO
select OM.m as months, V7.summary/V6.summary*100 as percentage
from V6, V7, OrderMonths OM               /* ws pososto tis pwlhseis ana mhna me tis sunolikes pwlhseis*/
where OM.m=V7.months;

--------Q10--------*/

GO 
create view V8(months,average) as 
select OM.m, avg(P.price*I.orQuant)
from OrderMonths OM, Customer C					/* μο ανα μήνα */
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where month(O.orDate)= OM.m
group by OM.m;

GO 
create view V9(months, custCode, average) as 
select OM.m, C.custCode, avg(P.price*I.orQuant)  /* μο αξίας αγορων ανα πελατη ανα μηνα, μο πελατη ανα μηνα*/
from OrderMonths OM, Customer C 
inner join Orders O on C.custCode=O.custCode
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where month(O.orDate)= OM.m
group by C.custCode, OM.m;

GO
select V8.months, count(V9.custCode)    /* μέτρα ποσοι*/
from V8, V9
where V8.months=V9.months and V9.average>V8.average   /*πελατες μο τους> μο του μήνα*/
group by V8.months;

/*--------Q11--------*/

/*σθγκρινε πωλησεις του μηνα 2012 με αντιστοιχο μηνα 2011*/

GO /*σύνολο ανά μήνα 2011*/
create view V10(months,summary) as
select OM.m, sum(P.price*I.orQuant)
from OrderMonths OM, Orders O
inner join Includes I on O.ordCode=I.ordCode
inner join Product P on P.prCode=I.prCode
where year(O.orDate)='2011' and month(O.orDate)= OM.m
group by OM.m;

/*η view V7  περιέχει το σύνολο ανά μήνα του 2012*/

GO
select V7.months, V7.summary/V10.summary*100 as percentage
from V7
inner join V10 on V7.months=V10.months
group by V7.months, V7.summary/V10.summary*100;    /*χρειαζεται αλλιως μου χτυπαει */

/*--------Q12--------*/

GO
create view V11(months,average) as
select OM.m, avg(P.price*I.orQuant)
from OrderMonths OM, Orders O         /* μο του κάθε μηνα του 2012*/
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
where year(O.orDate)='2012' and month(O.orDate)< OM.m     /* μο μήνα που προηγήθηκαν, δεν εμφανιζεται ο ιανουαρος γιατι οταν ειμαι στον ιανουαριο δεν εχει προηγηθει καποιος*/
group by OM.m;											/* φτιαχνω νεο πινακα, 'με τους μήνες που προηγήθηκαν'*/

GO
select OM.m, V11.average, V12.average
from OrderMonths OM, V11				/*left join επειδη θελω ολους τους μηνες να μου εμφανιστουν στοιχεια,*/
left join V12 on V11.months=V12.months   /* και στον ιανουαριο που στον 2ο πινακα δεν εχουμε κατι, να εμφανιστει null*/
where OM.m = V11.months
group by OM.m, V11.average, V12.average

/*--------Q13--------*/

GO /*ο αριθμός προμηθευτών για το κάθε προϊόν*/
create view V50 (prCode, suppliersNumber) as
select distinct P.prCode, COUNT(S.sCode) as suppliersNumber
from Product P
inner join Supplies Sup on P.prCode = Sup.prCode
inner join Supplier S on Sup.sCode = S.sCode
group by P.prCode

GO /*για κάθε προϊόν οι προμηθευτές που είναι από την ίδια περιοχή*/
create view V14 (prCode, suppliersNumber) as 
select distinct P.prCode, count(S.sCode) as suppliersNumber
from Product P
inner join Supplies Sup on P.prCode = Sup.prCode
inner join Supplier S on Sup.sCode = S.sCode                /*πχ για κωδ 2017 εχμ 4 προμηθευτες και η v14 βγαζει 3, γιατι συγκρινει χ1-χ2 , χ2-χ3, χ3-χ4 3 συκρισεις για 4 προμηεθευτες*/
left join Supplies Sup2 on P.prCode = Sup2.prCode           /* επειδη τα συγκρινει ανα ζευγη, χανουμε 1 προμηθευτη σαν ατομο στο συνολο πρμηθευτων*/
inner join Supplier S2 on Sup2.sCode = S2.sCode
where S.sCode != S2.sCode and S.gaCode = S2.gaCode
group by P.prCode, S.sCode, S.gaCode;

GO
select distinct V14.prCode
from V50, V14
where V50.prCode = V14.prCode and V14.suppliersNumber +1  = V50.suppliersNumber       /*θέλουμε όλοι οι προμηθευτες που βρηκαμε πως εχει ενα προιον στη V50, να ειναι ισοι με τον αριθμο που βρηκαμε +1 στη V14 οτι ειαι απο ιδια περιοχη*/
/*+1 γιατί τα ζεύγη που δημιουργεί η V14 είναι κατά ένα λιγότερα απο τους suppliers*/

/*--------Q14--------*/

GO
create view V15 (ordCode, prCode, sCode) as
select I.ordCode, P.prCode, Su.sCode
from Includes I						/*θελω 1 παραγγελια, 3 διαφορετικα προιοντα, 1 προμηθευτη*/
inner join Product P on P.prCode=I.prCode   /* φτιαχνω πινακα που περιεχει για καθε παραγγελια τα προιοντα και τους suppliers*/
inner join Supplies S on P.prCode=S.prCode
inner join Supplier Su on S.sCode=Su.sCode;
Go

select V15.ordCode    
from V15
left join V15 as V16 on V15.ordCode = V16.ordCode  /* kanoume join me ton eauto tou (epd milame gia idia paraggelia) opou exoume 2 diaforetika proionta me koino promhtheuth */
left join V15 as V17 on V16.ordCode = V17.ordCode  /* kai to xanakanoume giati theloume 3 proionta*/
where V15.prCode!=V16.prCode and V16.prCode!=V17.prCode and V15.prCode!=V17.prCode and V15.sCode=V16.sCode and V16.sCode=V17.sCode
group by V15.ordCode