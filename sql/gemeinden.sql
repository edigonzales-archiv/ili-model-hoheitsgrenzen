
-- gemeindegrenzen_gemeinde
WITH bezirke AS
(
 SELECT t_id, bezirksnummer
 FROM av_hoheitsgrenzen.bezirksgrenzen_bezirk
),
gemeinden AS 
(
  SELECT DISTINCT ON (gem_bfs) replace("name", '<br>', '') as aname, gem_bfs::integer, bzrk_nr::integer
  FROM public.gemgre_gen
)
INSERT INTO av_hoheitsgrenzen.gemeindegrenzen_gemeinde (aname, bfs_gemeindenummer, bezirk) 
SELECT gemeinden.aname, gemeinden.gem_bfs, bezirke.t_id
FROM bezirke, gemeinden
WHERE bezirke.bezirksnummer = gemeinden.bzrk_nr;

-- Update names of municipalities:
-- * remove hyphen
-- * replace names with correct names from 'amtliches gemeindeverzeichnis'
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Niederbuchsiten' WHERE bfs_gemeindenummer = 2405;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Holderbank (SO)' WHERE bfs_gemeindenummer = 2425;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Niedergösgen' WHERE bfs_gemeindenummer = 2495;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Obergösgen' WHERE bfs_gemeindenummer = 2497;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Rohr (SO)' WHERE bfs_gemeindenummer = 2498;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Wisen (SO)' WHERE bfs_gemeindenummer = 2502;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Erlinsbach (SO)' WHERE bfs_gemeindenummer = 2503;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Aeschi (SO)' WHERE bfs_gemeindenummer = 2511;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Kriegstetten' WHERE bfs_gemeindenummer = 2525;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Balm bei Günsberg' WHERE bfs_gemeindenummer = 2541;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Oberdorf (SO)' WHERE bfs_gemeindenummer = 2553;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Kappel (SO)' WHERE bfs_gemeindenummer = 2580;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Rickenbach (SO)' WHERE bfs_gemeindenummer = 2582;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Walterswil (SO)' WHERE bfs_gemeindenummer = 2585;
UPDATE av_hoheitsgrenzen.gemeindegrenzen_gemeinde SET aname = 'Beinwil (SO)' WHERE bfs_gemeindenummer = 2612;


-- gemeindegrenzen_gemeindegrenze_generalisiert
WITH gemeinde AS
(
 SELECT t_id, bfs_gemeindenummer as gem_bfs
 FROM av_hoheitsgrenzen.gemeindegrenzen_gemeinde
),
grenze AS (
 SELECT wkb_geometry, gem_bfs
 FROM public.gemgre_gen
)

INSERT INTO av_hoheitsgrenzen.gemeindegrenzen_gemeindegrenze_generalisiert(gemeinde, geometrie)
SELECT gemeinde.t_id, ST_SnapToGrid(grenze.wkb_geometry, 0.001)
FROM gemeinde, grenze
WHERE gemeinde.gem_bfs = grenze.gem_bfs::integer;


-- gemeindegrenzen_gemeindename_pos
-- Not sure about the orientation and starting point though...

INSERT INTO av_hoheitsgrenzen.gemeindegrenzen_gemeindename_pos (aelement, aname, pos, ori, hali, vali)
SELECT gemeinde.t_id, public.gemgre_gen."name" as aname, 
       ST_SnapToGrid(ST_PointFromText('POINT('|| public.gemgre_gen.pos_x || ' ' || public.gemgre_gen.pos_y ||')', 21781), 0.001) as pos, 
       public.gemgre_gen.winkel::double precision AS ori, 'Left'::text AS hali, 'Half' AS vali
FROM public.gemgre_gen, av_hoheitsgrenzen.gemeindegrenzen_gemeinde as gemeinde
WHERE public.gemgre_gen.gem_bfs::integer = gemeinde.bfs_gemeindenummer;
