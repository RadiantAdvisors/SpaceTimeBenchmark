/***************************************Data Loading Queries ************************************/
1.1 Data Preparation: Create the GIANT_POLYGON table from the border of Queens borough. ~29k vertices.

1) Creating Data Source

	Kinetica:
	CREATE OR REPLACE DATA SOURCE benchmark_ds
	LOCATION = 'S3'
	WITH OPTIONS (
	ANONYMOUS = true,
	BUCKET NAME = 'quickstartpublic',
	REGION = 'us-east-1'
	);

	PostGIs:

	Extension Available to Load data from S3 to PostGISDB.
	Link: https://medium.com/analytics-vidhya/easily-load-data-from-an-s3-bucket-into-postgres-using-the-aws-s3-extension-17610c660790

	Note: Data downloaded to local disk and loaded to PostgisDB to reduce the ingestion latency

	OmniSciDB:

	Ingest AWS S3 Data via Omnisql is possible.
	https://www.heavy.ai/blog/unlocking-the-power-of-aws-open-data-with-omnisci?utm_source=twitter&utm_medium=social&utm_campaign=twittersocial&utm_content=omnisci-social

	Note: Data downloaded to local disk and loaded to OmnisciDB to reduce the ingestion latency

2) Creating NYCT2010 table from datasource

	Kinetica:
	DROP TABLE IF EXISTS nyct2010;

	LOAD INTO nyct2010
	FROM FILE PATHS 'spatialbenchmark/nyct2010.csv'
	WITH OPTIONS (
	DATA SOURCE = 'benchmark_ds'
	);

	Advantage: Table creation & column dattypes will be automatically defined form the data.

	PostGIS:

	Table has to be created before loading the data. Data loading done using copy command.

	OmniSCIDB:

	Table has to be created before loading the data. Data loading done using copy command.

3) GIANT_POLYGONS table creation for Manhattan & Queens area.

	Kinetica:

	CREATE OR REPLACE REPLICATED TABLE GIANT_POLYGONS AS
	SELECT
	ST_DISSOLVE(geom) as wkt,
	BoroCode as id
	FROM nyct2010
	WHERE BoroName = 'Queens' OR BoroName = 'Manhattan'
	GROUP BY BoroCode;

	PostGIS: ST_UNION can be used instead of ST_DISSOLVE function in postGIS
	
		CREATE TABLE GIANT_POLYGONS_temp AS
	SELECT
		ST_UNION(geom) as wkt,
		BoroCode as id
	FROM nyct2010
	WHERE BoroName = 'Queens' OR BoroName = 'Manhattan'
	GROUP BY BoroCode;
	
	Note: Data loaded from kinetica for testing.
	
	OmniSCIDB:
	
	Data loaded from Kinetica into OmnisciDB. As per GITHUB doc, ST_UNION function is available from 5.2 version.
	OGC full "simple features" constructive geospatial operators (ST_Buffer, ST_Intersects, ST_Union, etc) (Completed 5.2+)
	
	Link:https://github.com/heavyai/heavydb/blob/master/ROADMAP.md

4) Biketrips10M data loading

	Kinetica: 11998049

	LOAD INTO bikeTrips10m
	FROM FILE PATHS 'spatialbenchmark/10million-Rides/'
	WITH OPTIONS (
		DATA SOURCE = 'benchmark_ds'
	);

	PostGIS: 11998049
	
		--Downloaded S3 files and ran below command to load the data to PostGIS.

		copy Biketrips10m FROM 'C:\Balaji\BM_Project\Data\10million-Rides\*.csv' DELIMITERS ',' CSV HEADER;	

	OmniSCiDB : 11998049

		--Downloaded S3 files and ran below command to load the data to Omnisci.
		
		COPY bikeTrips10m FROM '/tmp/data/202012-citibike-tripdata.csv.txt.csv';
		COPY bikeTrips10m FROM '/tmp/data/202011-citibike-tripdata.csv.txt.csv';
		COPY bikeTrips10m FROM '/tmp/data/202010-citibike-tripdata.csv.txt.csv';
		COPY bikeTrips10m FROM '/tmp/data/202009-citibike-tripdata.csv.txt.csv';
		COPY bikeTrips10m FROM '/tmp/data/202008-citibike-tripdata.csv.txt.csv';
		COPY bikeTrips10m FROM '/tmp/data/202007-citibike-tripdata.csv.txt.csv';
	

5) Creating a logical view for bikeTrips10m

	Kinetica:

	CREATE OR REPLACE LOGICAL VIEW bikeTrips as SELECT * from bikeTrips10m

	PostGISDB:

	CREATE OR REPLACE VIEW bikeTrips as SELECT * from bikeTrips10m

	OmniSCiDB: 

	CREATE VIEW bikeTrips as SELECT * from bikeTrips10m

6) ny_roads table data loading

	Kinetica Count : 1174853

	PostGIS: 1174853
	
	copy ny_roads FROM 'C:\Balaji\BM_Project\Data\10million-Rides\ny_roads.csv' DELIMITERS ',' CSV HEADER;
	
	Omnisci: 1174853
	
	COPY ny_roads FROM '/tmp/data/ny_roads.csv';
	

7) Loading Temperature data (spatialbenchmark/nyc_temperature.csv)

	Kinetica Count : 2097150

	-- Load the NYC Temperature data
	DROP TABLE IF EXISTS temperature;

	LOAD INTO temperature
	FROM FILE PATHS 'spatialbenchmark/nyc_temperature.csv'
	WITH OPTIONS (
		DATA SOURCE = 'benchmark_ds'
	);

	CREATE OR REPLACE REPLICATED TABLE temp_final AS
	SELECT 
	   "Sensor.ID" as sensor_id,
	   CONVERT(t.day, DATETIME) as dt,
	   hour,
	   airtemp,
	   latitude,
	   longitude,
	   "Install.Type" as install_type,
	   borough,
	   ntacode
	FROM temperature t;

	UPDATE temp_final
	SET dt = DATEADD(HOUR, hour, dt);

	UPDATE temp_final
	SET dt = dateadd(year, (2020 - year(dt)), dt) ;

	ALTER TABLE temp_final
	DROP COLUMN hour;

	DROP TABLE temperature;

	ALTER TABLE temp_final
	RENAME TO temperature;
	
	PostGIS: 2097150 , Date_add function not available in PostGIS. Used other date functions as workaround.
	
	copy Temperature FROM 'C:\Balaji\BM_Project\Data\nyc_temperature.csv' DELIMITERS ',' CSV HEADER;

	CREATE TABLE temp_final AS
	SELECT 
	  sensor_id,
	   (t.day::timestamp) as dt,
	   hour,
	   airtemp,
	   latitude,
	   longitude,
	   install_type,
	   borough,
	   ntacode
	FROM temperature t;

	
	-- select dt,dt + (hour * interval '1 hour') from temp_final
	UPDATE temp_final SET dt = dt + (hour * interval '1 hour');

	--select dt,'2020-' || to_char(dt,'MM-DD HH24:MI:SS') from temp_final
	-- select dt,TO_TIMESTAMP('2020-' || to_char(dt,'MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') from temp_final

	UPDATE temp_final SET dt = TO_TIMESTAMP('2020-' || to_char(dt,'MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS');
	
	select to_char(dt,'YYYY'),count(*) from temp_final group by to_char(dt,'YYYY');
	
	ALTER TABLE temp_final DROP COLUMN hour;
	
	DROP TABLE temperature;
	ALTER TABLE temp_final RENAME TO temperature;

	OmniSCiDB:
	
	
	Omnisci: 2097150 
	
		CREATE TABLE "temperature"
		(
		   "Sensor_ID" TEXT NOT NULL,
		   "AirTemp" DOUBLE,
		   "Day" date NOT NULL,
		   "Hour" INTEGER NOT NULL,
		   "Latitude" DOUBLE NOT NULL,
		   "Longitude" DOUBLE NOT NULL,
		   "Year" INTEGER NOT NULL,
		   "Install_Type" TEXT NOT NULL,
		   "Borough" TEXT NOT NULL,
		   "ntacode" TEXT NOT NULL
		);

		COPY temperature FROM '/tmp/data/nyc_temperature.csv';

		CREATE TABLE temp_final AS
		SELECT 
		  sensor_id,
		   cast("day" as timestamp) as dt,
		   "hour",
		   airtemp,
		   latitude,
		   longitude,
		   install_type,
		   borough,
		   ntacode
		FROM temperature t;

	-- select dt,dt+("hour" * interval '1' hour) from temp_final
	UPDATE temp_final SET dt = dt + ("hour" * interval '1' hour);

    -- select dt,dateadd(year, (2020 - extract (year from dt)), dt) from temp_final limit 1
	UPDATE temp_final SET dt = dateadd(year, (2020 - extract (year from dt)), dt);
	
	select extract(year from dt),count(*) from temp_final group by extract(year from dt);
	
	ALTER TABLE temp_final DROP COLUMN "hour";
	
	DROP TABLE temperature;
	ALTER TABLE temp_final RENAME TO temperature;
	
	
/******************************************** Spatial Queries *************************************************************/

SPATIAL QUERIES:
================

1.2. Geo Filter: Count the rides originating in the polygon

	Kinetica:476822

	SELECT
	  COUNT(*)
	FROM bikeTrips t, GIANT_POLYGONS b
	WHERE 
	  b.id = 4 AND
	  STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1;
	  
	PostGIS:476822
		SELECT
		COUNT(*)
		FROM bikeTrips10m t, GIANT_POLYGONS b
		where  b.id='4' and 
		 ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't';

	OmniSCiDB:

	SELECT
	COUNT(*)
	FROM bikeTrips10m t, GIANT_POLYGONS b
	where  b.id='4' and 
	 ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't';
	 

1.3 Filter + SUM: SUM the length of the rides originating in the polygon


	 Kinetica : 10970194

	 SELECT
		  SUM(TIMESTAMPDIFF(MINUTE, starttime, stoptime)) as total_ridetimes_w_4_as_origin
		FROM bikeTrips t, GIANT_POLYGONS b
		WHERE STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
		AND b.id = 4;
	 
	 PostGIS  : 10970194 Extract(epoch) function is used instead of timestampdiff,ST_INTERSECTS function instead of stxy_intersects function
	 
	 --old query has some minor difference in output due to date function
	 SELECT
	  sum( 
	  (DATE_PART('hour',stoptime::timestamp) * 60  + DATE_PART('minute',stoptime)) 
	  -  
	  ( DATE_PART('hour',starttime::timestamp) * 60 + DATE_PART('minute',starttime)) 
	  ) as total_ridetimes_w_4_as_origin
	FROM bikeTrips10m t, GIANT_POLYGONS b
	WHERE ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	AND b.id = '4';

	--new query
	 SELECT
	  sum(trunc((EXTRACT(EPOCH FROM stoptime) - EXTRACT(EPOCH FROM starttime))/60)) as total_ridetimes_w_4_as_origin
	FROM bikeTrips10m t, GIANT_POLYGONS b
	WHERE ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	AND b.id = '4';

	/****************PDV Query *******************/

	SELECT
		bikeid,start_station_id,stoptime,starttime,trunc((EXTRACT(EPOCH FROM stoptime) - EXTRACT(EPOCH FROM starttime))/60)  as diff
	FROM bikeTrips10m t, GIANT_POLYGONS b
	where  b.id='4' and 
	 ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	 and t.bikeid='43964' and t.start_station_id='3526'
	 
	/*************** *******************/
	
	OmniSCiDB:      ST_INTERSECTS function instead of stxy_intersects function
	
	SELECT
	  SUM(TIMESTAMPDIFF(MINUTE, starttime, stoptime)) as total_ridetimes_w_4_as_origin
	FROM bikeTrips10m t, GIANT_POLYGONS b
	WHERE ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	AND b.id = '4';

***1.4. Geojoin: Find all the rides originating and ending in the polygon(Check with Matt & Dipti)

	Kinetica Query has error: Group by clause needs to be removed

	Kinetica : 9058232
	PostGIS:   
	
	
	SELECT
	  count(*)
	FROM bikeTrips t
	JOIN GIANT_POLYGONS b ON
	  ST_INTERSECTS(st_point(t.start_station_longitude,t.start_station_latitude), b.wkt) = 't'
	JOIN GIANT_POLYGONS c ON
	  ST_INTERSECTS(st_point(t.end_station_longitude, t.end_station_latitude), c.wkt) = 't'
	;

	PostGIS:
	
	OmniSCIDB:

1.5 Geojoin + Count: Count all the rides originating and ending in the polygon

	Kinetica:
	
		SELECT 
		  COUNT(*), 
		  start_polygon_id,
		  end_polygon_id
		FROM 
		  (
			SELECT
			  t.*,
			  b.id as start_polygon_id,
			  c.id as end_polygon_id
			FROM bikeTrips t
			JOIN GIANT_POLYGONS b ON
			  STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
			JOIN GIANT_POLYGONS c ON
			  STXY_INTERSECTS(t.end_station_longitude, t.end_station_latitude, c.wkt) = 1
			)
		GROUP BY start_polygon_id, end_polygon_id;
	
		OUTPUT:
		EXPR_0		start_polygon_id		end_polygon_id
			65794       4                       1
			70044       1                       4
			347324      4                       4
			8575070     1                       1

		PostGIS:ST_INTERSECTS function instead of STXY_INTERSECTS

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
			FROM bikeTrips10m t
			JOIN GIANT_POLYGONS b ON
			  ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
			JOIN GIANT_POLYGONS c ON
			  ST_INTERSECTS(ST_Point(t.end_station_longitude, t.end_station_latitude), c.wkt) = 't'
			) xy
		GROUP BY xy.start_polygon_id, xy.end_polygon_id;
	
		OUTPUT:
		8575070	"1"	"1"
		70044	"1"	"4"
		65794	"4"	"1"
		347324	"4"	"4"

	OmniSCIDB:
	
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
		FROM bikeTrips10m t
			JOIN GIANT_POLYGONS b ON
		  CAST(ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) AS INTEGER) = 1
		JOIN GIANT_POLYGONS c ON
		  CAST(ST_INTERSECTS(ST_Point(t.end_station_longitude, t.end_station_latitude), c.wkt) AS INTEGER) = 1
		) xy
	GROUP BY xy.start_polygon_id, xy.end_polygon_id;

/********************************** Graph Queries ***********************************/

2.1 Graph Creation

	Kinetica:1122004

	-- Fix missing speed limits

	UPDATE ny_roads
	SET maxspeed = 25
	WHERE maxspeed = 0;

	PostGIS:1122004
	-- Fix missing speed limits

	UPDATE ny_roads
	SET maxspeed = 25
	WHERE maxspeed = 0;
	
	OmniSCIDB:
	
	UPDATE ny_roads
	SET maxspeed = 25
	WHERE maxspeed = 0;

	--Creating Graph table with Edges & Nodes
	Kinetica: 

		-- Create OSM Graph
		-- Weights on graph are time based, in hours

		CREATE OR REPLACE GRAPH osm_graph (
		 EDGES => INPUT_TABLE(
			SELECT 
			  r.osm_id AS EDGE_ID, 
			  r.WKT AS EDGE_WKTLINE 
			FROM ny_roads r
		  ),
		  WEIGHTS => INPUT_TABLE(
			SELECT 
			  r.osm_id AS WEIGHTS_EDGE_ID, 
			  ST_LENGTH(r.WKT,1)/(r.maxspeed/2.237) AS WEIGHTS_VALUESPECIFIED -- Converts max speed to meters per second
			FROM ny_roads r
		  ),
		  OPTIONS => KV_PAIRS(
			'enable_graph_draw' = 'true', 
			'recreate' = 'true', 
			'graph_table' = 'ny_roads_graph'
		  )
		);

	PostGIS: create topology is the equivalent command

		CREATE EXTENSION postgis;
		CREATE EXTENSION postgis_topology;
		CREATE EXTENSION pgrouting;

		create table ny_roads_graph as select * from ny_roads;

		ALTER TABLE ny_roads_graph ADD COLUMN source integer;
		ALTER TABLE ny_roads_graph ADD COLUMN target integer;
		CREATE INDEX nyroadsgr_source_idx ON ny_roads_graph (source);
		CREATE INDEX nyroadsgr_target_idx ON ny_roads_graph (target);

		-- Check no duplicates in osm_id column
		select osm_id,count(*) from ny_roads group by osm_id having count(*)>1

		--creating topology
		SELECT pgr_createTopology('ny_roads_graph', 0.0001, 'wkt', 'osm_id');

		Note: Data copied from Kinetica as there were gaps in coordinates. Hence the results were not matching

	OmniSCIDB: Graph queries not supported out of the box.

	-- Create batch solve input
		Kinetica: 16340
		CREATE TABLE batch_solve_input AS
		SELECT * FROM bikeTrips 
		WHERE starttime > '2020-12-20' AND starttime < '2020-12-21'
		ORDER BY starttime;

		PostGIS:16340
			-- Create batch solve input
		CREATE TABLE batch_solve_input AS
		SELECT * FROM bikeTrips 
		WHERE starttime > '2020-12-20' AND starttime < '2020-12-21'
		ORDER BY starttime;

2.2 Graph Solve + Aggregation: Find the length of the shortest route from the Empire State Building to the Brooklyn Bridge

	Kinetica: 2093.9603017510526 coordinates changed in kinetica to match with PostGIS
		SELECT  
			 SUM(ST_LENGTH (wktroute, 1)) as route_length
			FROM TABLE (
			  SOLVE_GRAPH(
				GRAPH => 'osm_graph',
				SOLVER_TYPE => 'SHORTEST_PATH',
				SOURCE_NODES => INPUT_TABLE(
				  SELECT ST_GEOMFROMTEXT('POINT(-73.9982422 40.7071839)') AS NODE_WKTPOINT),
				DESTINATION_NODES => INPUT_TABLE(
				  SELECT ST_GEOMFROMTEXT('POINT(-73.994485 40.7042092)') AS NODE_WKTPOINT),
				OPTIONS => KV_PAIRS(
				  'export_solve_results' = 'true',
				  'output_edge_path' = 'true'
				)
			  )
			);

			PostGIS:458.19658667607655
			
			SELECT osm_id, node, edge, cost as cost, agg_cost
		FROM pgr_dijkstra(
		   'SELECT osm_id, source, target, st_length(wkt, true) as cost FROM ny_roads_graph',
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

NOTE: Will import the data for ny_roads_graph from kinetica to POSTGIS and check

		/**********************Sample Validation Queries *************************/

		SELECT source FROM ny_roads_graph
		ORDER BY ST_Distance(
			ST_StartPoint(wkt),
			ST_GeomFromText('POINT(-73.9857 40.7484)',4326),
			true
		) ASC
		LIMIT 1

		SELECT source FROM ny_roads_graph
		ORDER BY ST_Distance(
			ST_StartPoint(wkt),
			ST_GeomFromText('POINT(-73.9969 40.7061)',4326),
			true
		) ASC
		LIMIT 1

		-- No rows returned
		SELECT * FROM pgr_dijkstra(
			'SELECT osm_id AS ID, source, target, st_length(wkt, true) as cost  FROM ny_roads_graph',
			1240143, 756418
		);

		SELECT osm_id, node, edge, cost as cost, agg_cost
		  FROM pgr_dijkstra(
			'SELECT osm_id, source, target, st_length(wkt, true) as cost FROM ny_roads_graph',
		   1240143, 756418, false, false
		  )

		select * from ny_roads_graph where source=756418
		SELECT ST_AsText(wkt) from ny_roads_graph where source=756418

		SELECT * FROM pgr_dijkstra(
			'SELECT osm_id AS ID, source, target, st_length(wkt, true) as cost  FROM ny_roads_graph',
			756418, 756419
		);

2.3 Graph Batch Solve: Find the shortest path for all trips taken on 12/20/2020 (~16k Trips)

	Kinetica:13311

		DROP TABLE IF EXISTS batch_solve_output;

		EXECUTE FUNCTION SOLVE_GRAPH(
			GRAPH => 'osm_graph', 
			SOLVER_TYPE => 'SHORTEST_PATH', 
			SOURCE_NODES => INPUT_TABLE( 
			  SELECT 
				REMOVE_NULLABLE(start_station_longitude) AS NODE_X, 
				REMOVE_NULLABLE(start_station_latitude) AS NODE_Y 
			  FROM batch_solve_input ), 
			DESTINATION_NODES => INPUT_TABLE( 
			  SELECT 
				REMOVE_NULLABLE(end_station_longitude) AS NODE_X, 
				REMOVE_NULLABLE(end_station_latitude) as NODE_Y 
			  FROM batch_solve_input ),
			OPTIONS => KV_PAIRS( 
			  'export_solve_results' = 'true', 
			  'output_edge_path' = 'true'
			 ),
			SOLUTION_TABLE =>  'batch_solve_output'
		  )

		SELECT 
		  source, target, SUM(ST_LENGTH(PATH,1)) as route_length
		FROM  batch_solve_output
		GROUP BY source, target
		ORDER BY route_length desc;

	PostGIS:13311 rows. minor difference in the distance values . Unit conversion may be required.
			CREATE TABLE batch_solve_output
			(
			   INDEX BIGINT NOT NULL,
			   SOURCE GEOMETRY NOT NULL,
			   TARGET GEOMETRY NOT NULL,
			   COST REAL NOT NULL,
			   PATH GEOMETRY NOT NULL,
			   ROUTE character varying NOT NULL
			)

			SELECT 
			  ST_AsText(source), ST_AsText(target), SUM(ST_LENGTH(PATH))*100000 as route_length
			FROM  batch_solve_output
			GROUP BY source, target
			ORDER BY route_length desc;

/************************************** Temporal Queries **********************************************/

3.2 AS OF Join: Join the bike events to the temperature readings based on AS OF join within a defined interval (I.e. +/- 1 hour)

	Kinetica:

	SELECT 
	  e.airtemp, t.*,
	  sensor_id,
	  e.dt as event_dt
	FROM 
	  bikeTrips t
	LEFT JOIN
	  temperature e
		ON ASOF(t.starttime, e.dt, INTERVAL '-1' HOUR, INTERVAL '1' HOUR, MAX)
	WHERE 
	ORDER BY  e.airtemp DESC

	PostGIS:
	
	
	create table MAX_TEMP as
	SELECT MAX(airtemp) as MAX_TEMP,tr.starttime st_time FROM temperature te, bikeTrips tr
	where te.dt >= (tr.starttime - INTERVAL '1 hour') and te.dt <= (tr.starttime + INTERVAL '1 hour')
	group by tr.starttime;

	create index MAX_TEMP_idx on MAX_TEMP(MAX_TEMP);
	create index st_time_idx on MAX_TEMP(st_time);

	SELECT
	e.airtemp, t.*,
	e.sensor_id,
	e.dt as event_dt
	FROM
	bikeTrips t
	left outer JOIN MAX_TEMP m
	ON t.starttime = m.st_time
	JOIN temperature e
	ON t.starttime=e.dt
	ORDER BY e.airtemp DESC;
	
	
	OmniSCIDB:
	 
	create table MAX_TEMP as
	SELECT MAX(airtemp) as MAX_TEMP,tr.starttime st_time FROM temperature te, bikeTrips10m tr
	where te.dt >= (tr.starttime - INTERVAL '1' hour) and te.dt <= (tr.starttime + INTERVAL '1' hour)
	group by tr.starttime;

	create index MAX_TEMP_idx on MAX_TEMP(MAX_TEMP);
	create index st_time_idx on MAX_TEMP(st_time);

	SELECT
	e.airtemp, t.*,
	e.sensor_id,
	e.dt as event_dt
	FROM
	bikeTrips t
	left outer JOIN MAX_TEMP m
	ON t.starttime = m.st_time
	JOIN temperature e
	ON t.starttime=e.dt
	ORDER BY e.airtemp DESC;

3.3 Time Filter: Count all events that occurred between two given date times that intersect with the polygon

	kinetica:

	SELECT
	COUNT(*)
	FROM bikeTrips t 
	JOIN GIANT_POLYGONS b 
	  ON STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
	WHERE t.starttime > '2020-12-20' 
	  AND t.starttime < '2020-12-21';

	PostGIS:


	SELECT COUNT(*) FROM bikeTrips10m t 
	JOIN GIANT_POLYGONS b 
	  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	  WHERE t.starttime > '2020-12-20 00:00:00' 
	  AND t.starttime < '2020-12-21 00:00:00';
	  
	OmniSCIDB:

	SELECT COUNT(*) FROM bikeTrips10m t 
	JOIN GIANT_POLYGONS b 
	  ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	  WHERE t.starttime > '2020-12-20 00:00:00' 
	  AND t.starttime < '2020-12-21 00:00:00';

3.4 Window Function: For every ride, find the moving demand over 10 min sliding window

	kinetica:

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
	  
	OmniSCIDB:

	SELECT start_station_id,bikeid,COUNT(*),
	cast(extract(HOUR from starttime) as integer) + ((cast(extract(MINUTE from starttime) as integer) / cast(10 as integer)) * cast(10 as integer)) AS ten_min_timestamp
	FROM bikeTrips10m
	GROUP BY start_station_id,bikeid,ten_min_timestamp;

3.5 Geo-Temporal: AS-OF + Geo filter (Get the temperature within an hour of the ride starting in the given polygon._
Count the number of trips that started in the given polygon where the temp was above 60 degrees.

	kinetica:
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
	  AND  ride_t.airtemp > 60;
	  
	PostGIS:
	
	SELECT
	e.airtemp, t.*,
	e.sensor_id,
	e.dt as event_dt
	FROM
	bikeTrips t
	left outer JOIN MAX_TEMP m
	ON t.starttime = m.st_time
	JOIN temperature e
	ON t.starttime=e.dt
	join GIANT_POLYGONS b 
	ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't' 
	where b.id = '4'  and e.airtemp > 60
	ORDER BY e.airtemp DESC;


	OmniSCiDB:
	
	SELECT
	e.airtemp, t.*,
	e.sensor_id,
	e.dt as event_dt
	FROM
	bikeTrips t
	left outer JOIN MAX_TEMP m
	ON t.starttime = m.st_time
	JOIN temperature e
	ON t.starttime=e.dt
	join GIANT_POLYGONS b
	ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	where b.id = '4'  and e.airtemp > 60
	ORDER BY e.airtemp DESC
	
	

3.6 Window + Geo Filter: Find the demand of trips for a particular day that fell within the GIANT_POLYGON

	Kinetica:

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

3.7 Geo-Join + Temporal Filter: Join events to boundaries where the trip duration was less than 10 minutes

	Kinetica:

	SELECT
	t.*,
	b.id
	FROM bikeTrips t 
	JOIN GIANT_POLYGONS b 
	ON STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
	WHERE t.starttime > '2020-12-20' AND t.starttime < '2020-12-21';

	PostGIS:
	SELECT
	t.*,
	b.id
	FROM bikeTrips10m t 
	JOIN GIANT_POLYGONS b 
	ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	WHERE t.starttime > '2020-12-20' AND t.starttime < '2020-12-21';


	OmniSCIDB:


	SELECT
	t.*,
	b.id
	FROM bikeTrips10m t 
	JOIN GIANT_POLYGONS b 
	ON ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
	WHERE t.starttime > '2020-12-20 00:00:00' AND t.starttime < '2020-12-21 00:00:00';

/*************************************************************************************************/

5.1 Generate Isochrone: Generate 5 minute isochrones from the empire state building using the OSM graph
MAX_SOLUTION_RADIUS: The largest polygon produced will equal 600 seconds of travel time
NUM_LEVELS: The number of levels to sub-divide the largest polygon produced by MAX_SOLUTION_RADIUS. 5 levels = 2 minute increments.

Kinetica:

CREATE OR REPLACE TABLE iso_levels AS
SELECT * FROM TABLE (
    GENERATE_ISOCHRONE (
        GRAPH => 'osm_graph',
        SOURCE_NODE => 'POINT(-73.9857 40.7484)',
        MAX_SOLUTION_RADIUS => 600,
        NUM_LEVELS => 5 
    )
) dt ORDER BY dt.Level DESC;

PostGIS: No inbuilt function available to generate the data & visualize

OmniSCIDB: No inbuilt function available to generate the data & visualize

/*************************************************************************************************************************/

