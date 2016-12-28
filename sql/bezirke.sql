-- bezirksgrenzen_bezirk
WITH kanton AS
(
  SELECT t_id
  FROM av_hoheitsgrenzen.kantonsgrenzen_kanton
),
bezirk AS 
(
  SELECT DISTINCT ON (bzrk_nr) bzrk_nr, bzrk_name
  FROM public.bezirkgre_gen
)
INSERT INTO av_hoheitsgrenzen.bezirksgrenzen_bezirk (aname, bezirksnummer, kanton)
SELECT bezirk.bzrk_name, bezirk.bzrk_nr::integer, kanton.t_id
FROM kanton, bezirk;


-- bezirksgrenzen_bezirksgrenze_generalisiert
WITH bezirk AS
(
 SELECT t_id, bezirksnummer
 FROM av_hoheitsgrenzen.bezirksgrenzen_bezirk
),
grenze AS (
 SELECT wkb_geometry, bzrk_nr::integer
 FROM public.bezirkgre_gen
)
INSERT INTO av_hoheitsgrenzen.bezirksgrenzen_bezirksgrenze_generalisiert (bezirk, geometrie)
SELECT bezirk.t_id, ST_SnapToGrid(grenze.wkb_geometry,0.001)
FROM bezirk, grenze
WHERE bezirk.bezirksnummer = grenze.bzrk_nr;

-- bezirksgrenzen_bezirksname_pos
INSERT INTO av_hoheitsgrenzen.bezirksgrenzen_bezirksname_pos (aelement, aname, pos, ori, hali, vali)
SELECT bezirke.t_id, public.bezirkgre_gen.bzrk_name as aname, ST_SnapToGrid(ST_PointFromText('POINT('|| public.bezirkgre_gen.pos_x || ' ' || public.bezirkgre_gen.pos_y ||')', 21781), 0.001) as pos, 
       public.bezirkgre_gen.winkel::double precision AS ori, 'Left'::text AS hali, 'Half' AS vali
FROM public.bezirkgre_gen , av_hoheitsgrenzen.bezirksgrenzen_bezirk AS bezirke
WHERE public.bezirkgre_gen.bzrk_nr::integer = bezirke.bezirksnummer;