-- 1.2. Geo Filter: Count the rides originating in the polygon

Kinetica:

SELECT
  COUNT(*)
FROM bikeTrips t, GIANT_POLYGONS b
WHERE 
  b.id = 4 AND
  STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1;
  
Output - 354,  0.067 seconds


PostGIS:

SELECT
COUNT(*)
FROM bikeTrips10m t, GIANT_POLYGONS b
where  b.id='4' and 
 ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't';
 
OmniSCI:

SELECT
COUNT(*)
FROM bikeTrips10m t, GIANT_POLYGONS b
where  b.id='4' and 
 ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't';
 

-- 1.3 Filter + SUM: SUM the length of the rides originating in the polygon

Kinetica:

SELECT
  SUM(TIMESTAMPDIFF(MINUTE, starttime, stoptime)) as total_ridetimes_w_4_as_origin
FROM bikeTrips t, GIANT_POLYGONS b
WHERE STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
AND b.id = 4;

Output - 3928

OmniSCI:

SELECT
  SUM(TIMESTAMPDIFF(MINUTE, starttime, stoptime)) as total_ridetimes_w_4_as_origin
FROM bikeTrips10m t, GIANT_POLYGONS b
WHERE ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
AND b.id = '4';

Output 3934


PostGIS:

SELECT
  sum( 
  (DATE_PART('hour',stoptime::timestamp) * 60  + DATE_PART('minute',stoptime)) 
  -  
  ( DATE_PART('hour',starttime::timestamp) * 60 + DATE_PART('minute',starttime)) 
  ) as total_ridetimes_w_4_as_origin
FROM bikeTrips10m t, GIANT_POLYGONS b
WHERE ST_INTERSECTS(ST_Point(t.start_station_longitude, t.start_station_latitude), b.wkt) = 't'
AND b.id = '4';

Output 4127


-- 1.4. Geojoin: Find all the rides originating and ending in the polygon

SELECT
  t.*,
  b.id as start_polygon_id,
  c.id as end_polygon_id
FROM bikeTrips t
JOIN GIANT_POLYGONS b ON
  STXY_INTERSECTS(t.start_station_longitude, t.start_station_latitude, b.wkt) = 1
JOIN GIANT_POLYGONS c ON
  STXY_INTERSECTS(t.end_station_longitude, t.end_station_latitude, c.wkt) = 1
GROUP BY start_polygon_id, end_polygon_id;


Api Error: Execute SQL - Error: 'SqlEngine: Expression 't.tripduration' is not being grouped (S/SDc:1283); error in Job process'


-- 1.5 Geojoin + Count: Count all the rides originating and ending in the polygon

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


Output -4

39 4 1
70 1 4
273 4 4
7284 1 1


Postgis:

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

output - 4 rows
7284	1	1
70	1	4
39	4	1
273	4	4


OmniSCI:

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

273|4|4
70|1|4
39|4|1
7284|1|1


--issues faced

ERROR :
DBever
error_msg:multiple SQL statements not allowed

CLI
Hash join failed, reason(s): Cannot apply hash join to inner column type BOOLEAN | Cannot fall back to loop join for intermediate join quals

for inner query:
Hash join failed, reason(s): Cannot apply hash join to inner column type BOOLEAN | Cannot fall back to loop join for intermediate join quals

-- Debugging


create table emp(empid text not null, did  integer);
create table dept(did integer not null, dname text);
insert into emp values(2,20);
insert into dept values(10,'ops');
insert into dept values(20,'eng');

select * from emp where did in ( select did from dept where did=10)

Fix::

enabled -- allow-loop-joins=true in conf file 
modified the query to cost boolean to integer
--
[root@mylinux ~]# cat /var/lib/omnisci/omnisci.conf
port = 6274
http-port = 6278
calcite-port = 6279
data = "/var/lib/omnisci/data"
null-div-by-zero = true
allowed-import-paths = ["/opt/omnisci/data/mapd_import/sample_datasets/flights_2008_10k/","/tmp/data"]
enable-union=true
allow-loop-joins=true
[web]
port = 6273
frontend = "/opt/omnisci/frontend"
[root@mylinux ~]#

--End of debugging session