-- Top & Bottom  Performing Cities 

              -- Top 3

select  dim_city.city_name,sum(fact_passenger_summary.total_passengers) as  Total_Passenger
from fact_passenger_summary
join dim_city
on dim_city.city_id = fact_passenger_summary.city_id	
group by dim_city.city_name
order by Total_Passenger desc
 ;


        -- Bottom 3 
select  dim_city.city_name,sum(fact_passenger_summary.total_passengers) as total_trips
from fact_passenger_summary
join dim_city
on dim_city.city_id = fact_passenger_summary.city_id	
group by dim_city.city_name
order by total_trips asc
limit 3 ;


-- Average Fare and Distance Per Trip by City 

select dim_city.city_name,avg(fact_trips.fare_amount) as Avg_Fare ,avg(fact_trips.distance_travelled) as Avg_Distance
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by dim_city.city_name
;


-- Cities with the Highest avg fare  

select dim_city.city_name,avg(fact_trips.fare_amount) as Avg_Fare 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by dim_city.city_name
order by Avg_Fare desc 
limit 3;

-- Cities with the lowest avg fare 

select dim_city.city_name,avg(fact_trips.fare_amount) as Avg_Fare 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by dim_city.city_name
order by Avg_Fare asc 
limit 3;




                                       -- Driver Rating 
select dim_city.city_name , round(avg(trips_db.fact_trips.driver_rating),2) as driver_rating 
from trips_db.fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by  dim_city.city_name
order by driver_rating   desc;                 













                   -- Passengers Ratings 
                
select dim_city.city_name , round(avg(fact_trips.passenger_rating),2) as passenger_rating 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by  dim_city.city_name
order by passenger_rating   desc;                 

  

                
                
                
                
                
                
                
                
                
                -- Repeated Customers 
select dim_city.city_name , avg(fact_trips.passenger_rating) as avg_psngr_rating 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
where fact_trips.passenger_type = 'repeated'
group by  dim_city.city_name
order by avg_psngr_rating   desc;




                                          -- New Customers 


select dim_city.city_name , avg(fact_trips.passenger_rating) as avg_psngr_rating 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
where fact_trips.passenger_type = 'new'
group by  dim_city.city_name
order by avg_psngr_rating   desc;                 





                              -- New VS Repeated Customer Ratings 
    
SELECT 
    dim_city.city_name, 
   round( AVG(new_customers.avg_psngr_rating),2) AS avg_psngr_rating_new,
    round(AVG(repeated_customers.avg_psngr_rating),2) AS avg_psngr_rating_repeated
FROM dim_city
LEFT JOIN (
    SELECT city_id, AVG(passenger_rating) AS avg_psngr_rating 
    FROM fact_trips
    WHERE passenger_type = 'new'
    GROUP BY city_id
) AS new_customers ON dim_city.city_id = new_customers.city_id
LEFT JOIN (
    SELECT city_id, AVG(passenger_rating) AS avg_psngr_rating 
    FROM fact_trips
    WHERE passenger_type = 'repeated'
    GROUP BY city_id
) AS repeated_customers ON dim_city.city_id = repeated_customers.city_id
GROUP BY dim_city.city_name
ORDER BY avg_psngr_rating_repeated DESC;


                                        -- New VS Repeated Driver  Ratings 


SELECT 
    dim_city.city_name, 
    AVG(new_customers.drv_ratings) AS avg_drv_rating_new,
    AVG(repeated_customers.drv_ratings) AS avg_drv_rating_repeated
FROM dim_city
LEFT JOIN (
    SELECT city_id, AVG(driver_rating) AS drv_ratings 
    FROM fact_trips
    WHERE passenger_type = 'new'
    GROUP BY city_id
) AS new_customers ON dim_city.city_id = new_customers.city_id
LEFT JOIN (
    SELECT city_id, AVG(driver_rating) AS drv_ratings 
    FROM fact_trips
    WHERE passenger_type = 'repeated'
    GROUP BY city_id
) AS repeated_customers ON dim_city.city_id = repeated_customers.city_id
GROUP BY dim_city.city_name;


              --  City with Highest Customer Ratings  
select dim_city.city_name , avg(fact_trips.passenger_rating) as avg_psngr_rating 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by  dim_city.city_name
order by avg_psngr_rating   desc
limit 1;                 

                        -- City with lowest Customer Ratings
                        
                        
select dim_city.city_name , avg(fact_trips.passenger_rating) as avg_psngr_rating 
from fact_trips
join dim_city
on dim_city.city_id = fact_trips.city_id
group by  dim_city.city_name
order by avg_psngr_rating asc
limit 1;  
  
  
  
  --  Weekend vs Weekdays demnad  by city 
  
      -- WEEKEND  Demand 
      
	SELECT 
    dc.city_name,
    COUNT(ft.trip_id) AS total_weekend_trips
FROM 
    trips_db.fact_trips ft
JOIN 
    goodycab.dim_date dd ON ft.date = dd.date
JOIN goodycab.dim_city dc
     ON ft.city_id = dc.city_id
WHERE 
    dd.day_type = 'weekend'
GROUP BY 
    dc.city_name
order by total_weekend_trips desc  ;



                                   -- WEEKDAYS DEMAND 
                  
                  	
     
	SELECT 
    dc.city_name,
    COUNT(ft.trip_id) AS total_weekend_trips
FROM 
    trips_db.fact_trips ft
JOIN 
    goodycab.dim_date dd ON ft.date = dd.date
JOIN goodycab.dim_city dc
     ON ft.city_id = dc.city_id
WHERE 
    dd.day_type = 'Weekday'
GROUP BY 
    dc.city_name
order by total_weekend_trips desc  ;
     
     
                      --  Repeated Passenger frequency % 
     
     SELECT 
    dc.city_name,
    SUM(CASE WHEN drtd.trip_count = 2 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_2_trips,
    SUM(CASE WHEN drtd.trip_count = 3 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_3_trips,
    SUM(CASE WHEN drtd.trip_count = 4 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_4_trips
    ,SUM(CASE WHEN drtd.trip_count = 5 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_5_trips
    ,SUM(CASE WHEN drtd.trip_count = 6 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_6_trips
    ,SUM(CASE WHEN drtd.trip_count = 7 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_7_trips
	,SUM(CASE WHEN drtd.trip_count = 8 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_8_trips
        ,SUM(CASE WHEN drtd.trip_count = 9  THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers_9_trips
            ,SUM(CASE WHEN drtd.trip_count  > 10 THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / NULLIF(SUM(drtd.repeat_passenger_count), 0) AS passengers__10_trips

FROM 
    dim_repeat_trip_distribution drtd
JOIN 
    dim_city dc ON drtd.city_id = dc.city_id
GROUP BY 
    dc.city_name ; 
    
    
    
    
    
    
          -- Evaluate monthly performance against targets for new passengers
SELECT 
    t.city_id,
    c.city_name,
    t.month,
    t.target_new_passengers,
    f.new_passengers,
    (f.new_passengers - t.target_new_passengers) AS performance_difference
FROM 
    targets_db.monthly_target_new_passengers t
JOIN 
    trips_db.fact_passenger_summary f
    ON t.city_id = f.city_id AND t.month = f.month
JOIN 
    trips_db.dim_city c
    ON t.city_id = c.city_id
ORDER BY 
    t.city_id, t.month;









            -- Evaluate monthly performance against targets for total trips
SELECT 
    t.city_id,
    c.city_name,
    t.month,
    t.total_target_trips,
    COALESCE(trip_counts.total_trips, 0) AS total_trips, -- Handle cases where no trips occurred
    (COALESCE(trip_counts.total_trips, 0) - t.total_target_trips) AS performance_difference
FROM 
    targets_db.monthly_target_trips t
JOIN 
    trips_db.dim_city c
    ON t.city_id = c.city_id
LEFT JOIN (
    -- Aggregate total trips from fact_trips
    SELECT 
        city_id, 
        DATE_FORMAT(date, '%Y-%m-01') AS month,
        COUNT(*) AS total_trips
    FROM 
        trips_db.fact_trips
    GROUP BY 
        city_id, DATE_FORMAT(date, '%Y-%m-01')
) trip_counts
    ON t.city_id = trip_counts.city_id AND t.month = trip_counts.month
ORDER BY 
    t.city_id, t.month;


                            -- Evaluate monthly performance against targets for total trips

                                        -- Targeted  New Passenger Vs  Actual Passenger 
select 
targets_db.monthly_target_new_passengers.month,
 trips_db.fact_passenger_summary.city_names,
 targets_db.monthly_target_new_passengers.target_new_passengers,
 trips_db.fact_passenger_summary.new_passengers
 from targets_db.monthly_target_new_passengers
 inner join trips_db.fact_passenger_summary
 on targets_db.monthly_target_new_passengers.month = trips_db.fact_passenger_summary.month
 and targets_db.monthly_target_new_passengers.city_id = trips_db.fact_passenger_summary.city_id 
 ;


                                        
                                        -- Targeted  PR  VS Actual PR 

SELECT trips_db.fact_trips.city_names ,
 targets_db.city_target_passenger_rating.target_avg_passenger_rating,
round(avg(passenger_rating),2) as Passenger_rating 
 FROM trips_db.fact_trips
 join targets_db.city_target_passenger_rating
  on trips_db.fact_trips.city_id =  targets_db.city_target_passenger_rating.city_id
  group by  trips_db.fact_trips.city_names, targets_db.city_target_passenger_rating.target_avg_passenger_rating
  ;





                                    -- Top RPR% Cities 
                                    
SELECT 
    city_name,
    (SUM(repeat_passenger_count) / total_repeat_passengers.total_count * 100) AS RPR
FROM 
    goodycab.dim_repeat_trip_distribution d
JOIN (
    -- Subquery to calculate the total repeat passenger count
    SELECT 
        SUM(repeat_passenger_count) AS total_count
    FROM 
        goodycab.dim_repeat_trip_distribution
) total_repeat_passengers
WHERE 
    repeat_passenger_count IS NOT NULL
GROUP BY 
    city_name, total_repeat_passengers.total_count
ORDER BY 
    RPR DESC
LIMIT 2;


                                               --  Lowest RPR Cities 

SELECT 
    city_name,
    (SUM(repeat_passenger_count) / total_repeat_passengers.total_count * 100) AS RPR
FROM 
    goodycab.dim_repeat_trip_distribution d
JOIN (
    -- Subquery to calculate the total repeat passenger count
    SELECT 
        SUM(repeat_passenger_count) AS total_count
    FROM 
        goodycab.dim_repeat_trip_distribution
) total_repeat_passengers
WHERE 
    repeat_passenger_count IS NOT NULL
GROUP BY 
    city_name, total_repeat_passengers.total_count
ORDER BY 
    RPR ASC
LIMIT 2;



                     -- RPR% Month Wise 
		

  SELECT 
    month_names,
    (SUM(repeat_passenger_count) / total_repeat_passengers.total_count * 100) AS RPR
FROM 
   trips_db.dim_repeat_trip_distribution d
JOIN (
    -- Subquery to calculate the total repeat passenger count
    SELECT 
        SUM(repeat_passenger_count) AS total_count
    FROM 
        trips_db.dim_repeat_trip_distribution
) total_repeat_passengers
WHERE 
    repeat_passenger_count IS NOT NULL
GROUP BY 
    month_names, total_repeat_passengers.total_count
ORDER BY 
    RPR desc
;
        






     