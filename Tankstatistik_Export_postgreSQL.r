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

# Letzte wesentliche Änderung: 24.07.2025
# Verwendete Version: R 4.5.2

# Arbeitsverzeichnis festgelegt?
getwd()

# Pakete laden
library(RPostgreSQL)



#-------------------#
# Datenaufbereitung #----
#-------------------#
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
print(names(df.new))



#------------#
# postgreSQL #----
#------------#

## Verbindung prüfen
# Funktion
dbCheck <- function(){
  conn <- dbConnect(RPostgres::Postgres(),
                    dbname = "Tankstatistik",
                    host = Sys.getenv("PG_HOST"),
                    port = Sys.getenv("PG_PORT"),
                    user = Sys.getenv("PG_USER"),
                    password = Sys.getenv("PG_PASS") #Zugangsdaten in lokaler Umgebungsvariablendatei hinterlegt
                   )
  on.exit(dbDisconnect(conn), add = TRUE)
  # Verbindung prüfen
  print(conn)
  dbGetQuery(conn, "SELECT nspname FROM pg_catalog.pg_namespace")
  }

# Aufruf
dbCheck()


## Staging
# Funktion
dbStageData <- function(){
  conn <- dbConnect(RPostgres::Postgres(),
                    dbname = "Tankstatistik",
                    host = Sys.getenv("PG_HOST"),
                    port = Sys.getenv("PG_PORT"),
                    user = Sys.getenv("PG_USER"),
                    password = Sys.getenv("PG_PASS")
  )
  on.exit(dbDisconnect(conn), add = TRUE)
  # In staging laden
  dbWriteTable(conn,
               Id(schema = "staging", table = "corolla_betankungen"),
               df.new,
               row.names = FALSE, overwrite = TRUE)

  # Primärschlüssel für Abgleich erzeugen
  dbSendQuery(conn, "ALTER TABLE staging.corolla_betankungen
                     ADD COLUMN betankung_nr SERIAL PRIMARY KEY")

  # Datum in korrektes Format bringen
  dbSendQuery(conn, "ALTER TABLE staging.corolla_betankungen
                     ALTER COLUMN datum TYPE date
                     USING datum::date")
  }

# Aufruf
dbStageData()


## Core
# Funktion
dbUpdateCore <- function(){
  conn <- dbConnect(RPostgres::Postgres(),
                    dbname = "Tankstatistik",
                    host = Sys.getenv("PG_HOST"),
                    port = Sys.getenv("PG_PORT"),
                    user = Sys.getenv("PG_USER"),
                    password = Sys.getenv("PG_PASS")
  )
  on.exit(dbDisconnect(conn), add = TRUE)
  # Core aktualisieren
  dbSendQuery(conn,
    "MERGE INTO core.corolla_betankungen AS c
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
              )"
             )
  }

# Aufruf
dbUpdateCore()
