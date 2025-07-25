/* Code für Schema- und Tabellenerzeugug in postgreSQL
und Code für Ausführung in R*/


/* Schemata erzeugen */
/* Manuell in pgAdmin die Schemata: "staging" und "core" */


/* Tabellen erzeugen */
/* Tabelle "staging.corolla_betankungen */
/* erfolgt in R */


/* Anlegen der Tabelle 'core.corolla_betankungen' */
CREATE TABLE IF NOT EXISTS core.corolla_betankungen(
betankung_nr SMALLINT PRIMARY KEY NOT NULL,
datum DATE NOT NULL,
jahr SMALLINT NOT NULL,
monat SMALLINT NOT NULL,
tag SMALLINT NOT NULL,
stunde SMALLINT,
minute SMALLINT,
tage SMALLINT,
liter NUMERIC(4,2) NOT NULL,
euro_liter NUMERIC(4,3) NOT NULL,
euro NUMERIC(5,2) NOT NULL,
km SMALLINT,
km_gesamt INT,
liter_km NUMERIC(5,4),
euro_km NUMERIC(5,4),
km_tag NUMERIC(7,4),
liter_tag NUMERIC(6,4),
euro_tag NUMERIC(7,4)
);



/* In R verwendete Queries */
/* Primärschlüssel für Abgleich erzeugen */
ALTER TABLE staging.corolla_betankungen
ADD COLUMN betankung_nr SERIAL PRIMARY KEY;

/* Datum in korrektes Format bringen */
ALTER TABLE staging.corolla_betankungen
ALTER COLUMN datum TYPE date
USING datum::date;


/* Core aktualisieren */
MERGE INTO core.corolla_betankungen AS c
USING (SELECT *
       FROM staging.corolla_betankungen
       ORDER BY betankung_nr
      ) AS s
ON c.betankung_nr = s.betankung_nr
WHEN MATCHED AND (c.km,
                  c.km_gesamt,
                  c.datum,
                  c.jahr,
                  c.monat,
                  c.tag,
                  c.stunde,
                  c.minute,
                  c.tage,
                  c.liter,
                  c.euro_liter,
                  c.euro,
                  c.liter_km,
                  c.euro_km,
                  c.km_tag,
                  c.liter_tag,
                  c.euro_tag
                 ) = (s.km,
                      s.km_gesamt,
                      s.datum,
                      s.jahr,
                      s.monat,
                      s.tag,
                      s.stunde,
                      s.minute,
                      s.tage,
                      s.liter,
                      s.euro_liter,
                      s.euro,
                      s.liter_km,
                      s.euro_km,
                      s.km_tag,
                      s.liter_tag,
                      s.euro_tag
                     ) THEN
	DO NOTHING
WHEN MATCHED AND (c.km IS DISTINCT FROM s.km OR
                  c.km_gesamt IS DISTINCT FROM s.km_gesamt OR
                  c.datum IS DISTINCT FROM s.datum OR
                  c.jahr IS DISTINCT FROM s.jahr OR
                  c.monat IS DISTINCT FROM s.monat OR
                  c.tag IS DISTINCT FROM s.tag OR
                  c.stunde IS DISTINCT FROM s.stunde OR
                  c.minute IS DISTINCT FROM s.minute OR
                  c.tage IS DISTINCT FROM s.tage OR
                  c.liter IS DISTINCT FROM s.liter OR
                  c.euro_liter IS DISTINCT FROM s.euro_liter OR
                  c.euro IS DISTINCT FROM s.euro OR
                  c.liter_km IS DISTINCT FROM s.liter_km OR
                  c.euro_km IS DISTINCT FROM s.euro_km OR
                  c.km_tag IS DISTINCT FROM s.km_tag OR
                  c.liter_tag IS DISTINCT FROM s.liter_tag OR
                  c.euro_tag IS DISTINCT FROM s.euro_tag
                 ) THEN
	UPDATE SET
	km = s.km,
	km_gesamt = s.km_gesamt,
	datum = s.datum,
	jahr = s.jahr,
	monat = s.monat,
	tag = s.tag,
	stunde = s.stunde,
	minute = s.minute,
	tage = s.tage,
	liter = s.liter,
	euro_liter = s.euro_liter,
	euro = s.euro,
	liter_km = s.liter_km,
	euro_km = s.euro_km,
	km_tag = s.km_tag,
	liter_tag = s.liter_tag,
	euro_tag = s.euro_tag
WHEN NOT MATCHED THEN
	INSERT (betankung_nr,
            datum,
            jahr,
            monat,
            tag,
            stunde,
            minute,
            tage,
            liter,
            euro_liter,
            euro,
            km,
            km_gesamt,
            liter_km,
            euro_km,
            km_tag,
            liter_tag,
            euro_tag
           )
	VALUES (s.betankung_nr,
            s.datum,
            s.jahr,
            s.monat,
            s.tag,
            s.stunde,
            s.minute,
            s.tage,
            s.liter,
            s.euro_liter,
            s.euro,
            s.km,
            s.km_gesamt,
            s.liter_km,
            s.euro_km,
            s.km_tag,
            s.liter_tag,
            s.euro_tag
           );
		   
/* Core aktualisieren (verkürzte Methode, ungetestet Stand 25.07.2025) */
/* Limitations (MS Copilot) */
/* Both c and s must have identical column sets and order. */
/* If the schemas differ (e.g. extra columns or different order), this will fail or behave unexpectedly. */
/* You can't selectively exclude columns (e.g. audit fields) without listing them manually. */
MERGE INTO core.corolla_betankungen AS c
USING (SELECT *
       FROM staging.corolla_betankungen
       ORDER BY betankung_nr
      ) AS s
ON c.betankung_nr = s.betankung_nr
WHEN MATCHED AND ROW(c.*) = ROW(s.*) THEN
	DO NOTHING
WHEN MATCHED AND ROW(c.*) IS DISTINCT FROM ROW(s.*) THEN
	UPDATE SET
	km = s.km,
	km_gesamt = s.km_gesamt,
	datum = s.datum,
	jahr = s.jahr,
	monat = s.monat,
	tag = s.tag,
	stunde = s.stunde,
	minute = s.minute,
	tage = s.tage,
	liter = s.liter,
	euro_liter = s.euro_liter,
	euro = s.euro,
	liter_km = s.liter_km,
	euro_km = s.euro_km,
	km_tag = s.km_tag,
	liter_tag = s.liter_tag,
	euro_tag = s.euro_tag
WHEN NOT MATCHED THEN
	INSERT (betankung_nr,
            datum,
            jahr,
            monat,
            tag,
            stunde,
            minute,
            tage,
            liter,
            euro_liter,
            euro,
            km,
            km_gesamt,
            liter_km,
            euro_km,
            km_tag,
            liter_tag,
            euro_tag
           )
	VALUES (s.betankung_nr,
            s.datum,
            s.jahr,
            s.monat,
            s.tag,
            s.stunde,
            s.minute,
            s.tage,
            s.liter,
            s.euro_liter,
            s.euro,
            s.km,
            s.km_gesamt,
            s.liter_km,
            s.euro_km,
            s.km_tag,
            s.liter_tag,
            s.euro_tag
           );