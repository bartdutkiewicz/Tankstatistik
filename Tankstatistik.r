#----------------------------------------------------#
# Auswertung der Tankstatistik für                   #
# Toyota Corolla, Bj.1998, Benzin, 920kg, 81kw,      #
# 6000U/min, 195kmhmax, 1587cm3, 40L-Tank            #
# Fahrgestellnummer: UT164AEB103030101               #
# B.R.Dutkiewicz                                     #
#----------------------------------------------------#

# Letzte wesentliche Änderung: 24.07.2025
# Verwendete Version: R 4.5.1

# Arbeitsverzeichnis festgelegt?
getwd()

# Entfernen aller Objekte
rm(list=ls(all=TRUE))



#--------------#
# Aufbereitung #----
#--------------#
##----------#
## Einlesen #----
##----------#

# Einlesen der Rohdaten
df.raw <- read.table("Input_Data\\Corolla_Betankungen_raw.txt",
                     col.names=c("Tag", "Monat", "Jahr", "Stunde",
                                 "Minute", "Liter","Euro.Liter", "Euro",
                                 "km", "km.gesamt", "Anmerkung"),
                     header=TRUE, sep = "\t", dec = ",", skip = 5, fill = TRUE)

# Datensatz betrachten
head(df.raw)
tail(df.raw, n = 6)
str(df.raw)

# Exportversion der Rohdaten
df.export.raw <- df.raw

# Löschen der Anmerkungen
df.raw <- df.raw[, -11]



##-------------------#
## Datenaufbereitung #----
##-------------------#

### Rekonstruktion Teil 1
# Rekonstruktion von [1, 1]; [1, 2] (Tag und Monat)
df.raw[1, 1] <- 20; df.raw[1, 2] <- 6

# Rekonstruktion von [1, 7] (Literpreis)
df.raw[1, 7] <- df.raw[1, 8]/df.raw[1, 6]



### Aufbereitung Teil 1
# Erzeugen einer Datumsvariable und Einfügen dieser
# in die Tabelle.
Datum <- paste(df.raw$Jahr,"-",df.raw$Monat,"-",df.raw$Tag, sep="")
df.raw$Datum <- as.Date(Datum)

# Berechnen der vergangenen Tage zwischen zwei Betankungen
Tage <- as.integer(diff(df.raw$Datum))
df.raw$Tage <- c(Tage, NA)



### Rekonstruktion Teil 2
## Rekonstruktion von [58, 9] bis [66, 9] (Kilometer je Tankfüllung in 2018)
# Durchschnittliche Kilometer am Tag 2019
df.raw.2019 <- subset(df.raw, Jahr == "2019")
df.raw.2019 <- df.raw.2019[, c(9, 12)]
Mittel.a.2019 <- lapply(df.raw.2019, function(x) mean(x))
Mittel.a.2019$km.Tag <- (Mittel.a.2019$km/Mittel.a.2019$Tage)

# Rückrechnung
df.raw[58, 9] <- df.raw[58, 12] * Mittel.a.2019$km.Tag
df.raw[59, 9] <- df.raw[59, 12] * Mittel.a.2019$km.Tag
df.raw[60, 9] <- df.raw[60, 12] * Mittel.a.2019$km.Tag
df.raw[61, 9] <- df.raw[61, 12] * Mittel.a.2019$km.Tag
df.raw[62, 9] <- df.raw[62, 12] * Mittel.a.2019$km.Tag
df.raw[63, 9] <- df.raw[63, 12] * Mittel.a.2019$km.Tag
df.raw[64, 9] <- df.raw[64, 12] * Mittel.a.2019$km.Tag
df.raw[65, 9] <- df.raw[65, 12] * Mittel.a.2019$km.Tag
df.raw[66, 9] <- df.raw[66, 12] * Mittel.a.2019$km.Tag



### Rekonstruktion Teil 3
# Rekonstruktion von [1, 10] bis [75, 10] (Gesamtkilometerstand)
for (i in 76:2){
  df.raw[i-1, 10] <- df.raw[i, 10] - df.raw[i, 9]
}


### Aufbereitung Teil 2
## Bereinigung Arbeitsumgebung
# Entfernen aller ab hier unnötigen Objekte
rm(df.raw.2019, Mittel.a.2019, Datum, i, Tage)


## Bilden einiger Quotienten
# Liter je km
df.raw$Liter.km <- df.raw$Liter / df.raw$km

# Euro je km
df.raw$Euro.km <- df.raw$Euro / df.raw$km

# Kilometer je Tag
df.raw$km.Tag <- df.raw$km / df.raw$Tage

# Liter je Tag
df.raw$Liter.Tag <- df.raw$Liter / df.raw$Tage

# Euro je Tag
df.raw$Euro.Tag <- df.raw$Euro / df.raw$Tage


## Format
# Tag und Monat als Ganzzahlen speichern
df.raw$Tag <- as.integer(df.raw$Tag)
df.raw$Monat <- as.integer(df.raw$Monat)



### Aufbereitung Teil 3
# Runden aller Spalten für einheitliche Anzahl an Nachkommastellen
df.raw$km <- round(df.raw$km)
df.raw$km.gesamt <- round(df.raw$km.gesamt)
df.raw$Liter.km <- round(df.raw$Liter.km, 4)
df.raw$Euro.km <- round(df.raw$Euro.km, 4)
df.raw$km.Tag <- round(df.raw$km.Tag, 3)
df.raw$Liter.Tag <- round(df.raw$Liter.Tag, 4)
df.raw$Euro.Tag <- round(df.raw$Euro.Tag, 4)



##--------------------#
## Varianten erzeugen #----
##--------------------#

## Aufbereiteter Datensatz inkl. unv. jüngster Beobachtung für den Export
df.export <- df.raw

# In Spaltennamen Punkt durch Unterstrich ersetzen
names(df.export) <- gsub(x = names(df.export), pattern = "\\.", replacement = "_")
#Punkte in Spaltennamen sind in R üblich, jedoch in anderen Werkzeugen wie Python problematisch.


## Aufbereiteter Datensatz exkl. unv. jüngster Beobachtung für die weitere Auswertung
df.raw <- df.raw[-nrow(df.raw), ]
df <- df.raw
rm(df.raw)



#------------#
# Auswertung #----
#------------#
##-------------------#
## Gesamter Zeitraum #----
##-------------------#

## Summen
# Gesamtverbrauch an Benzin in Litern
# Gesamtausgaben in Euro
# Insgesamt gefahrene Kilomenter
# Vergangene Tage seit Beginn der Erhebung
Summen <- unlist(lapply(df[c(6, 8, 9, 12)], function(x) sum(x)))

# Anzahl der Betankungen
Summen <- c(Summen, dim(df)[1])
names(Summen) <- c("Liter", "Euro", "km", "Tage", "Betankungen")


## Mittel und Quotienten (arithmetrisch)
# Durchschnittlich getanktes Benzin in Litern
# Durschschnittspreis in Euro/Liter
# Durchschnittliche Ausgaben in Euro/Kilometer
# Durchschnittlich gefahrene Strecke in Kilometern
# Durchschnittlich vergangenene Zeit zwischen zwei Betankungen in Tagen
Mittel.a <- lapply(df[c(6:9, 12)], function(x) mean(x))

# Durchschnittsverbrauch in Liter/km
Mittel.a$Liter.km <- (Mittel.a$Liter/Mittel.a$km)

# Durchschnittskosten in Euro/km
Mittel.a$Euro.km <- (Mittel.a$Euro/Mittel.a$km)

# Durchschnittliche Kilometer am Tag
Mittel.a$km.Tag <- (Mittel.a$km/Mittel.a$Tage)

# Durchschnittlicher Benzinverbrauch in l/Tag
Mittel.a$Liter.Tag <- (Mittel.a$Liter/Mittel.a$Tage)

# Durchschnittliche Kosten in Euro/Tag
Mittel.a$Euro.Tag <- (Mittel.a$Euro/Mittel.a$Tage)

# Listeneigenschaft entfernen (erst hier! Wird oben benötigt)
Mittel.a <- unlist(Mittel.a)


## Mittel und Quotienten (median)
# Durchschnittlich getanktes Benzin in Litern
# Durschschnittspreis in Euro/Liter
# Durchschnittliche Ausgaben in Euro/Kilometer
# Durchschnittlich gefahrene Strecke in Kilometern
# Durchschnittlich vergangenene Zeit zwischen zwei Betankungen in Tagen
Mittel.m <- lapply(df[c(6:9, 12)], function(x) median(x))

# Durchschnittsverbrauch in Liter/km
Mittel.m$Liter.km <- (Mittel.m$Liter/Mittel.m$km)

# Durchschnittskosten in Euro/km
Mittel.m$Euro.km <- (Mittel.m$Euro/Mittel.m$km)

# Durchschnittliche Kilometer am Tag
Mittel.m$km.Tag <- (Mittel.m$km/Mittel.m$Tage)

# Durchschnittlicher Benzinverbrauch in l/Tag
Mittel.m$Liter.Tag <- (Mittel.m$Liter/Mittel.m$Tage)

# Durchschnittliche Kosten in Euro/Tag
Mittel.m$Euro.Tag <- (Mittel.m$Euro/Mittel.m$Tage)

# Listeneigenschaft entfernen (erst hier! Wird oben benötigt)
Mittel.m <- unlist(Mittel.m)

## Vergleich von Median und arithmetrischem Mittel
# Differenzen der Mittel für Gesamtzeitraum, absolut
Mittel.diff.abs <- Mittel.m - Mittel.a

# Differenzen der Mittel für Gesamtzeitraum, relativ in Prozent
Mittel.diff.rel <- ((Mittel.m - Mittel.a)/Mittel.m) * 100

# Tabelle bilden
Mittel <- data.frame(cbind(Mittel.a, Mittel.m, Mittel.diff.abs, Mittel.diff.rel))


## Bereinigung Arbeitsumgebung
# Entfernen aller ab hier unnötigen Objekte
rm(Mittel.a, Mittel.m, Mittel.diff.abs, Mittel.diff.rel)



##-------#
## Jahre #----
##-------#

# Aufteilen nach Jahr
df.Jahr <- split(df, df$Jahr)


## Summen
# Gesamtverbrauch an Benzin in Litern
Gesamtverbrauch.Jahr <- unlist(lapply(df.Jahr, function(x) sum(x[, 6])))
# Gesamtausgaben in Euro
Gesamtausgaben.Jahr <- unlist(lapply(df.Jahr, function(x) sum(x[, 8])))
# Insgesamt gefahrene Kilomenter
Kilometer.Jahr <- unlist(lapply(df.Jahr, function(x) sum(x[, 9])))
# Anzahl der Betankungen
Betankungen.Jahr <- unlist(lapply(df.Jahr, function(x) dim(x)[1]))

# Tabelle bilden
Summen.Jahr <- data.frame(cbind(Gesamtverbrauch.Jahr,
                                Gesamtausgaben.Jahr,
                                Kilometer.Jahr,
                                Betankungen.Jahr))


## Bereinigung Arbeitsumgebung
# Entfernen aller ab hier unnötigen Objekte
rm(Gesamtverbrauch.Jahr, Gesamtausgaben.Jahr, Kilometer.Jahr, Betankungen.Jahr)


## Mittel und Quotienten (arithmetrisch)
# Durchschnittlich getanktes Benzin in Litern je Jahr
Liter.Tank.Jahr.a <- unlist(lapply(df.Jahr, function(x) mean(x[, 6])))
# Durschschnittspreis in Euro/Liter je Jahr
Literpreis.Jahr.a <- unlist(lapply(df.Jahr, function(x) mean(x[, 7])))
# Durchschnittliche Ausgaben in Euro je Jahr
Euro.Tank.Jahr.a <- unlist(lapply(df.Jahr, function(x) mean(x[, 8])))
# Durchschnittlich gefahrene Strecke in Kilometern je Jahr
KM.Tank.Jahr.a <- unlist(lapply(df.Jahr, function(x) mean(x[, 9])))
# Durchschnittlich vergangenene Zeit zwischen zwei Betankungen in Tagen
Tage.Tank.Jahr.a <- unlist(lapply(df.Jahr, function(x) mean(x[, 12])))

# Durchschnittsverbrauch in Liter/km
Liter.KM.Jahr.a <- unlist(lapply(df.Jahr, function(x) (mean(x[, 6])/mean(x[, 9]))))
# Durchschnittskosten in Euro/km
Euro.KM.Jahr.a <- unlist(lapply(df.Jahr, function(x) (mean(x[, 8])/mean(x[, 9]))))
# Durchschnittliche Kilometer am Tag
KM.Tag.Jahr.a <- unlist(lapply(df.Jahr, function(x) (mean(x[, 8])/mean(x[, 12]))))
# Durchschnittlicher Benzinverbrauch in l/Tag
Liter.Tag.Jahr.a <- unlist(lapply(df.Jahr, function(x) (mean(x[, 6])/mean(x[, 12]))))
# Durchschnittliche Kosten in Euro/Tag
Euro.Tag.Jahr.a <- unlist(lapply(df.Jahr, function(x) (mean(x[, 8])/mean(x[, 12]))))

# Tabelle bilden
Mittel.Jahr.a <- data.frame(cbind(Liter.Tank.Jahr.a,
                                  Literpreis.Jahr.a,
                                  Euro.Tank.Jahr.a,
                                  KM.Tank.Jahr.a,
                                  Tage.Tank.Jahr.a,
                                  Liter.KM.Jahr.a,
                                  Euro.KM.Jahr.a,
                                  KM.Tag.Jahr.a,
                                  Liter.Tag.Jahr.a,
                                  Euro.Tag.Jahr.a))

## Bereinigung Arbeitsumgebung
# Entfernen aller ab hier unnötigen Objekte
rm(Liter.Tank.Jahr.a,
   Literpreis.Jahr.a,
   Euro.Tank.Jahr.a,
   KM.Tank.Jahr.a,
   Tage.Tank.Jahr.a,
   Liter.KM.Jahr.a,
   Euro.KM.Jahr.a,
   KM.Tag.Jahr.a,
   Liter.Tag.Jahr.a,
   Euro.Tag.Jahr.a)


## Mittel und Quotienten (median)
# Durchschnittlich getanktes Benzin in Litern je Jahr
Liter.Tank.Jahr.m <- unlist(lapply(df.Jahr, function(x) median(x[, 6])))
# Durschschnittspreis in Euro/Liter je Jahr
Literpreis.Jahr.m <- unlist(lapply(df.Jahr, function(x) median(x[, 7])))
# Durchschnittliche Ausgaben in Euro je Jahr
Euro.Tank.Jahr.m <- unlist(lapply(df.Jahr, function(x) median(x[, 8])))
# Durchschnittlich gefahrene Strecke in Kilometern je Jahr
KM.Tank.Jahr.m <- unlist(lapply(df.Jahr, function(x) median(x[, 9])))
# Durchschnittlich vergangenene Zeit zwischen zwei Betankungen in Tagen
Tage.Tank.Jahr.m <- unlist(lapply(df.Jahr, function(x) median(x[, 12])))

# Durchschnittsverbrauch in Liter/km
Liter.KM.Jahr.m <- unlist(lapply(df.Jahr, function(x) (median(x[, 6])/median(x[, 9]))))
# Durchschnittskosten in Euro/km
Euro.KM.Jahr.m <- unlist(lapply(df.Jahr, function(x) (median(x[, 8])/median(x[, 9]))))
# Durchschnittliche Kilometer am Tag
KM.Tag.Jahr.m <- unlist(lapply(df.Jahr, function(x) (median(x[, 8])/median(x[, 12]))))
# Durchschnittlicher Benzinverbrauch in l/Tag
Liter.Tag.Jahr.m <- unlist(lapply(df.Jahr, function(x) (median(x[, 6])/median(x[, 12]))))
# Durchschnittliche Kosten in Euro/Tag
Euro.Tag.Jahr.m <- unlist(lapply(df.Jahr, function(x) (median(x[, 8])/median(x[, 12]))))

# Tabelle bilden
Mittel.Jahr.m <- data.frame(cbind(Liter.Tank.Jahr.m,
                                  Literpreis.Jahr.m,
                                  Euro.Tank.Jahr.m,
                                  KM.Tank.Jahr.m,
                                  Tage.Tank.Jahr.m,
                                  Liter.KM.Jahr.m,
                                  Euro.KM.Jahr.m,
                                  KM.Tag.Jahr.m,
                                  Liter.Tag.Jahr.m,
                                  Euro.Tag.Jahr.m))


## Bereinigung Arbeitsumgebung
# Entfernen aller ab hier unnötigen Objekte
rm(df.Jahr,
   Liter.Tank.Jahr.m,
   Literpreis.Jahr.m,
   Euro.Tank.Jahr.m,
   KM.Tank.Jahr.m,
   Tage.Tank.Jahr.m,
   Liter.KM.Jahr.m,
   Euro.KM.Jahr.m,
   KM.Tag.Jahr.m,
   Liter.Tag.Jahr.m,
   Euro.Tag.Jahr.m)


## Vergleich von Median und arithmetrischem Mittel
# Differenzen der Mittel für Einzeljahre, absolut
Mittel.diff.Jahr.abs <- Mittel.Jahr.m - Mittel.Jahr.a

# Differenzen der Mittel für Einzeljahre, relativ in Prozent
Mittel.diff.Jahr.rel <- ((Mittel.Jahr.m - Mittel.Jahr.a)/Mittel.Jahr.m) * 100



##--------------------#
## Ausgabe Auswertung #----
##--------------------#

## Gesamter Zeitraum
# Zusammenfassung aller Summen, Mittelwerte und Quotienten des Gesamtzeitraumes
print(Summen)
print(Mittel)

## Jahreswerte
# Zusammenfassung der Jahressummen
print(Summen.Jahr)

# Zusammenfassung der Jahresmittelwerte und -quotienten (arithmetrisch)
print(Mittel.Jahr.a)

# Zusammenfassung der Jahresmittelwerte und -quotienten (median)
print(Mittel.Jahr.m)

# Vergleich beider Mittel, absolut und relativ
print(Mittel.diff.Jahr.abs)
print(Mittel.diff.Jahr.rel)



#-------------#
# Abbildungen #----
#-------------#
##-----------#
## Vorarbeit #----
##-----------#

## Pakete laden
library(tidyverse)
library(wesanderson) #Farbpaletten


## Vorarbeit
# Jahre (bisher als Zeilennamen) in reguläre Variable packen (damit ggplot2 zurecht kommt)
Summen.Jahr$Jahr <- as.integer(rownames(Summen.Jahr))
# Alles auf ganze Zahlen Runden (sonst hässliche Darstellung)
Summen.Jahr <- round(Summen.Jahr, digits = 0)
# Data Frame als Tibble
df <- as_tibble(df)

## Jahresmittelwerte in brauchbare Form bringen und zusammenführen
# Arithmetrisches Mittel
long.Mittel.Jahr.a <- Mittel.Jahr.a
names(long.Mittel.Jahr.a) <- str_sub(names(long.Mittel.Jahr.a), 1, nchar(names(long.Mittel.Jahr.a))-2) #Letzte beide Zeichen in den Spaltennamen Entfernen
long.Mittel.Jahr.a$Jahr <- as.integer(rownames(long.Mittel.Jahr.a)) #Jahr in Spalte ziehen
long.Mittel.Jahr.a$Mittel <- rep("arithmetrisch", nrow(long.Mittel.Jahr.a)) #Mittel in Spalte hinzufügen

# Median
long.Mittel.Jahr.m <- Mittel.Jahr.m
names(long.Mittel.Jahr.m) <- str_sub(names(long.Mittel.Jahr.m), 1, nchar(names(long.Mittel.Jahr.m))-2) #Das Gleiche für den Median
long.Mittel.Jahr.m$Jahr <- as.integer(rownames(long.Mittel.Jahr.m))
long.Mittel.Jahr.m$Mittel <- rep("median", nrow(long.Mittel.Jahr.m))

Mittel.Jahr <- rbind(long.Mittel.Jahr.a, long.Mittel.Jahr.m) #Zusammenführen
rownames(Mittel.Jahr) <- NULL #Zeilennamen löschen
Mittel.Jahr <- as_tibble(Mittel.Jahr) #In Tibble umwandeln


## Bereinigung Arbeitsumgebung
# Entfernen aller ab hier unnötigen Objekte
rm(long.Mittel.Jahr.a, long.Mittel.Jahr.m)



##--------------#
## Jahressummen #----
##--------------#

# Betankungen je Jahr
Abb.Betankungen.Jahr <- ggplot(data = Summen.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Summen.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 20),
                     breaks = seq(0, 20, 2)) +
  labs(x = "Jahr",
       y = "Anzahl",
       title = "Betankungen je Jahr") +
  geom_bar(mapping = (aes(x = Jahr, y = Betankungen.Jahr)),
           stat = "identity",
           color = "#2c624b",
           fill = "#2c624b") +
  geom_text(aes(x = Jahr,
                y = Betankungen.Jahr,
                label = Betankungen.Jahr),
            size = 5,
            #fontface = "bold",
            nudge_y = 1) +
  annotate(geom = "text", x = 2014, y = 8, label = "(ab Juni)", hjust = "center")
Abb.Betankungen.Jahr

# Kilometer je Jahr
Abb.Kilometer.Jahr <- ggplot(data = Summen.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Summen.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 9000)) +
  labs(x = "Jahr",
       y = "Kilometer",
       title = "Gefahrene Kilometer je Jahr") +
  geom_bar(mapping = (aes(x = Jahr, y = Kilometer.Jahr)),
           stat = "identity",
           color = wes_palettes$Rushmore1[4],
           fill = wes_palettes$Rushmore1[4]) +
  geom_text(aes(x = Jahr,
                y = Kilometer.Jahr,
                label = Kilometer.Jahr),
            size = 5,
            nudge_y = 300) +
  annotate(geom = "text", x = 2014, y = 3500, label = "(ab Juni)", hjust = "center")
Abb.Kilometer.Jahr

# Verbrauch je Jahr
Abb.Gesamtverbrauch.Jahr <- ggplot(data = Summen.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Summen.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 750)) +
  labs(x = "Jahr",
       y = "Liter",
       title = "Verbrauch je Jahr") +
  geom_bar(mapping = (aes(x = Jahr, y = Gesamtverbrauch.Jahr)),
           stat = "identity",
           color = wes_palettes$Rushmore1[1],
           fill = wes_palettes$Rushmore1[1]) +
  geom_text(aes(x = Jahr,
                y = Gesamtverbrauch.Jahr,
                label = Gesamtverbrauch.Jahr),
            size = 5,
            nudge_y = 20) +
  annotate(geom = "text", x = 2014, y = 300, label = "(ab Juni)", hjust = "center")
Abb.Gesamtverbrauch.Jahr

# Ausgaben je Jahr
Abb.Gesamtausgaben.Jahr <- ggplot(data = Summen.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Summen.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 900)) +
  labs(x = "Jahr",
       y = "Euro",
       title = "Ausgaben je Jahr") +
  geom_bar(mapping = (aes(x = Jahr, y = Gesamtausgaben.Jahr)),
           stat = "identity",
           color = wes_palettes$Rushmore1[5],
           fill = wes_palettes$Rushmore1[5]) +
  geom_text(aes(x = Jahr,
                y = Gesamtausgaben.Jahr,
                label = Gesamtausgaben.Jahr),
            size = 5,
            nudge_y = 20) +
  annotate(geom = "text", x = 2014, y = 420, label = "(ab Juni)", hjust = "center")
Abb.Gesamtausgaben.Jahr



##----------#
## Verläufe #----
##----------#

# Getankte Liter je Betankung
Abb.Liter <- ggplot(data = df,
                    mapping = aes(x = Datum, y = Liter)) +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 45)) +
  labs(x = "Jahr",
       y = "Liter",
       title = "Getanke Liter je Betankung") +
  geom_line() +
  geom_point(size = 1) +
  geom_hline(yintercept = 40, color = "red") +
  annotate(geom = "text", x = as.Date("2016-04-16"), y = 42, label = "max. Fassungsvermögen", hjust = "center")
Abb.Liter

# Verlauf der Literpreise
Abb.Literpreise <- ggplot(data = df,
                          mapping = aes(x = Datum, y = Euro.Liter)) +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 2.2)) +
  labs(x = "Jahr",
       y = "Euro",
       title = "Literpreis für E95") +
  geom_line() +
  geom_point(size = 1)
Abb.Literpreise

# Gefahrene Kilometer je Betankung
Abb.Kilometer <- ggplot(data = df,
                        mapping = aes(x = Datum, y = km)) +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 1000)) +
  labs(x = "Jahr",
       y = "Kilometer",
       title = "Gefahrene Kilometer je Betankung") +
  geom_line() +
  geom_point(size = 1) +
  annotate(geom = "text", x = as.Date("2016-04-16") + 10, y = 920,
           label = "Ausreißer, Plausibilität zweifelhaft", hjust = "left")
Abb.Kilometer

# Gefahrene Kilometer je getanktem Liter
Abb.Kilometer.Liter <- ggplot(data = df,
                              mapping = aes(x = Datum, y = Liter.km ^ (-1))) +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 35)) +
  labs(x = "Jahr",
       y = "Kilometer",
       title = "Gefahrene Kilometer je getanktem Liter") +
  geom_line() +
  geom_point(size = 1) +
  annotate(geom = "text", x = as.Date("2016-04-16"), y = 32,
           label = "Ausreißer, Plausibilität zweifelhaft", hjust = "left")
Abb.Kilometer.Liter

# Verbrauchte Liter je 100 Kilometer
Abb.Liter.100km <- ggplot(data = df,
                          mapping = aes(x = Datum, y = Liter.km * 100)) +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 20)) +
  labs(x = "Jahr",
       y = "Liter",
       title = "Verbrauchte Liter je 100 Kilometer") +
  geom_line() +
  geom_point(size = 1) +
  annotate(geom = "text", x = as.Date("2016-04-16"), y = 32,
           label = "Ausreißer, Plausibilität zweifelhaft", hjust = "left")
Abb.Liter.100km


# TBD: Kilometer je Tag und zeitlicher Abstand zur nächsten Betankung


# TBD: Reichweite je Tank + Farbskala Abstand je Betankung



##------------------------------------------#
## Jahresmittel (artithmetrisch und median) #----
##------------------------------------------#

# Liter je Betankung
Abb.Liter.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 50)) +
  labs(x = "Jahr",
       y = "Liter",
       title = "Liter je Betankung") +
  geom_bar(mapping = (aes(x = Jahr, y = Liter.Tank.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge()) +
  geom_hline(yintercept = 40, color = "red") +
  annotate(geom = "text", x = 2016, y = 42, label = "max. Fassungsvermögen", hjust = "center")
Abb.Liter.Jahr

# Literpreis
Abb.Literpreis.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 2.5)) +
  labs(x = "Jahr",
       y = "Euro/Liter",
       title = "Literpreis") +
  geom_bar(mapping = (aes(x = Jahr, y = Literpreis.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Literpreis.Jahr

# Euro je Tankfüllung
Abb.Euro.Tank.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 100)) +
  labs(x = "Jahr",
       y = "Euro/Betankung",
       title = "Ausgabe je Betankung") +
  geom_bar(mapping = (aes(x = Jahr, y = Euro.Tank.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Euro.Tank.Jahr

# Gefahrene Kilometer je Tankfüllung
Abb.KM.Tank.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 600)) +
  labs(x = "Jahr",
       y = "Kilometer/Tankfüllung",
       title = "Zurückgelegte Strecke je Betankung") +
  geom_bar(mapping = (aes(x = Jahr, y = KM.Tank.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.KM.Tank.Jahr

# Vergangene Tage zwischen zwei Betankungen
Abb.Tage.Tank.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 100)) +
  labs(x = "Jahr",
       y = "Tage",
       title = "Verstrichene Tage zwischen Tankfüllungen") +
  geom_bar(mapping = (aes(x = Jahr, y = Tage.Tank.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Tage.Tank.Jahr

# Verbrauch auf 100km
Abb.Verbrauch.100km.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 15)) +
  labs(x = "Jahr",
       y = "Liter/100km",
       title = "Verbrauch auf 100 km") +
  geom_bar(mapping = (aes(x = Jahr, y = (Liter.KM.Jahr) * 100, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Verbrauch.100km.Jahr

# Kosten in Euro je Kilometer
Abb.Euro.KM.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 0.20)) +
  labs(x = "Jahr",
       y = "Euro/km",
       title = "Kosten je Kilometer") +
  geom_bar(mapping = (aes(x = Jahr, y = Euro.KM.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Euro.KM.Jahr

# Zurückgelegte Kilometer je Tag
Abb.KM.Tag.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 3)) +
  labs(x = "Jahr",
       y = "Kilometer/Tag",
       title = "Zurückgelegte Kilometer je Tag") +
  geom_bar(mapping = (aes(x = Jahr, y = KM.Tag.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.KM.Tag.Jahr

# Verbrauchte Liter je Tag
Abb.Liter.Tag.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 2.5)) +
  labs(x = "Jahr",
       y = "Liter/Tag",
       title = "Verbrauchte Liter je Tag") +
  geom_bar(mapping = (aes(x = Jahr, y = Liter.Tag.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Liter.Tag.Jahr

# Kosten in Euro je Tag
Abb.Euro.Tag.Jahr <- ggplot(data = Mittel.Jahr) +
  theme_bw() +
  theme(panel.grid.major.x = element_blank()) +
  theme(panel.grid.minor.x = element_blank()) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 15)) +
  theme(axis.title.x = element_text(face = "bold", size = 15)) +
  theme(axis.text.x = element_text(face = "bold", vjust = 0.3)) +
  theme(axis.title.y = element_text(face = "bold", size = 15)) +
  theme(axis.text.y = element_text(face = "bold", vjust = 0.3)) +
  scale_x_continuous(expand = c(0, 0.25),
                     breaks = Mittel.Jahr$Jahr) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 3)) +
  labs(x = "Jahr",
       y = "Euro/Tag",
       title = "Kosten je Tag") +
  geom_bar(mapping = (aes(x = Jahr, y = Euro.Tag.Jahr, fill = Mittel)),
           stat = "identity",  position = position_dodge())
Abb.Euro.Tag.Jahr



#--------#
# Export #----
#--------#
##-------#
## Daten #----
##-------#
###----------#
### R-Objekt #----
###----------#

save(df.export, file = "Output_Data\\Corolla_Betankungen_reconstructed.RDS")



###-----------#
### Textdatei #----
###-----------#

## Aufbereitete Daten
# Information zum Datensatz
head <- "Corolla_Betankungen_reconstructed
B.R.Dutkiewicz (https://github.com/bartdutkiewicz/Tankstatistik)
Toyota Corolla Bj.1998 Benzin 920kg 81kw 6000U/min 195kmhmax 1587cm3 40L-Tank
UT164AEB103030101
Aufbereitete Daten"

# Datei öffnen
Export.File.Con <- file("Output_Data\\Corolla_Betankungen_reconstructed.txt", open = "wt")

# Information schreiben
writeLines(head, Export.File.Con, sep = "\n")

# Daten schreiben
write.table(df.export, file = Export.File.Con,
            append = TRUE, quote = TRUE, sep ="\t",
            na = "NA", dec = ",", row.names = FALSE)

# Datei schließen
close(Export.File.Con)


## Englische Version
# Information zum Datensatz
head.en <- "Corolla_refuelellings_reconstructed
B.R.Dutkiewicz (https://github.com/bartdutkiewicz/Tankstatistik)
Toyota Corolla year of manufacture 1998 gasoline 920kg 81kw 6000rpm 195kphmax 1587cm3 40 liter tank
UT164AEB103030101
Reconstructed Data"

# Englische Spaltennamen
df.export.en <- df.export
names(df.export.en) <- c("day", "month", "year", "hour", "minute", "liter", "euro_liter", "euro", "km", "km_total", "date", "days", "liter_km", "euro_km", "km_day", "liter_day", "euro_day")

# Datei öffnen
Export.File.Con <- file("Output_Data\\Corolla_refuellings_reconstructed.txt", open = "wt")

# Information schreiben
writeLines(head.en, Export.File.Con, sep = "\n")

# Daten schreiben
write.table(df.export.en, file = Export.File.Con,
            append = TRUE, quote = TRUE, sep ="\t",
            na = "NA", dec = ".", row.names = FALSE)

# Datei schließen
close(Export.File.Con)

# Entfernen aller ab hier unnötigen Objekte
rm(Export.File.Con, head, head.en)



###------------#
### postgreSQL #----
###------------#

# (Nur lokal auf eigenem Rechner. In gesondertem Skript!)



###--------#
### SQLite #----
###--------#

## Paket laden
library(RSQLite)


## Datenbank erzeugen und anbinden
SQLite.conn <- dbConnect(RSQLite::SQLite(), "Output_Data\\Corolla_Refuellings.db",
                         overwrite = TRUE)


## Technische Daten
# Tabelle
technische_daten <- c("marke", "modell", "baujahr", "kraftstoff", "gewicht_kg", "leistung_kw", "Umin", "geschwindigkeit_kmh", "hubraum_cm2", "fassungsvermögen_L", "fahrgestellnummer")
technical_data <- c("brand", "model", "year_of_manufacture", "fuel", "weight_kg", "power_kw", "rpm", "speed_kph", "displacement_ccm", "capacity_L", "chassis_number")
value <- c("Toyota", "Corolla", "1998", "Benzin_Gasoline", "920", "81", "195", "1587", "6000", "40", "UT164AEB103030101")
car_data <- data.frame(technische_daten, technical_data, value)

# In Datenbank laden
dbWriteTable(SQLite.conn, "car_data", car_data,
             overwrite = TRUE)


## Rohdaten
dbWriteTable(SQLite.conn, "corolla_betankungen_raw", df.export.raw,
             overwrite = TRUE)


## Aufbereitete Daten
dbWriteTable(SQLite.conn, "corolla_betankungen_reconstructed", df.export,
             overwrite = TRUE)


## Aufbereitete Daten Englisch
dbWriteTable(SQLite.conn, "corolla_refuellings_reconstructed", df.export.en,
             overwrite = TRUE)


## Entfernen aller ab hier unnötigen Objekte
rm(SQLite.conn, technische_daten, technical_data, value, car_data)



###-----#
### XML #----
###-----#

## Paket laden und schreiben
library(MESS)
write.xml(df.export, "Output_Data\\Corolla_Betankungen_reconstructed.xml")



###------#
### JSON #----
###------#

## Paket laden
library(jsonlite)


## JSON-Spalten
df.export.json.col <- toJSON(df.export, dataframe = "columns", pretty = TRUE)
write_json(df.export.json.col, "Output_Data\\Corolla_Betankungen_reconstructed.col.json")
#Zweistufig um a) Spaltennamen zu exportieren b) Format zu bestimmmen


## JSON-Reihen
df.export.json.row <- toJSON(df.export, dataframe = "rows", pretty = TRUE)
write_json(df.export.json.row, "Output_Data\\Corolla_Betankungen_reconstructed.row.json")


## Entfernen aller ab hier unnötigen Objekte
rm(df.export.json.col, df.export.json.row)


###---------------#
### Python Pandas #----
###---------------#

# Nein, einfach nur nein! Besser SQLite oder Apache Parquet



###----------------#
### Apache Parquet #----
###----------------#

## Paket laden und schreiben
library(arrow)
write_parquet(df.export, "Output_Data\\Corolla_Betankungen_reconstructed.parquet")



##--------------#
## Auswertungen #----
##--------------#

write.table(Summen, "Output_Files\\Tankstatistik_Gesamtsummen.txt")
write.table(Mittel, "Output_Files\\Tankstatistik_Mittel.txt")
write.table(Summen.Jahr, "Output_Files\\Tankstatistik_Jahressummen.txt")
write.table(Mittel.Jahr.a, "Output_Files\\Tankstatistik_Jahresmittel_arithmetrisch.txt")
write.table(Mittel.Jahr.m, "Output_Files\\Tankstatistik_Jahresmittel_median.txt")



##-------------#
## Abbildungen #----
##-------------#

# (Nur bei Bedarf)
