-- kantonsgrenzen_kanton
INSERT INTO av_hoheitsgrenzen.kantonsgrenzen_kanton (aname, kantonskuerzel)
VALUES ('Solothurn', 'SO');

-- kantonsgrenzen_kantonsgrenze_generalisiert
WITH kanton AS 
(
  SELECT t_id, kantonskuerzel
  FROM av_hoheitsgrenzen.kantonsgrenzen_kanton
), 
geometrie AS 
(
  SELECT wkb_geometry as geom, kanton
  FROM public.kantonsgre_gen
)

INSERT INTO av_hoheitsgrenzen.kantonsgrenzen_kantonsgrenze_generalisiert (kanton, geometrie)
SELECT kanton.t_id, ST_SnapToGrid(geometrie.geom, 0.001)
FROM kanton, geometrie
WHERE kanton.kantonskuerzel = geometrie.kanton;

-- kantonsgrenzen_kantonsname_pos
WITH kanton AS 
(
  SELECT t_id, kantonskuerzel
  FROM av_hoheitsgrenzen.kantonsgrenzen_kanton
), 
pos AS 
(
  SELECT kanton, ST_SnapToGrid(ST_PointFromText('POINT('|| pos_x || ' ' || pos_y ||')', 21781), 0.001) as pos, 
         winkel::double precision, 'Left'::text AS hali, 'Half' AS vali
  FROM public.kantonsgre_gen
)
INSERT INTO av_hoheitsgrenzen.kantonsgrenzen_kantonsname_pos (aname, aelement, pos, ori, hali, vali)
SELECT pos.kanton, kanton.t_id, pos, winkel, hali, vali
FROM kanton, pos
WHERE kanton.kantonskuerzel = pos.kanton;

