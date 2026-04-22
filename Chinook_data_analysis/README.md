<h1> Chinook database simple analysis </h1>
This is a simple analysis of the Chinook sample database using mysql and mysql workbench. The main questions we will answer in this microproject are :
<ul><li>How is the distribution of Customers in the USA comparing to the other countries ?</li>
<li>How is the distribution of Customers in every countries ?</li>
<li>How is the distribution of invoices per year since 2021 to 2025</li>
<li>How does the number of invoices per country look like?</li>
<li>What is the total of tracks in every playlist ?</li>
<li>Who are the top 3 best sales agent?</li>
<li>What are the total sales per country?</li>
<li>What are the top 10 most purchased track?</li>
</ul>
<h2>How is the distribution of Customers in the USA comparing to the other countries ?</h2>
<img src = "datasets/USA vs Other customers.png"/>
<p> In a sample of 24 Country, USA takes the lead in term of customers. As we can see in the plots there are more than the quarter  of the sum of every customers in every countries in the USA. We can see the distribution of customers in each country in the following plots</p>
<img src = "datasets/Customer per country.png"/>
<h2>How is the distribution of invoices per year since 2021 to 2025?</h2>
<img src = "datasets/Invoices per year.png"/>
<p> Invoices may be considered as some references for each sale made. This plot above this present text explain the evolution of invoices in Chinook data store
from 2021 to 2025. The plot shows an equal distribution of it with a value of 83 since 2021 to 2024, but it decreased at a value of 80 in 2025.</p>
<h2>How does the number of invoices per country look like ?</h2>
<img src = "datasets/Invoices per country.png"/>
<p> In term of invoices, USA customers still take the lead with a total of 91 invoices acquiered, followed by Canada (56) and  Brazil, France and GB. 
Some other countries have an average value of invoices of 7,which is really low in front of the americans</p>
<h2>What is the total tracks in every playlist?</h2>
<img src = "datasets/track per playlist.png"/>
<p> There are many kinds of tracks in each playlist, but the most common tracks with a high value of 6580 are musics, followed by 90's musics with a value of 1477 tracks. In front of these, tracks like classical, grunge and heavy metal music are very low in term of values.</p>
<h2>What is the total sale made by every sale agent?</h2>
<p> Three sales agent and marketers made a high value of sales in the Chinook data store: Jane Peacock with a total sales of 146, Margaret Park and Steve Johson with 140 and 126 sales each other.</p>
<h2>What are the total sales per country?</h2>
<img src = "datasets/Sales per coutry.png"/>
<p> This plot explain the sales made by each country. The distribution matches exactly the value of invoices explained earlier,which we can see the USA at the top, followed by Brazil, Canada, Germany and France.</p>
<h2>What are the top 10 most purchased track</h2>
 <p>The file https://github.com/dinasdata/Chinook-database-analysis/blob/main/datasets/Top_10_track.csv provides the top 10 most purchased track on the database. At first we get "Dazed and confused" from the artist Ruel, with a purchase of 5, equal to "the Trooper". At second place we can find "The Number of The Beast", "Hallowed Be Thy Name", "Eruption" and "Sure Know Something" with 4 purchases. 3 tracks followed them, which are "Welcome Home (Sanitarium)", "Brasil" and "Blood Brothers" with 3 purchases total.</p>
<h2> Tools and software</h2>
<ul><li>Mysql version 8.0.42 on Ubuntu as server</li>
<li>Mysql workbench version 8.0.36 Community </li>
<li>WPS spreadsheet for data visualization</li>
</ul>
