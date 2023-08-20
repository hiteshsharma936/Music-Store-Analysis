
use MusicStoreAnalysis
--------------------------------------------------------------------------------------------------------------
                                             -- BEGINNER LEVEL QUERIES--

-- who is the senior most employee based on job title?

select TOP 1 * from employee order by levels desc
--------------------------------------------------------------------------------------------------------------
--Which countries  have the most invoices?

select  top 10 count(billing_country),billing_country from invoice group by billing_country 
order by billing_country desc
---------------------------------------------------------------------------------------------------------------
--What are the top 3 values of total invoice?

select top 3 total from invoice order by total desc
---------------------------------------------------------------------------------------------------------------
--Which city has the best customers? We would like to throw a promotional music festival in the city we made the 
--most moneywrite a query that returns one city that has the highest sum of invoice totals.Return both the city 
-- name and sum of all invoice totals.

select top 1 billing_city,sum(total)as t from invoice group by billing_city order by t
-----------------------------------------------------------------------------------------------------------------
--Who is the best customer?The customer who has spent the most money will be declared the best customer. Write a 
--query that returns the person who has spent the most money.

select top 1 c.customer_id,sum(i.total) as t  from customer as c  join invoice as i on c.customer_id = i.customer_id 
group by c.customer_id order by t desc
-----------------------------------------------------------------------------------------------------------------
                                          --MODERATE LEVEL QUERIES--

--Write query to return the email,first name,last name of all rock music listeners.Return your list 
--ordered alphabetically by email starting with "A"

select distinct c.email,c.first_name,c.last_name from customer as c  join invoice as i on 
c.customer_id = i.customer_id join invoice_line on i.invoice_id = invoice_line.invoice_id where track_id in
( select track_id from track join genre on track.genre_id = genre.genre_id where genre.name like 'Rock')   order by email;

-----------------------------------------------------------------------------------------------------------------
--Lets invite the artists who have written the most rock music in our dataset.Write a query that returns the artist 
--name and total track count of the top 10 rock bands.

select top 10 artist.name,count(track_id) as tracks  from artist join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id where genre_id = 1 group by artist.name order by tracks desc

------------------------------------------------------------------------------------------------------------------
--Return all the track names that have a song length longer than the average song length.Return the average song length.
--Return the name and milleseconds for each track.Order by the song length with the longest songs listed first.

select name,milliseconds from track  where milliseconds >(select avg(milliseconds) from track as AvgSongLeng)
order by milliseconds desc
------------------------------------------------------------------------------------------------------------------
                                              --ADVANCE LEVEL QUERIES--

/*find how much amount spent by each customer on artists? Write a query to return customer name,artist name and total spent*/

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



/* Write a query that determines the customer that has spent the most on music for each country.Write a query that 
returns the country along with the top customer and how much they spent.For countries where the top amount spent
is shared, provide all customers who spent this amount */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1




