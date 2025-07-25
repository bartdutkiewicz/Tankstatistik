# Tankstatistik

## Statistik auf Grundlage selbst erhobener Daten von Betankungen eines Toyota Corolla Bj. 1998 seit 2014

### Projektbeschreibung

In diesem Projekt wird die Tankstatistik eines Toyota Corolla Bj. 1998 seit 2014 fortlaufend ausgewertet. Das Auto wird durch den Urheber dieser Auswertung überwiegend innerhalb der Region Stuttgart bewegt und an städischen Tankstellen betankt (in sehr seltenen Fällen an der Autobahn).

Dieses Projekt ist <b>Work-In-Progress</b> und der Datensatz wird laufend ergänzt.

Eine ausführliche Präsentation des Projekts findet sich in [Tankstatistik_Markdown_GitHub](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.md).

Grundliegendes Dokument ist jedoch das Skript [Tankstatistik.r](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik.r). Der Code aller anderen Dokumente fußt auf diesem.


### Repository-Inhalt

- [Input_Data](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Input_Data): Erhobener Datensatz.
- [Output_Data](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Output_Data): Rekonstruierter, verarbeiteter und ergänzter Datensatz.
- [Output_Files](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Output_Files): Exportierte Statistik.
- [Tankstatistik_Markdown_GitHub_files/figure-gfm](https://github.com/bartdutkiewicz/Tankstatistik/tree/main/Tankstatistik_Markdown_GitHub_files/figure-gfm): Exportierte Abbildungen als Asset-Ordner für Markdown-Präsentation.
- [LICENCE.txt](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/LICENCE): Lizenz.
- [README.md](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/README.md): Dieses Dokument.
- [Tankstatistik.r](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik.r): Grundliegende Datei des Projekts.
- [Tankstatistik_Markdown_GitHub.Rmd](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.Rmd): Projektpräsentation im R-Markdown-Format.
- [Tankstatistik_Markdown_GitHub.md](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.md): Projektpräsentaion in "reinem" Markdown-Format.


### Weitere Orte dieses Projekts im Internet
- [RPubs](https://rpubs.com/Dutkiewicz/Tankstatistik): Projektpräsentation in Markdown (älteste, weiter aktualiserte Projektpräsentation).
- [Posit.Cloud](https://posit.cloud/content/3318758): Cloud-Version des R-Studio-Projekts (Benutzerkonto erforderlich).


### Daten und Erhebung
- Auto wird nur vom Urheber gefahren.
- Technische Daten des Autos: siehe Einleitung in [Tankstatistik_Markdown_GitHub.md](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik_Markdown_GitHub.md).
- Erhebungsbeginn ist 2014.
- Der Datensatz ist durch Verlust und erst später erhobene Beobachtungen lückenhaft. Die Rekonstruktion wird in den Markdown-Präsenation erläutert.


### Auswertung grundsätzlich
- <b>Work-In-Progress</b>
- Skript wird seit etwa 2015 entwickelt. Nach der ersten Version waren die meisten Änderungen nur inkrementell. Größere Enwicklungschübe gab es 2021/12 - 2022/01 (Abbildungen, Markdown, Cloud-Version auf Posit.Cloud), 2025/03 (Grundliegende Überarbeitung, Versionsverwaltung mit Git/GitHub) und ab 2025/07 (geplante Änderungen s.u.).


### Auswertung Skript
- Das [R-Skript](https://github.com/bartdutkiewicz/Tankstatistik/blob/main/Tankstatistik.r) ist für alle anderen Dokumente grundliegend!
- Das Skript hat monolithischen Charakter, da es historisch gewachsen ist. Eine Aufteilung in Module ist in Planung (s.u.).
- In der Datenaufbereitung und -Auswertung wird auf Pakete jenseits der R-Basis verzichtet. Dies ist bei Projektbeginn aus autodidaktischen Gründen entschieden worden und wird beibehalten.
- Für Abbildungen, Markdown und Exporte werden bekannte Pakete (z.B. die Paketfamilie "tidyverse") verwendet.
- Einige Kommentare sind "Notiz an den Urheber" aus während der Entwicklung gewonnenen Erkenntnissen über die Funktionsweise von R und anderen wichtigen Aspekten.


### Weiteres Vorgehen

- Modularisierung und Makefile.

- Rückrechnung der gefahrenen Kilometer verbessern (anhand der Kilometerstände der Protokolle der Hauptuntersuchungen).
