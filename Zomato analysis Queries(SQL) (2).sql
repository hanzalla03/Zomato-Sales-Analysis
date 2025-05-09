create database zomato_data;
use zomato_data;
 select * 
 from maindata;
 


##----------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE maindata ADD COLUMN Date_Field DATE;

select * from maindata;

UPDATE Maindata SET Date_Field = 
STR_TO_DATE(CONCAT(`Year opening`, '-', LPAD(`Month opening`, 2, '0'), '-', LPAD(`Day opening`, 2, '0')), '%Y-%m-%d');

select date_field 
from maindata;

## Q1.A. Year
SELECT Year(Date_Field) FROM Maindata;

# Q1.B. Month No
 SELECT Month(Date_Field) as Month_No 
 FROM Maindata;
 
 ## Q1.C Month Name
 SELECT `Month opening`, MONTHNAME(Date_Field) as Month_Name 
 FROM Maindata;
 
 ## Q1.D Quarter
 SELECT MONTHNAME(Date_Field) as Month_Name, QUARTER(Date_Field) as Quarter 
 FROM Maindata;
 
 ## Q1.E Year_Month (YYYY-MMM)
 SELECT DATE_FORMAT(Date_Field, '%Y-%b') AS YearMonth 
 FROM Maindata;
 
 ## Q1.F. WeekDaysNo. 
 SELECT DAYOFWEEK(Date_Field) as Weekday_No 
 FROM Maindata;
        
## Q1.G. Weekday Name
SELECT DAYNAME(Date_Field) as Weekday_name 
FROM Maindata;

## Q1.H. Financial Month
SELECT MONTHNAME(Date_Field),
CASE
    WHEN MONTH(Date_Field) >= 4 THEN MONTH(Date_Field) - 3
    ELSE MONTH(Date_Field) + 9
  END AS FinancialMonth
FROM Maindata;

## Q1.I Financial Quarter
SELECT MONTH(Date_Field),
  CASE
    WHEN MONTH(Date_Field) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(Date_Field) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(Date_Field) BETWEEN 10 AND 12 THEN 'Q3'
    ELSE 'Q4'
  END AS FinancialQuarter
FROM Maindata;



-- KPI 1 : Build a Calendar Table using the Columns Datekey_Opening

SELECT `Year opening`, `Month opening`, `Day opening`, MONTHNAME(Date_Field), QUARTER(Date_Field), DATE_FORMAT(Date_Field, '%Y-%b') AS YearMonth,
		DAYOFWEEK(Date_Field), DAYNAME(Date_Field),
CASE
    WHEN MONTH(Date_Field) >= 4 THEN MONTH(Date_Field) - 3
    ELSE MONTH(Date_Field) + 9
  END AS FinancialMonth,
  CASE
    WHEN MONTH(Date_Field) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(Date_Field) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(Date_Field) BETWEEN 10 AND 12 THEN 'Q3'
    ELSE 'Q4'
  END AS FinancialQuarter
FROM Maindata;

#---------------------------------------------------------------------------------------------------------------------------


-- Q2 Convert the Average cost for 2 column into USD dollars

SELECT Restaurant_Name, Currency, Average_Cost_for_two, Average_Cost_for_two * 
(SELECT USD_Rate FROM Currency_data c WHERE m.currency = c.currency) AS "Avg_Cost_for_Two(USD)"
FROM maindata m
LEFT JOIN currency_data c
USING(currency);

 #----------------------------------------------------------------------------------------------------------------------------------

-- 3 KPI -- Find the Numbers of Resturants based on City and Country

SELECT 
    m.City,
    c.Countryname,
    COUNT(*) AS Number_of_Restaurants
FROM 
    maindata m
JOIN 
    `COUNTRY_DATA` c ON m.`Countrycode` = c.`CountryID`
GROUP BY 
    m.City, c.Countryname
ORDER BY 
    Number_of_Restaurants DESC;
   
   #City wise Restaurant Count
   SELECT city,  count(distinct RestaurantID) AS Restaurant_Count
FROM maindata
GROUP BY City
order by  Restaurant_Count desc;

#Country wise Restaurant Count
SELECT c.countryname,  count(m.RestaurantID) AS Restaurant_Count
FROM maindata m
JOIN 
    `COUNTRY_DATA` c ON m.`Countrycode` = c.`CountryID`
GROUP BY c.countryname;

    
#----------------------------------------------------------------------------------------------------------------------------------    
    
-- 4 KPI --  Numbers of Resturants opening based on Year , Quarter , Month
 
# Year
SELECT `Year Opening`,
       SUM(COUNT(RestaurantID)) OVER (PARTITION BY `YEAR OPENING`) AS Restaurant_Count
FROM MAINDATA
GROUP BY `YEAR OPENING`
ORDER BY `YEAR OPENING`; 

# Qarter 
SELECT Quarter(date_field),
       SUM(COUNT(RestaurantID)) OVER (PARTITION BY Quarter(date_field)) AS Restaurant_Count
FROM MAINDATA
GROUP BY Quarter(date_field)
ORDER BY Quarter(date_field);

# Month
SELECT `Month Opening`,
       SUM(COUNT(RestaurantID)) OVER (PARTITION BY `Month Opening`) AS Restaurant_Count
FROM MAINDATA
GROUP BY `Month Opening`
ORDER BY `Month Opening`;
 #----------------------------------------------------------------------------------------------------------------------------------


-- Q5 Count of Resturants based on Average Ratings

SELECT 
    CASE
        WHEN Rating = 1 THEN '1'
        WHEN Rating > 1 AND Rating <= 2 THEN '1.1 - 2.0'
        WHEN Rating > 2 AND Rating <= 3 THEN '2.1 - 3.0'
        WHEN Rating > 3 AND Rating <= 4 THEN '3.1 - 4.0'
        WHEN Rating > 4 AND Rating <= 5 THEN '4.1 - 5.0'
        ELSE 'Unknown'
    END AS Rating_Bucket,
    COUNT(*) AS Restaurant_Count
FROM Maindata
WHERE Rating IS NOT NULL
GROUP BY Rating_Bucket
ORDER BY Rating_Bucket;

 #----------------------------------------------------------------------------------------------------------------------------------

-- Q6 bucket list based on Average Price

SELECT 
  CASE 
    WHEN (m.Average_Cost_for_two * c.USD_Rate) BETWEEN 0 AND 10 THEN 'Low Budget(0-10)'
    WHEN (m.Average_Cost_for_two * c.USD_Rate) BETWEEN 10.01 AND 30 THEN 'Medium Budget(10-30)'
    WHEN (m.Average_Cost_for_two * c.USD_Rate) BETWEEN 30.01 AND 100 THEN 'High Budget(30-100)'
    WHEN (m.Average_Cost_for_two * c.USD_Rate) > 100 THEN 'Premium(>100)'
    ELSE 'Unknown'
  END AS Price_Bucket_USD,
  COUNT(*) AS Restaurant_Count
FROM maindata m
JOIN `currency_data` c
USING(currency)
WHERE m.Average_Cost_for_two IS NOT NULL
GROUP BY Price_Bucket_USD;




#---------------------------------------------------------------------------------------------------------------------------------

-- Q7 Percentage of Resturants based on "Has_Table_booking"

 SELECT 
    Has_Table_booking, 
    COUNT(*) AS Total_Restaurants, ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM maindata)), 1) AS Percentage
FROM 
   maindata
GROUP BY 
    Has_Table_booking;

-- ----------------------------------------------------------------------------------------------------------------------------------
    
-- Q8 Percentage of Resturants based on "Has_Online_delivery"

  SELECT 
    Has_Online_delivery, 
    COUNT(*) AS Total_Restaurants, ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM maindata)), 1) AS Percentage
FROM 
   maindata
GROUP BY 
   Has_Online_delivery;  
   
#----------------------------------------------------------------------------------------------------------------------------------

-- Q9 Rating vs online delivery analysis  
   SELECT 
    Has_Online_delivery, 
    COUNT(*) AS Total_Restaurants,
    AVG(Rating) AS Average_Rating
    
FROM 
    maindata
GROUP BY 
    Has_Online_delivery
ORDER BY 
    Has_Online_delivery;
   
-- Q10 Rating vs table delivery analysis
   SELECT 
     Has_table_booking, 
    COUNT(*) AS Total_Restaurants,
    AVG(Rating) AS Average_Rating
    
FROM 
    maindata
GROUP BY 
    Has_table_booking
ORDER BY 
    Has_table_booking;
    
   --  List the 10 most popular cuisines
   
   SELECT Cuisines, COUNT(*) AS Restaurant_Count
FROM Maindata
GROUP BY Cuisines
ORDER BY Restaurant_Count DESC
LIMIT 10;









