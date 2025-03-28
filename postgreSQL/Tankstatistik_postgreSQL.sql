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
ADD COLUMN betankung_nr SERIAL PRIMARY KEY

/* Datum in korrektes Format bringen */
ALTER TABLE staging.corolla_betankungen
ALTER COLUMN datum TYPE date
USING datum::date


/* Daten in core mit neuen daten aus staging zusammenführen */
MERGE INTO core.corolla_betankungen AS c
USING (SELECT * FROM staging.corolla_betankungen ORDER BY betankung_nr) AS s
ON c.betankung_nr = s.betankung_nr
WHEN MATCHED AND (c.km, c.km_gesamt) = (c.km, c.km_gesamt) THEN
    DO NOTHING
WHEN MATCHED AND NOT (c.km, c.km_gesamt) = (c.km, c.km_gesamt) THEN
    UPDATE SET
		km = s.km,
		km_gesamt = s.km_gesamt
WHEN NOT MATCHED THEN
    INSERT (datum,
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
	VALUES (s.datum,
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
