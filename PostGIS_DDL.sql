\timing on
-- Table: batch_solve_input

-- DROP TABLE IF EXISTS batch_solve_input;

CREATE TABLE IF NOT EXISTS batch_solve_input
(
    tripduration bigint,
    starttime timestamp without time zone,
    stoptime timestamp without time zone,
    start_station_id character varying ,
    start_station_name character varying ,
    start_station_latitude double precision,
    start_station_longitude double precision,
    end_station_id character varying ,
    end_station_name character varying ,
    end_station_latitude double precision,
    end_station_longitude double precision,
    bikeid character varying ,
    usertype character varying ,
    birth_year character varying ,
    gender character varying 
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS batch_solve_input OWNER to postgres;

-- Table: batch_solve_output

-- DROP TABLE IF EXISTS batch_solve_output;

CREATE TABLE IF NOT EXISTS batch_solve_output
(
    index bigint NOT NULL,
    source geometry NOT NULL,
    target geometry NOT NULL,
    cost real NOT NULL,
    path geometry NOT NULL,
    route character varying  NOT NULL
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS batch_solve_output OWNER to postgres;

-- Table: biketrips10m

-- DROP TABLE IF EXISTS biketrips10m;


CREATE TABLE IF NOT EXISTS biketrips10m
(
    tripduration bigint ,
    starttime timestamp without time zone ,
    stoptime timestamp without time zone ,
    start_station_id character varying  ,
    start_station_name character varying  ,
    start_station_latitude double precision ,
    start_station_longitude double precision ,
    end_station_id character varying  ,
    end_station_name character varying  ,
    end_station_latitude double precision ,
    end_station_longitude double precision ,
    bikeid character varying  ,
    usertype character varying ,
    birth_year character varying ,
    gender character varying 
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS biketrips10m
    OWNER to postgres;



-- Table: biketrips50m

-- DROP TABLE IF EXISTS biketrips50m;

CREATE TABLE IF NOT EXISTS biketrips50m
(
    tripduration bigint ,
    starttime timestamp without time zone ,
    stoptime timestamp without time zone ,
    start_station_id character varying  ,
    start_station_name character varying  ,
    start_station_latitude double precision ,
    start_station_longitude double precision ,
    end_station_id character varying  ,
    end_station_name character varying  ,
    end_station_latitude double precision ,
    end_station_longitude double precision ,
    bikeid character varying  ,
    usertype character varying ,
    birth_year character varying ,
    gender character varying 
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS biketrips50m OWNER to postgres;

-- Table: biketrips100m

-- DROP TABLE IF EXISTS biketrips100m;

CREATE TABLE IF NOT EXISTS biketrips100m
(
    tripduration bigint ,
    starttime timestamp without time zone ,
    stoptime timestamp without time zone ,
    start_station_id character varying  ,
    start_station_name character varying  ,
    start_station_latitude double precision ,
    start_station_longitude double precision ,
    end_station_id character varying  ,
    end_station_name character varying  ,
    end_station_latitude double precision ,
    end_station_longitude double precision ,
    bikeid character varying  ,
    usertype character varying ,
    birth_year character varying ,
    gender character varying
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS biketrips100m OWNER to postgres;


-- Table: giant_polygons

-- DROP TABLE IF EXISTS giant_polygons;

CREATE TABLE IF NOT EXISTS giant_polygons
(
    wkt geometry,
    id character varying  NOT NULL
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS giant_polygons
    OWNER to postgres;

-- Table: max_temp

-- DROP TABLE IF EXISTS max_temp;

CREATE TABLE IF NOT EXISTS max_temp_10m
(
    max_temp double precision,
    st_time timestamp without time zone
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS max_temp_10m
    OWNER to postgres;

-- Table: ny_roads

-- DROP TABLE IF EXISTS ny_roads;

CREATE TABLE IF NOT EXISTS ny_roads
(
    wkt geometry NOT NULL,
    osm_id bigint NOT NULL,
    code integer NOT NULL,
    fclass character varying  NOT NULL,
    name character varying ,
    ref character varying ,
    oneway character varying  NOT NULL,
    maxspeed integer NOT NULL,
    layer integer NOT NULL,
    bridge character varying  NOT NULL,
    tunnel character varying  NOT NULL
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS ny_roads OWNER to postgres;

-- Table: ny_roads_graph

-- DROP TABLE IF EXISTS ny_roads_graph;

CREATE TABLE ny_roads_graph
(
   osm_id BIGINT NOT NULL,
   source BIGINT NOT NULL,
   target BIGINT NOT NULL,
   wkt GEOMETRY NOT NULL,
   WEIGHTS_VALUESPECIFIED REAL NOT NULL
)TABLESPACE pg_default;


ALTER TABLE IF EXISTS ny_roads_graph
    OWNER to postgres;

-- Table: nyct2010

-- DROP TABLE IF EXISTS nyct2010;

CREATE TABLE IF NOT EXISTS nyct2010
(
    gid integer NOT NULL,
    geom geometry NOT NULL,
    ctlabel character varying  NOT NULL,
    borocode character varying  NOT NULL,
    boroname character varying  NOT NULL,
    ct2010 character varying  NOT NULL,
    boroct2010 character varying  NOT NULL,
    cdeligibil character varying  NOT NULL,
    ntacode character varying  NOT NULL,
    ntaname character varying  NOT NULL,
    puma character varying  NOT NULL,
    shape_leng double precision NOT NULL,
    shape_area double precision NOT NULL,
    CONSTRAINT nyct2010_pkey PRIMARY KEY (gid)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS nyct2010 OWNER to postgres;

-- Table: station_info

-- DROP TABLE IF EXISTS station_info;

CREATE TABLE IF NOT EXISTS station_info
(
    capacity integer NOT NULL,
    eightd_has_key_dispenser integer NOT NULL,
    eightd_station_services character varying  NOT NULL,
    electric_bike_surcharge_waiver integer NOT NULL,
    external_id character varying  NOT NULL,
    has_kiosk integer NOT NULL,
    lat double precision NOT NULL,
    legacy_id integer NOT NULL,
    lon double precision NOT NULL,
    name character varying  NOT NULL,
    region_id integer NOT NULL,
    rental_methods character varying  NOT NULL,
    rental_uris character varying  NOT NULL,
    short_name character varying  NOT NULL,
    station_id integer NOT NULL,
    station_type character varying  NOT NULL
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS station_info OWNER to postgres;

-- Table: station_status

-- DROP TABLE IF EXISTS station_status;

CREATE TABLE IF NOT EXISTS station_status
(
    eightd_active_station_services character varying ,
    eightd_has_available_keys integer NOT NULL,
    is_installed integer NOT NULL,
    is_renting integer NOT NULL,
    is_returning integer NOT NULL,
    last_reported integer NOT NULL,
    legacy_id integer NOT NULL,
    num_bikes_available integer NOT NULL,
    num_bikes_disabled integer NOT NULL,
    num_docks_available integer NOT NULL,
    num_docks_disabled integer NOT NULL,
    num_ebikes_available integer NOT NULL,
    station_id integer NOT NULL,
    station_status character varying  NOT NULL,
    valet character varying ,
    dt timestamp without time zone NOT NULL
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS station_status OWNER to postgres;

-- Table: temperature

DROP TABLE IF EXISTS temperature;

CREATE TABLE IF NOT EXISTS temperature
(
   sensor_id character varying NOT NULL,
   airtemp double precision,
   Day timestamp without time zone NOT NULL,
   Hour INTEGER NOT NULL,
   latitude double precision NOT NULL,
   longitude double precision NOT NULL,
   Year INTEGER NOT NULL,
   Install_Type character varying NOT NULL,
   Borough character varying NOT NULL,
   ntacode character varying NOT NULL
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS temperature OWNER to postgres;


\q
