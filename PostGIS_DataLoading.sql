\timing on
\o DataLoading.log


truncate table batch_solve_input;
truncate table batch_solve_output;
truncate table biketrips10m;
truncate table giant_polygons;
truncate table ny_roads;
truncate table ny_roads_graph;
truncate table nyct2010;
truncate table station_info;
truncate table station_status;
truncate table Temperature;

\echo "--Loading Data nyct2010"
COPY nyct2010 FROM '/mnt/resource/nyct2010.csv' DELIMITERS ',' CSV HEADER;	

\echo "--Loading Data Giant Polygons"
COPY giant_polygons FROM '/mnt/resource/giant_polygons.csv' DELIMITERS ',' CSV HEADER;	

\echo "--Loading Data ny_roads_graph"
COPY ny_roads_graph FROM '/mnt/resource/ny_roads_graph.csv' DELIMITERS ',' CSV HEADER;	

\echo "--Loading Data batch_solve_output"
COPY batch_solve_output FROM '/mnt/resource/batch_solve_output.csv' DELIMITERS ',' CSV HEADER;	

\echo "--Loading Data Biketrips10m"

COPY Biketrips10m FROM '/mnt/resource/10m/202012-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips10m FROM '/mnt/resource/10m/202011-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips10m FROM '/mnt/resource/10m/202010-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips10m FROM '/mnt/resource/10m/202009-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips10m FROM '/mnt/resource/10m/202008-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips10m FROM '/mnt/resource/10m/202007-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;

\echo "--Loading Data Biketrips50m"

COPY Biketrips50m FROM '/mnt/resource/50m/202012-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202011-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202010-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202009-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202008-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202007-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202006-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202005-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202004-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202003-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202002-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/202001-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201912-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201911-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201910-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201909-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201806-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201908-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201907-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201906-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201905-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201904-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201903-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201902-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201901-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201812-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201811-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201810-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201809-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201808-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips50m FROM '/mnt/resource/50m/201807-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;

\echo "--Loading Data Biketrips100m for Year 2014-2015"

COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201412-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201411-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201410-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-08 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-07 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-06 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-05 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-04 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-03 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-01 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/2014-02 - Citi Bike trip data.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201409-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201512-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201510-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201511-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201509-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201508-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201507-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201505-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201504-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201503-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201502-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201501-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2014-2015/201506-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;

\echo "--Loading Data Biketrips100m for Year 2016-2017"

COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201706-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201705-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201704-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201703-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201702-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201701-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201712-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201711-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201710-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201709-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201708-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201707-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201612-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201611-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201610-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201609-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201608-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201607-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201606-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201605-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201604-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201603-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201602-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2016-2017/201601-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;

\echo "--Loading Data Biketrips100m for Year 2018-20"

COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202012-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202011-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202010-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202009-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202008-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202007-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202006-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202005-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202004-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202003-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202002-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/202001-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201912-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201911-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201910-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201909-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201908-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201907-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201906-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201905-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201904-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201903-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201902-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201901-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201812-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201811-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201810-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201809-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201808-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201807-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201806-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201805-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201804-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201803-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201802-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;
COPY Biketrips100m FROM '/mnt/resource/100m/2018-2020/201801-citibike-tripdata.csv.txt.csv' DELIMITERS ',' CSV HEADER;


\echo "--Loading Data ny_roads"
COPY ny_roads FROM '/mnt/resource/ny_roads.csv' DELIMITERS ',' CSV HEADER;

\echo "--Loading Data batch_solve_output for 10M"
COPY batch_solve_output FROM '/mnt/resource/batch_solve_output.csv' DELIMITERS ',' CSV HEADER;

\echo "--Loading Temperature data"

COPY Temperature FROM '/mnt/resource/nyc_temperature.csv' DELIMITERS ',' CSV HEADER;

	drop table temp_final;
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

\echo"--Creating Graph table with Edges & Nodes"

	CREATE EXTENSION postgis;
	CREATE EXTENSION postgis_topology;
	CREATE EXTENSION pgrouting;

	drop table ny_roads_graph_test;
	create table ny_roads_graph_test as select * from ny_roads;

	ALTER TABLE ny_roads_graph_test ADD COLUMN source integer;
	ALTER TABLE ny_roads_graph_test ADD COLUMN target integer;
	CREATE INDEX nyroadsgr_source_idx ON ny_roads_graph_test (source);
	CREATE INDEX nyroadsgr_target_idx ON ny_roads_graph_test (target);

	\echo "--creating topology"
	SELECT pgr_createTopology('ny_roads_graph_test', 0.0001, 'wkt', 'osm_id');
	
	
\q