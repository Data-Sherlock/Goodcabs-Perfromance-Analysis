                        -- Business Request 1
						
                         --   City Level Trip And Summary Report 
                         
 
    SELECT 
    dc.city_name,
    COUNT(ft.trip_id) AS total_trips,
    AVG(ft.fare_amount / ft.distance_travelled_km) AS avg_fare_per_km,
    AVG(ft.fare_amount) AS avg_fare_per_trip,
    (COUNT(ft.trip_id) * 100.0 / 
     (SELECT COUNT(trip_id) FROM trips_db.fact_trips)) AS percentage_contribution_to_total_trips
FROM 
    trips_db.fact_trips ft
JOIN 
    trips_db.dim_city dc 
ON 
    ft.city_id = dc.city_id
GROUP BY 
    dc.city_name;
;




             
                            -- Business Request 2
                            
                            
SELECT 
    dc.city_name,
    dd.month_name,  
    COUNT(ft.trip_id) AS actual_trips,
    tt.total_target_trips,
    CASE 
        WHEN COUNT(ft.trip_id) > tt.total_target_trips THEN 'Above Target'
        ELSE 'Below Target'
    END AS performance_stat ,
    ((COUNT(ft.trip_id) - tt.total_target_trips) * 100.0 / tt.total_target_trips) AS percentage_difference
FROM 
    trips_db.fact_trips ft
JOIN 
    trips_db.dim_city dc 
ON 
    ft.city_id = dc.city_id
JOIN 
    trips_db.dim_date dd 
ON 
    ft.date = dd.date  
JOIN 
    targets_db.monthly_target_trips tt 
ON 
    ft.city_id = tt.city_id AND dd.start_of_month = tt.month  -- Ensure correct mapping
GROUP BY 
    dc.city_name, dd.month_name, tt.total_target_trips
LIMIT 0, 1000;

                            
                                                        -- Business Request 3
                                            -- City Level Repaeat Passener Trip Frequency
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
    
                                -- Business Request 4
					-- Cities With The Highest And The Lowest New Passengers 
                                
								-- Top 3
select  city_names , sum(new_passengers) as new_passenger
from  trips_db.fact_passenger_summary
group by city_names
order by new_passenger desc
limit 3;
                              -- Bottom 3
  select  city_names , sum(new_passengers) as new_passenger
from  trips_db.fact_passenger_summary
group by city_names
order by new_passenger asc
limit 3;                            
                                              
                                                -- Business Request 4
                                                -- Month With Highest Revenue For Each City

WITH RevenuePerCityMonth AS (
    SELECT 
        dc.city_name,
        dd.month_name,
        SUM(ft.fare_amount) AS total_revenue
    FROM 
        trips_db.fact_trips ft
    JOIN 
        trips_db.dim_city dc ON ft.city_id = dc.city_id
    JOIN 
        trips_db.dim_date dd ON ft.date = dd.start_of_month
    GROUP BY 
        dc.city_name, dd.month_name
)
SELECT 
    city_name,
    month_name,
    total_revenue
FROM (
    SELECT 
        city_name,
        month_name,
        total_revenue,
        RANK() OVER (PARTITION BY city_name ORDER BY total_revenue DESC) AS revenue_rank
    FROM 
        RevenuePerCityMonth
) AS ranked
WHERE revenue_rank = 1
ORDER BY 
    city_name
;




                                       -- Business Request 6
                                   -- Repaeat Passenger Rate Analysis                                     
SELECT 
    dc.city_name,
    dd.month_name,
    SUM(fps.repeat_passengers) AS repeat_passengers,
    SUM(fps.total_passengers) AS total_passengers,
    (SUM(fps.repeat_passengers) * 100.0 / SUM(fps.total_passengers)) AS repeat_passenger_rate
FROM 
    trips_db.fact_passenger_summary fps
JOIN 
    trips_db.dim_city dc 
ON 
    fps.city_id = dc.city_id
JOIN 
    trips_db.dim_date dd 
ON 
    fps.month = dd.start_of_month
GROUP BY 
    dc.city_name, dd.month_name
ORDER BY 
    repeat_passenger_rate DESC;