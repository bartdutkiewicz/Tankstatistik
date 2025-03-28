#----------------------------------------------------#
# Auswertung der Tankstatistik für                   #
# Toyota Corolla, Bj.1998, Benzin, 920kg, 81kw,      #
# 6000U/min, 195kmhmax, 1587cm3, 40L-Tank            #
# Fahrgestellnummer: UT164AEB103030101               #
# B.R.Dutkiewicz                                     #
#                                                    #
# Export der Datensatzrekonstruktion in postgreSQL   #
#                                                    #
#----------------------------------------------------#

# Letzte wesentliche Änderung: 27.03.2025
# Verwendete Version: R 4.4.3

# Arbeitsverzeichnis festgelegt?
getwd()



#-----------------------#
# Zugang zur postgreSQL #----
#-----------------------#

# Pakete laden
library(RPostgreSQL)

# Verbindung zu postgreSQL herstellen
pg.conn <- dbConnect(RPostgres::Postgres(),
                     dbname = "Tankstatistik",
                     host = Sys.getenv("PG_HOST"),
                     port = Sys.getenv("PG_PORT"),
                     user = Sys.getenv("PG_USER"),
                     password = Sys.getenv("PG_PASS") #Zugangsdaten in lokaler Umgebungsvariablendatei hinterligt
)

# Verbindung prüfen
print(pg.conn)

# Schemata betrachten
dbGetQuery(pg.conn, "SELECT nspname FROM pg_catalog.pg_namespace")

# Schema "staging" in Suchpfad legen.
dbExecute(pg.conn, "SET search_path TO sales")



#--------#
# Export #----
#--------#
## Datensatz
# Laden
df.new <- read.table("Output_Data\\Corolla_Betankungen_reconstructed.txt",
                     skip = 5,
                     header = TRUE, sep = "\t", quote = "\"",
                     dec = ",", fill = TRUE)

# Spaltennamen postgreSQL-kompatibel machen
dbSafeNames <- function(names){
  names <- gsub('[^a-z0-9]+', '_',tolower(names))
  names <- make.names(names, unique = TRUE, allow_ = TRUE)
  names <- gsub('.', '_', names, fixed = TRUE)
  names
}

colnames(df.new) <- dbSafeNames(colnames(df.new))
names(df.new)

# In staging laden
dbWriteTable(pg.conn,
             Id(schema = "staging", table = "corolla_betankungen"),
             df.new,
             row.names = FALSE, overwrite = TRUE)

# Primärschlüssel für Abgleich erzeugen
dbSendQuery(pg.conn, "ALTER TABLE staging.corolla_betankungen
                      ADD COLUMN betankung_nr SERIAL PRIMARY KEY")

# Datum in korrektes Format bringen
dbSendQuery(pg.conn, "ALTER TABLE staging.corolla_betankungen
                      ALTER COLUMN datum TYPE date
                      USING datum::date")

# Tabelle mit neuen Daten aus staging aktualisieren
dbSendQuery(pg.conn, "MERGE INTO core.corolla_betankungen AS c
                      USING (SELECT * FROM staging.corolla_betankungen ORDER BY betankung_nr) AS s
                      ON c.betankung_nr = s.betankung_nr
                      WHEN MATCHED AND (c.km, c.km_gesamt) = (c.km, c.km_gesamt) THEN
                         DO NOTHING
                      WHEN MATCHED AND NOT (c.km, c.km_gesamt) = (c.km, c.km_gesamt) THEN
                         UPDATE SET
                         km = s.km,
                         km_gesamt = s.km_gesamt
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
                                )")
