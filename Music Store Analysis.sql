Create database music_store;
use music_store;
create table album(
album_id int primary key,
title varchar(50),
artist_id int
);

select count(*) from album;

set sql_mode = "";

load data infile "C:/ProgramData/MySQL/album.csv" into table album
fields terminated by ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;

create table employee(
employee_id int,
last_name varchar(50),
first_name varchar(50),
title varchar(50),
reports_to int,
levels varchar(50),
birthdate date,
hire_date date,
address varchar(50),
city varchar(50),
state varchar(50),
country varchar(50),
postal_code varchar(50),
phone int,
fax int,
email varchar(50));

load data infile "C:/ProgramData/MySQL/employee.csv" into table employee
fields terminated by ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;

-- Other tables were imported using table data import wizard

-- Q1: Who is the senior most employee, find name and job title
select concat(first_name, " " , last_name) as Name, title from employee
order by levels desc
limit 1;


-- Q2: Which countries have the most Invoices?
select billing_country, Count(*) as `Total Invoices` from invoice
group by billing_country
order by `Total Invoices`  desc;


-- Q3: What are top 3 values of total invoice?
select invoice_id, total from invoice
order by total desc
limit 3;


-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--     Write a query that returns one city that has the highest sum of invoice totals. 
--     Return both the city name & sum of all invoice totals.
select billing_city, sum(total) as `invoice total` from invoice
group by billing_city
order by `invoice total` desc
limit 1;


-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--     Write a query that returns the person who has spent the most money.
select c.customer_id, concat(c.first_name," ",c.last_name) as Name, sum(i.total) as `Money Spent`
from customer c inner join invoice i on (c.customer_id = i.customer_id)
group by c.customer_id
order by `Money Spent` desc
limit 1;


-- Q6: Write query to return the first name, last name, email & Genre of all Rock Music listeners. 
--        Return your list ordered alphabetically by email starting with A.
select distinct c.email, c.first_name, c.last_name, g.name as name from
customer c inner JOIN invoice i ON i.customer_id = c.customer_id
inner JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock' and c.email like 'a%'
ORDER BY c.email;


-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
--     Write a query that returns the Artist name and total track count of the top 10 rock bands.
select a.name, count(a.artist_id) as `total tracks`
from artist a inner join album al using (artist_id)
inner join track t using(album_id)
inner join genre g using (genre_id)
where g.name like 'Rock'
group by a.artist_id
order by `total tracks` desc
limit 10;


-- Q8: Return all the track names that have a song length longer than the average song length. 
--     Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select name, milliseconds from track 
where milliseconds > (select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;


-- Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

set sql_mode = "";
select concat(c.first_name," ",c.last_name) as `customer Name`, a.name as `artist name`, sum(il.unit_price*il.quantity) as `total spent`
from customer c inner JOIN invoice i ON i.customer_id = c.customer_id
inner JOIN invoice_line il ON il.invoice_id = i.invoice_id
inner JOIN track t ON t.track_id = il.track_id
inner join album al using(album_id)
inner join artist a using(artist_id)
group by `customer Name`, `artist name`
order by `total spent` desc;


-- Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.
with popular_genre as 
(select count(il.quantity) as purchases,
c.country as country, g.name as genre_name,
row_number() over(partition by c.country order by count(il.quantity) desc) as row_num
from customer c inner join invoice i using (customer_id)
inner join invoice_line il using (invoice_id)
inner join track t using (track_id)
inner join genre g using (genre_id)
group by country,genre_name
order by 2 asc, 1 desc)
SELECT country, genre_name, purchases 
FROM popular_genre 
WHERE row_num <= 1;


-- Q11: Write a query that determines the customer that has spent the most on music for each country. 
--      Write a query that returns the country along with the top customer and how much they spent. 
--      For countries where the top amount spent is shared, provide all customers who spent this amount.
select  country,`customer Name`, `amount spent`
from (select c.country as country, concat(c.first_name," ",c.last_name) as `customer Name`, SUM(i.total) as `amount spent`, row_number()over(partition by c.country order by sum(i.total) desc) as row_num
from customer c inner join invoice i using (customer_id)
group by `customer Name`
order by `amount spent` desc) as rnk
where row_num = 1;


-- Q12: Who are the most popular artists?
select count(il.quantity) as purchases, a.name as `artist name`
from invoice_line il inner join track t using (track_id)
inner join album al using (album_id)
inner join artist a using(artist_id)
group by `artist name`
order by purchases desc
limit 10;


 -- Q13: Which is the most popular song?
select count(il.quantity) as purchases, t.name as song_name
from invoice_line il inner join track t using (track_id)
group by song_name
order by purchases desc
limit 10;


-- Q14: What are the average prices of different types of music?
select genre, concat('$ ', round(avg(total_spent))) as total_spent from
(select g.name as genre, sum(i.total) as total_spent
from invoice i inner join invoice_line il using (invoice_id)
inner join track t using(track_id)
join genre g using (genre_id)
group by genre
order by total_spent) as tab
group by genre;


-- Q15: What are the most popular countries for music purchases?
select i.billing_country as country, count(il.quantity) as total_purchases from
invoice_line il inner join invoice i using (invoice_id)
group by country
order by total_purchases desc;
