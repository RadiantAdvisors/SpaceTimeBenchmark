\timing on;
\o Index.log
-- Index: tr_sttime

-- DROP INDEX IF EXISTS 
tr_sttime;

CREATE INDEX IF NOT EXISTS tr_sttime
    ON biketrips10m USING btree
    (starttime ASC NULLS LAST)
    TABLESPACE pg_default;

create index testidx on bikeTrips10m(start_station_longitude,start_station_latitude);

-- Index: max_temp_idx

-- DROP INDEX IF EXISTS max_temp_idx;

CREATE INDEX IF NOT EXISTS max_temp_idx
    ON max_temp USING btree
    (max_temp ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: st_time_idx

-- DROP INDEX IF EXISTS st_time_idx;

CREATE INDEX IF NOT EXISTS st_time_idx
    ON max_temp USING btree
    (st_time ASC NULLS LAST)
    TABLESPACE pg_default;

-- Index: nyroads_source_idx

-- DROP INDEX IF EXISTS nyroads_source_idx;

CREATE INDEX IF NOT EXISTS nyroads_source_idx
    ON ny_roads USING btree
    (source ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: nyroads_target_idx

-- DROP INDEX IF EXISTS nyroads_target_idx;

CREATE INDEX IF NOT EXISTS nyroads_target_idx
    ON ny_roads USING btree
    (target ASC NULLS LAST)
    TABLESPACE pg_default;

-- Index: ny_roads_graph_osm_id_idx

-- DROP INDEX IF EXISTS ny_roads_graph_osm_id_idx;

CREATE INDEX IF NOT EXISTS ny_roads_graph_osm_id_idx
    ON ny_roads_graph USING btree
    (osm_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ny_roads_graph_wkt_idx

-- DROP INDEX IF EXISTS ny_roads_graph_wkt_idx;

CREATE INDEX IF NOT EXISTS ny_roads_graph_wkt_idx
    ON ny_roads_graph USING gist
    (wkt)
    TABLESPACE pg_default;
-- Index: nyroadsgr_source_idx

-- DROP INDEX IF EXISTS nyroadsgr_source_idx;

CREATE INDEX IF NOT EXISTS nyroadsgr_source_idx
    ON ny_roads_graph USING btree
    (source ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: nyroadsgr_target_idx

-- DROP INDEX IF EXISTS nyroadsgr_target_idx;

CREATE INDEX IF NOT EXISTS nyroadsgr_target_idx
    ON ny_roads_graph USING btree
    (target ASC NULLS LAST)
    TABLESPACE pg_default;

-- Index: tedt

-- DROP INDEX IF EXISTS tedt;

CREATE INDEX IF NOT EXISTS tedt
    ON temperature USING btree
    (dt ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: tetmp

-- DROP INDEX IF EXISTS tetmp;

CREATE INDEX IF NOT EXISTS tetmp
    ON temperature USING btree
    (airtemp ASC NULLS LAST)
    TABLESPACE pg_default;

\q