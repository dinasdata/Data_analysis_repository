# a Madagascar data scraping package for the website : https://weatherandclimate.com/madagascar
<p>This repository countains code for a python package that can be used to download a summary and daily weather data for Madagascar from the website we told above.
There are two main functions in the package :data_scrap.daily_scrap and data_scrap.summary_scrap. summary_scrap is used for summary data download and daily_scrap for daily data.
Three parameters must be entered while using these functions :</p>
<ul>
  <li>The town : antananarivo, mahajanga, toamasina, toliara, fianarantsoa, antsiranana (all in lowercase)</li>
  <li>The month : january to december (all in lowercase and all day available for the daily scrap)</li>
  <li>The year : 2010 to 2020</li>
</ul>
<p>The downloaded data will be stored in an excel file with the town name, month and year and ready for analysis. Please enjoy :) !</p>
