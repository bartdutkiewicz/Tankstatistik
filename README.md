# Tankstatistik

## Statistik auf Grundlage selbst erhobener Daten von Betankungen eines Toyota Corolla Bj. 1998 seit 2014

### Projektbeschreibung

In diesem Projekt wird die Tankstatistik eines Toyota Corolla Bj. 1998 seit 2014 fortlaufend ausgewertet. Das Auto wird durch den Urheber dieser Auswertung überwiegend innerhalb der Region Stuttgart bewegt und an städischen (sehr selten: an der Autobahn) Tankstellen der selben Region betankt.

Die Auswertung erfolt mit R und der IDE R-Studio in Projektform. Mit R-Studio findet auch der Austausch mit GitHub statt.

Dieses Projekt (Code und verbale Auswertung) ist <b>Work-In-Progress</b> (seit 2015) und das Datum bezieht sich auf die letzte wesentliche Änderung im Code. <b>Der Datensatz wird laufend ergänzt</b>.

Eine ausführliche Präsentation des Projekts findet sich in [Tankstatistik_Markdown_GitHub](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.md).

Grundliegendes Dokument ist jedoch das Skript [Tankstatistik.r](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik.r), wo die Ausertung auch entwickelt wird. Der Code aller anderen Dokumente ist (z.T. unvollständige und ggf. um Formatierung ergänzte) Kopie dieses Quelltextes.


### Repository-Inhalt

- [Input_Data](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Input_Data): Erhobener Datensatz
- [Output_Data](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Output_Data): Rekonstruierter, verarbeiteter und ergänzter Datensatz
- [Output_Files](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Output_Files): Exportierte Statistik
- [Tankstatistik_Markdown_GitHub_files/figure-gfm](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Tankstatistik_Markdown_GitHub_files/figure-gfm): Exportierte Abbildungen als Asset-Ordner für Markdown-Präsentation.
- [LICENCE.txt](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/LICENCE): Lizenz
- [README.md](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/README.md): Dieses Dokument
- [Tankstatistik.r](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik.r): Grundliegender Quelltext des Projekts
- [Tankstatistik_Markdown_GitHub.Rmd](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.Rmd): R-Markdown-Dokument, Quelltext für das Markdown-Dokument
- [Tankstatistik_Markdown_GitHub.md](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.md): Markdown-Dokument mit Projektpräsentation (außer Exporte, die im R-Skript beschrieben sind)


### Weitere Orte dieses Projekts im Internet
- [RPubs](https://rpubs.com/Dutkiewicz/Tankstatistik): Ausertungsbeschreibung in Markdown (älteste aber aktualiserte Präsentation des Projekts)
- [Posit.Cloud](https://posit.cloud/content/3318758): Cloud-Version des R-Studio-Projekts (Benutzerkonto erforderlich)


### Daten und Erhebung
- Auto wird nur vom Urheber gefahren
- Technische Daten des Autos: siehe Einleitung in [Tankstatistik_Markdown_GitHub.md](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.md)
- Erhebungsbeginn 2014
- Der Datensatz ist durch Verlust und erst später erhobene Beobachtungen lückenhaft. Die Rekonstruktiron wird auch in Markdown beschrieben.


### Auswertung grundsätzlich
- <b>Work-In-Progress</b>
- Skript wird seit etwa 2015 entwickelt. Nach der ersten Version waren die meisten Änderungen nur inkrementell. Größere Enwicklungschübe gab es 2021/12 - 2022/01 (Abbildungen, Markdown, Cloud-Version auf Posit.Cloud) und seit 2025/03 (Grundliegende Überarbeitung, Versionsverwaltung mit Git/GitHub, geplante Änderungen s.u.)


### Auswertung Skript
- Das [R-Skript](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik.r) ist für alle anderen Dokumente grundliegend!
- Das Skript hat monolithischen Charakter, obwohl es auf 2-4 Skripte aufgeteilt werden könnte (Aufbereitung, Auswertung, Abbildungen, Export). Dies ist mit der Absicht geschehen, alles mit einer Ausführung erledigen zu können. Aufgrund des überschaubaren Projektumfangs wird dies bis auf Weiteres beibehalten.
- In der Datenaufbereitung und -Auswertung wird auf Pakete jenseits der R-Basis verzichtet. Dies ist bei Projektbeginn aus autodidaktischen Gründen entschieden worden und wird beibehalten.
- Für Abbildungen, Markdown und Exporte werden bekannte Pakete (z.B. die Paketfamilie "tidyverse") verwendet.
- Einige Kommentare sind "Notiz an den Urheber" aus während der Entwicklung gewonnenen Erkenntnissen über die Funktionsweise von R und anderen wichtigen Aspekten.


### Weiteres Vorgehen
- Export in postgreSQL (getrenntes Skript)
- Export in SQLite (im Skript als Demonstration)
- Rückrechnung der gefahrenen Kilometer verbessern (anhand der Kilometerstände der Protokolle der Hauptuntersuchungen)

- Zweite Projektpräsention mit Jupyter-Notebook
