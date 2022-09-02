-- 3.2 AS OF Join: Join the bike events to the temperature readings based on AS OF join within a defined interval (I.e. +/- 1 hour)

SELECT 
  e.airtemp, t.*,
  sensor_id,
  e.dt as event_dt
FROM 
  bikeTrips t
LEFT JOIN
  temperature e
    ON ASOF(t.starttime, e.dt, INTERVAL '-1' HOUR, INTERVAL '1' HOUR, MAX)
ORDER BY  e.airtemp DESC

Number of Records: 10000, Completed in 0.16925 seconds


-- Notes about ASOF Function
https://docs.kinetica.com/7.0/concepts/sql.html?highlight=asof#asof

ASOF FUNCTION

Kinetica supports the notion of an inexact match join via the ASOF join function. This feature allows each left-side table record to be matched to a single right-side table record whose join column value is the smallest or largest value within a range relative to the left-side join column value. In the case where multiple right-side table records have the same smallest or largest value for a given left-side table record, only one of the right-side table records will be chosen and returned as part of the join.

The format of the ASOF function is as follows:

ASOF(<left_column>, <right_column>, <rel_range_begin>, <rel_range_end>, <MIN|MAX>)

The five parameters are:

left_column - name of the column to join on from the left-side table
right_column - name of the column to join on from the right-side table
rel_range_begin - constant value defining the position, relative to each left-side column value, of the beginning of the range in which to match right-side column values; use a negative constant to begin the range before the left-side column value, or a positive one to begin after it
rel_range_end - constant value defining the position, relative to each left-side column value, of the end of the range in which to match right-side column values; use a negative constant to end the range before the left-side column value, or a positive one to end after it
MIN|MAX - use MIN to return the right-side matched record with the smallest join column value; use MAX to return the right-side matched record with the greatest join column value
Effectively, each matched right-side column value must be:

>= <left-side column value> + rel_range_begin
<= <left-side column value> + rel_range_end
Within the set of right-side matches for each left-side record, the one with the MIN or MAX column value will be returned in the join. In the case of a tie for the MIN or MAX column value, only one right-side record will be selected for return in the join for that left-side record.

https://docs.kinetica.com/7.0/concepts/sql.html?highlight=asof#asof

-- End of the note section!

PostGIS:

create table temp  as 
SELECT 
  e.airtemp, t.*,   sensor_id,
  e.dt as event_dt
FROM 
  bikeTrips10m t
LEFT OUTER JOIN
  temperature e
    ON t.starttime=e.dt
	--where t.starttime > t.starttime - INTERVAL '1 HOURS'  AND t.starttime <= t.starttime + INTERVAL '1 HOURS'
	where e.dt > e.dt - INTERVAL '1 HOURS'  AND e.dt <= e.dt + INTERVAL '1 HOURS'
	

SELECT 
  e.airtemp, t.*,
  sensor_id,
  e.dt as event_dt
FROM bikeTrips10m t 
LEFT OUTER JOIN temperature e
    ON t.starttime=e.dt
	--ASOF(t.starttime, e.dt, INTERVAL '-1' HOUR, INTERVAL '1' HOUR, MAX)
	where t.starttime > t.starttime - INTERVAL '1 HOURS'  AND t.starttime <= t.starttime + INTERVAL '1 HOURS'
	and t.starttime in (select min(event_dt) from temp)
	ORDER BY  e.airtemp DESC


OmniSCI:

Not yet tested.


-- 3.3 Time Filter: Count all events that occurred between two given date times that intersect with the polygon

SELECT
COUNT(*)
FROM bikeTrips t 
JOIN GIANT_POLYGONS b 
  ON STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
WHERE t.starttime > '2020-12-20' 
  AND t.starttime < '2020-12-21';
  
Output - 0

PostGIS:

SELECT COUNT(*) FROM bikeTrips10m t 
JOIN GIANT_POLYGONS b 
  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
  WHERE t.starttime > '2020-12-20 00:00:00' 
  AND t.starttime < '2020-12-21 00:00:00';

Timestamp value is changed and added 00:00:00
Ouput - 0

OmniSCI:

SELECT COUNT(*) FROM bikeTrips10m t 
JOIN GIANT_POLYGONS b 
  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
  WHERE t.starttime > '2020-12-20 00:00:00' 
  AND t.starttime < '2020-12-21 00:00:00';
  
Ouput - 0


  
--3.4 Window Function: For every ride, find the moving demand over 10 min sliding window

Kinetica:

SELECT
  starttime,
  start_station_id,
  bikeid,
  COUNT(*) OVER (
    ORDER BY LONG(starttime)
    RANGE BETWEEN 300000 PRECEDING AND 300000 FOLLOWING
  ) AS trip_demand
FROM bikeTrips
    WHERE starttime >= '2020-12-20' AND starttime <'2020-12-21'
ORDER BY
  starttime;

Output - 0

PostGIS:

SELECT
  starttime,
  start_station_id,
  bikeid,
  COUNT(*) OVER (
    ORDER BY EXTRACT(EPOCH FROM starttime)
    RANGE BETWEEN 300000 PRECEDING AND 300000 FOLLOWING
  ) AS trip_demand
FROM bikeTrips10m
    WHERE starttime >= '2020-12-20 00:00:00' AND starttime <'2020-12-21 00:00:00'
ORDER BY
  starttime;
  
Output - 0 rows 

Omnsici:

Corrected and working

SELECT start_station_id,bikeid,COUNT(*),
cast(extract(HOUR from starttime) as integer) + ((cast(extract(MINUTE from starttime) as integer) / cast(10 as integer)) * cast(10 as integer)) AS ten_min_timestamp
FROM bikeTrips10m
GROUP BY start_station_id,bikeid,ten_min_timestamp;



-- https://docs-new.omnisci.com/sql/data-manipulation-dml/sql-capabilities
-- Window functions where there are expressions (not simple columns) in the window partition and order clause are not currently supported.

--Linux EPOCH values range from -30610224000 (1/1/1000) through 185542587100800 (1/1/5885487). Complete range in years: +/-5,883,517 around epoch.
--https://docs-new.omnisci.com/sql/data-manipulation-dml/functions-operators
  
Error::: Frame specification not supported
  
-- Debugging note
SELECT bikeid, LONG(STARTTIME) FROM radiant2.bikeTrips10m where bikeid=48358
  
48358 2020-12-10 18:01:30.703
48358 1607623290 703
  
Integer fields are assumed to be seconds since the epoch; long/timestamp fields are assumed to be milliseconds since the epoch.
  
SELECT bikeid, EXTRACT(EPOCH FROM starttime::timestamp) FROM  bikeTrips10m where bikeid='48358';
SELECT bikeid, EXTRACT(EPOCH FROM TIMESTAMP starttime) * 1000 FROM  bikeTrips10m where bikeid='48358';
  
SELECT TIMESTAMP 'epoch' + (starttime::int) * INTERVAL '1 second' as started_on from bikeTrips10m where bikeid='48358';
 
 bikeid |   date_part
--------+----------------
 48358  | 1607623290.703
(1 row)

--end of debugging section


--3.5 Geo-Temporal: AS-OF + Geo filter

Get the temperature within an hour of the ride starting in the given polygon. 
Count the number of trips that started in the given polygon where the temp was above 60 degrees.

SELECT COUNT(*)
FROM 
  (
    SELECT 
          e.airtemp, t.*,
          e.sensor_id as event_id,
          e.dt as event_dt
    FROM bikeTrips t
    LEFT JOIN temperature e ON 
      ASOF(t.starttime, e.dt, INTERVAL '-1' HOUR, INTERVAL '1' HOUR, MAX)
  ) ride_t,
  GIANT_POLYGONS b
WHERE 
  STXY_INTERSECTS(ride_t.start_station_longitude, ride_t.start_station_latitude, b.wkt)
  AND b.id = 4 
  AND  ride_t.airtemp > 60


-- 3.6 Window + Geo Filter: Find the demand of trips for a particular day that fell within the GIANT_POLYGON

SELECT
    RPAD(LPAD(CHAR2(HOUR(starttime)), 2, '0'), 5, ':00') AS "Pickup_Hour", 
    AVG(trip_demand) AS "Average_Demand"
FROM 
(SELECT
  starttime,
  COUNT(*) OVER (
    ORDER BY LONG(t.starttime)
    RANGE BETWEEN 300000 PRECEDING AND 300000 FOLLOWING
  ) AS trip_demand
    FROM bikeTrips t,
       GIANT_POLYGONS b
  WHERE 
    t.starttime >= '2020-12-20' AND t.starttime <'2020-12-21'
    AND STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt)
    AND b.id = 4
)
GROUP BY HOUR(starttime)
ORDER BY
  Pickup_Hour 
  

PostGIS:

SELECT
    extract(hour from starttime) AS "Pickup_Hour", 
    AVG(trip_demand) AS "Average_Demand"
FROM 
(SELECT
  starttime,
  COUNT(*) OVER (
    ORDER BY EXTRACT(EPOCH FROM t.starttime)
    RANGE BETWEEN 300000 PRECEDING AND 300000 FOLLOWING
  ) AS trip_demand
  FROM bikeTrips10m t,
       GIANT_POLYGONS b
  WHERE 
    t.starttime >= '2020-12-20' AND t.starttime <'2020-12-21'
    AND ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt)='t'
    AND b.id = '4'
) tmp
GROUP BY extract(hour from starttime)
ORDER BY   1 ;

Output - 0 rows


OmniSCI:

SELECT
    extract(hour from starttime) AS "Pickup_Hour", 
    AVG(trip_demand) AS "Average_Demand"
FROM 
(SELECT
  starttime,
  COUNT(*) OVER (
    ORDER BY EXTRACT(EPOCH FROM t.starttime)
    -- RANGE BETWEEN 300000 PRECEDING AND 300000 FOLLOWING
	RANGE BETWEEN   first_value(300000) AND last_value(300000)
  ) AS trip_demand
  FROM bikeTrips10m t,
       GIANT_POLYGONS b
  WHERE 
    t.starttime >= '2020-12-20 00:00:00' AND t.starttime <'2020-12-21 00:00:00'
    AND ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt)='t'
    AND b.id = '4'
) tmp
GROUP BY extract(hour from starttime)
ORDER BY 1 ; 



ERROR: Frame specification not supported

select bikeid,extract(hour from starttime) from bikeTrips10m where bikeid='48358';
select RPAD(LPAD(extract(hour from starttime))) from bikeTrips10m where bikeid=48358;

The value PRECEDING and value FOLLOWING cases are currently only allowed in ROWS mode. They indicate that the frame starts or ends with the row that many rows before or after the current row


-- 3.7 Geo-Join + Temporal Filter: Join events to boundaries where the trip duration was less than 10 minutes

Kinetica:

SELECT
  t.*,
  b.id
FROM bikeTrips10m t 
JOIN GIANT_POLYGONS b 
  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
  WHERE t.starttime > '2020-12-20 00:00:00' AND t.starttime < '2020-12-21 00:00:00';

Output - 0 rows

PostGIS:

SELECT
  t.*,
  b.id
FROM bikeTrips10m t 
JOIN GIANT_POLYGONS b 
  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
  WHERE t.starttime > '2020-12-20' AND t.starttime < '2020-12-21';

Output - 0 rows
 
Omnisci:

SELECT
  t.*,
  b.id
FROM bikeTrips10m t 
JOIN GIANT_POLYGONS b 
  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
  WHERE t.starttime > '2020-12-20 00:00:00' AND t.starttime < '2020-12-21 00:00:00';

Output - 0 rows