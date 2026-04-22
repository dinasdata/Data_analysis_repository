/* selecting all the Customer of the Chinook database that are not Americans and all the customers that are Americans*/
select count(CustomerId) ,
case 
when Country = "USA" then "Americans"
else "not Americans"
end as country_type
from Customer
group by country_type;
;
/*Showing all customers by country */
select distinct Country, count(CustomerId) as total_customers from Customer
group by Country;
/* Invoice numbers by year since 2021 to 2025*/
select year(InvoiceDate) as Year, count(InvoiceId) as Invoice_number from Chinook.Invoice
where year(InvoiceDate) = 2025
group by Year
union
select year(InvoiceDate) as Year, count(InvoiceId) as Invoice_number from Chinook.Invoice
where year(InvoiceDate) = 2024
group by Year
union
select year(InvoiceDate) as Year, count(InvoiceId) as Invoice_number from Chinook.Invoice
where year(InvoiceDate) = 2023
group by Year
union
select year(InvoiceDate) as Year, count(InvoiceId) as Invoice_number from Chinook.Invoice
where year(InvoiceDate) = 2022
group by Year
union
select year(InvoiceDate) as Year, count(InvoiceId) as Invoice_number from Chinook.Invoice
where year(InvoiceDate) = 2021
group by Year
;
/*Number of Invoices per country*/
select distinct Country, count(I.CustomerId) as total_customer from Chinook.Invoice I join Chinook.Customer C on
I.CustomerId = C.CustomerId
group by Country;
/*Total of tacks per playlist*/
select Name, count(p.TrackId) as Total_track from Chinook.PlaylistTrack p join 
Chinook.Playlist t on p.PlaylistId = t.PlaylistId
group by Name
order by Name;
/* Total sales made by every sale agent*/
use Chinook;
select concat(E.FirstName," ",E.LastName) as Name, count(V.InvoiceId) as Total_sales from 
 Chinook.Invoice V join Chinook.Customer C on V.CustomerId = C.CustomerId join (select * from Chinook.Employee where Title like "%Sales%" ) as E on E.EmployeeId = C.SupportRepId
group by Name;
/*total sales per country*/
select distinct BillingCountry, count(InvoiceId) as total_sales from Chinook.Invoice
group by BillingCountry
order by BillingCountry;
/*Getting  top 10 most purchased track*/
select distinct T.Name, count(J.Total) as total_sales from Chinook.Track T 
join Chinook.InvoiceLine I on T.TrackId = I.TrackId join Chinook.Invoice J on I.InvoiceId= J.InvoiceId
group by T.Name
order by total_sales  desc limit 10;
