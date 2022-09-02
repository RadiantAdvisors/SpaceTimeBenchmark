\timing on
\pset pager 0
\o Queries_50M.log


\echo "Executing Spatial Queries"
\echo "========================="

\echo "creating view for 50m biketrips"

DROP VIEW biketrips;

CREATE OR REPLACE VIEW biketrips
 AS
 SELECT * FROM biketrips50m;

ALTER TABLE biketrips OWNER TO postgres;

DROP VIEW max_temp;

CREATE OR REPLACE VIEW max_temp
 AS
 SELECT * FROM max_temp_50m;

ALTER TABLE biketrips OWNER TO postgres;

\echo "1.2. Geo Filter: Count the rides originating in the polygon"
	SELECT
	COUNT(*)
	FROM bikeTrips t, GIANT_POLYGONS b
	where  b.id='4' and 
	 ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't';

	
\echo "1.3 Filter + SUM: SUM the length of the rides originating in the polygon"
	 SELECT
	  sum(trunc((EXTRACT(EPOCH FROM stoptime) - EXTRACT(EPOCH FROM starttime))/60)) as total_ridetimes_w_4_as_origin
	FROM bikeTrips t, GIANT_POLYGONS b
	WHERE ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	AND b.id = '4';


\echo "1.4. Geojoin: Find all the rides originating and ending in the polygon(Check with Matt & Dipti)"

	SELECT
	  count(*)
	FROM bikeTrips t
	JOIN GIANT_POLYGONS b ON
	  ST_INTERSECTS(st_point(t.start_station_longitude,t.start_station_latitude), b.wkt) = 't'
	JOIN GIANT_POLYGONS c ON
	  ST_INTERSECTS(st_point(t.end_station_longitude, t.end_station_latitude), c.wkt) = 't'
	;

\echo "1.5 Geojoin + Count: Count all the rides originating and ending in the polygon"

	SELECT 
	  COUNT(*), 
	  xy.start_polygon_id,
	  xy.end_polygon_id
	FROM 
	  (
		SELECT
		  t.*,
		  b.id as start_polygon_id,
		  c.id as end_polygon_id
		FROM bikeTrips t
		JOIN GIANT_POLYGONS b ON
		  ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
		JOIN GIANT_POLYGONS c ON
		  ST_INTERSECTS(ST_Point(t.end_station_longitude, t.end_station_latitude), c.wkt) = 't'
		) xy
	GROUP BY xy.start_polygon_id, xy.end_polygon_id;



\echo "Executing Graph Queries"
\echo "======================="

	UPDATE ny_roads
	SET maxspeed = 25
	WHERE maxspeed = 0;

\echo "-- Create batch solve input"

	drop table batch_solve_input;
	CREATE TABLE batch_solve_input AS
	SELECT * FROM bikeTrips 
	WHERE starttime > '2020-12-20' AND starttime < '2020-12-21'
	ORDER BY starttime;

\echo "2.2 Graph Solve + Aggregation: Find the length of the shortest route from the Empire State Building to the Brooklyn Bridge Kinetica graph"

SELECT osm_id, node, edge, cost as cost, agg_cost
FROM pgr_dijkstra(
   'SELECT osm_id as id, source, target, st_length(wkt, true) as cost FROM ny_roads_graph',
   (SELECT source FROM ny_roads_graph
  ORDER BY ST_Distance(
	ST_StartPoint(wkt),
	ST_GeomFromText('POINT(-73.9982422 40.7071839)',4326),
	true
  ) ASC
  LIMIT 1),
   (SELECT source FROM ny_roads_graph
	ORDER BY ST_Distance(
		ST_StartPoint(wkt),
		ST_GeomFromText('POINT(-73.994485 40.7042092)',4326),
		true
   ) ASC
   LIMIT 1),FALSE
) as pt
JOIN ny_roads_graph rd ON pt.edge = rd.osm_id;

\echo "2.2_1 Graph Solve + Aggregation: Find the length of the shortest route from the Empire State Building to the Brooklyn Bridge PostGIS graph"

SELECT osm_id, node, edge, cost as cost, agg_cost
FROM pgr_dijkstra(
   'SELECT osm_id as id, source, target, st_length(wkt, true) as cost FROM ny_roads_graph_test',
   (SELECT source FROM ny_roads_graph_test
  ORDER BY ST_Distance(
	ST_StartPoint(wkt),
	ST_GeomFromText('POINT(-73.9982422 40.7071839)',4326),
	true
  ) ASC
  LIMIT 1),
   (SELECT source FROM ny_roads_graph_test
	ORDER BY ST_Distance(
		ST_StartPoint(wkt),
		ST_GeomFromText('POINT(-73.994485 40.7042092)',4326),
		true
   ) ASC
   LIMIT 1),FALSE
) as pt
JOIN ny_roads_graph_test rd ON pt.edge = rd.osm_id;

\echo"2.3 Graph Batch Solve: Find the shortest path for all trips taken on 12/20/2020 (~16k Trips)"

	SELECT 
	  ST_AsText(source), ST_AsText(target), SUM(ST_LENGTH(PATH))*100000 as route_length
	FROM  batch_solve_output
	GROUP BY source, target
	ORDER BY route_length desc;
	
\echo"Executing Temporal Queries"
\echo"=========================="
\echo "3.2 AS OF Join: Join the bike events to the temperature readings based on AS OF join within a defined interval (I.e. +/- 1 hour)"

	SELECT
	  e.airtemp, t.*,
	  e.sensor_id,
	  e.dt as event_dt
	FROM
	  bikeTrips t
	left outer JOIN  MAX_TEMP m
		ON t.starttime = m.st_time
	JOIN temperature e
	ON t.starttime=e.dt
	ORDER BY  e.airtemp DESC;

\echo"3.3 Time Filter: Count all events that occurred between two given date times that intersect with the polygon"

	SELECT COUNT(*) FROM bikeTrips t 
	JOIN GIANT_POLYGONS b 
	  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	  WHERE t.starttime > '2020-12-20 00:00:00' 
	  AND t.starttime < '2020-12-21 00:00:00';
	  
\echo"3.4 Window Function: For every ride, find the moving demand over 10 min sliding window "

	SELECT
	  starttime,
	  start_station_id,
	  bikeid,
	  COUNT(*) OVER (
		ORDER BY EXTRACT(EPOCH FROM starttime)
		RANGE BETWEEN 300000 PRECEDING AND 300000 FOLLOWING
	  ) AS trip_demand
	FROM bikeTrips
		WHERE starttime >= '2020-12-20 00:00:00' AND starttime <'2020-12-21 00:00:00'
	ORDER BY
	  starttime;

\echo "3.5 Geo-Temporal: AS-OF + Geo filter (Get the temperature within an hour of the ride starting in the given polygon."
\echo "Count the number of trips that started in the given polygon where the temp was above 60 degrees."

	SELECT COUNT(*)
	FROM 
	  (
		SELECT
		  e.airtemp, t.*,
		  e.sensor_id,
		  e.dt as event_dt
		FROM
		  bikeTrips t
		left outer JOIN  MAX_TEMP m
			ON t.starttime = m.st_time
		JOIN temperature e
		ON t.starttime=e.dt) ride_t,
	  GIANT_POLYGONS b
	WHERE 
	  ST_INTERSECTS(ST_Point(ride_t.start_station_longitude, ride_t.start_station_latitude), b.wkt) = 't'
	  AND b.id = '4'
	  AND  ride_t.airtemp > 60;
  
\echo"3.6 Window + Geo Filter: Find the demand of trips for a particular day that fell within the GIANT_POLYGON"

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
	  FROM bikeTrips t,
		   GIANT_POLYGONS b
	  WHERE 
		t.starttime >= '2020-12-20' AND t.starttime <'2020-12-21'
		AND ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt)='t'
		AND b.id = '4'
	) tmp
	GROUP BY extract(hour from starttime)
	ORDER BY   1 ;

\echo "3.7 Geo-Join + Temporal Filter: Join events to boundaries where the trip duration was less than 10 minutes"

	SELECT
	t.*,
	b.id
	FROM bikeTrips t 
	JOIN GIANT_POLYGONS b 
	ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	WHERE t.starttime > '2020-12-20' AND t.starttime < '2020-12-21';
	
\echo"Find the minimum and maximum timestamp of the station status for each station"

	SELECT station_id, MIN(dt) start_dt, MAX(dt) mdt
	FROM station_status 
	GROUP BY station_id;
	
\echo"Query the total capacity of each station"

	select station_id, MAX(capacity) cap
	from station_info
	GROUP BY station_id
	ORDER BY station_id;
	
\echo"Create necessary views to calculate linear regression values of bikes demand at docking stations over time."

	DROP MATERIALIZED VIEW if exists station_capacity CASCADE;
	CREATE  MATERIALIZED VIEW station_capacity AS
	select station_id, MAX(capacity) cap
	from station_info
	GROUP BY station_id
	ORDER BY station_id;

	DROP MATERIALIZED VIEW if exists data_start_info CASCADE;
	CREATE MATERIAlIZED VIEW data_start_info
	AS 
	SELECT station_id, MIN(dt) start_dt, MAX(dt) mdt
	FROM station_status 
	GROUP BY station_id;
		
	DROP MATERIALIZED VIEW if exists regression_view cascade;
	CREATE  MATERIALIZED VIEW regression_view 
	AS SELECT CAST(REGR_INTERCEPT((s1.cap - s2.num_bikes_available), EXTRACT(EPOCH FROM s2.dt) - EXTRACT(EPOCH FROM s3.start_dt)) AS DECIMAL) as b, 
			  CAST(REGR_SLOPE((s1.cap - s2.num_bikes_available), EXTRACT(EPOCH FROM s2.dt) - EXTRACT(EPOCH FROM s3.start_dt)) AS DECIMAL) as a, 
			  s1.station_id, MAX(s1.cap) as cap
	FROM station_capacity s1, station_status s2, data_start_info s3
	WHERE s1.station_id = s2.station_id AND s3.station_id = s1.station_id
	GROUP BY s1.station_id
	ORDER BY s1.station_id;
	
\echo"Create view to calculate bikes demand at docking stations over time."

	DROP MATERIALIZED VIEW if exists streaming_station_demand;
	CREATE MATERIALIZED VIEW streaming_station_demand
		AS   SELECT (CONCAT ( CONCAT ('Demand exceeded at  station ', CONCAT(STATION_ID, ' at time ')),  CAST(time_of_demand AS CHAR) ) ) as  payload, * 
		FROM 
		(
		SELECT  ROUND((r.b + (r.a * CAST((EXTRACT(EPOCH FROM s2.dt) - EXTRACT(EPOCH FROM s3.start_dt)) AS DECIMAL )))) as bike_demand, s2.station_id, s2.num_bikes_available, s2.dt time_of_demand, r.b, r.a,
				EXTRACT(EPOCH FROM s2.dt) - EXTRACT(EPOCH FROM s3.start_dt) as x, s3.start_dt, r.cap
		FROM  station_status s2, regression_view r, data_start_info s3 
		WHERE s2.station_id = r.station_id AND  s3.station_id = r.station_id
		)t ;

/q
