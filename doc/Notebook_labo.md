# Cahier de labo - Analyse métagénomique

## Semaine 12/01

### Objectifs
- Découvrir le sujet de stage en profondeur
- Comprendre les objectifs attendus
- Faire de la bibliographie sur le sujet de stage
  

### Complets
- Compréhension minimale du sujet
- Installation de mamba sur le serveur Soere-meb
- Bibiographie et découverte des outils utilisés
- Papier de [Banerjee et al.(2024)](https://doi.org/10.1016/j.xpro.2024.103167) : expose les outils qui peut être utilisé pour le sujet
- Papier de [Yazhini et al.(2025)](https://doi.org/10.1093/bib/bbaf617) : faire la comparaison des outils qu'on peut utiliser
- Papier de [Yan et al.(2025)](https://doi.org/10.1128/msystems.01428-24) : un peu la même idée que le sujet, regarde sur les outils utilisés, les génes de resistances qu'on peut observés dans nos resultats
- Papier de [Mirete et al.(2025)](https://doi.org/10.3390/microorganisms13050985) : expose les défis progrés et parle des outils de binning et raffinement qu'on peut utiliser
- Papier de [Bay et al.(2025)](https://doi.org/10.1038/s41467-025-65209-w) : regarde sur les outils de binning utiliser
- Papier de [Silvester et al.(2025)](https://doi.org/10.1016/j.scitotenv.2025.180607) : métagénomique sur échantillons d'eau usées municipaux et hospitaliers, regarde sur les outils utilisés et résultats obtenus
- Papier de [Hang et al.(2025)](https://doi.org/10.1038/s41467-025-57957-6) : benchmarking des outils de binning et des modes de binning


### Discussion
Dans ce projet, on doit pourvoir reconstruire des MAG (Génomes assemblés par métagénome), et faire la recherche des facteurs de virulences et de gènes de resitances aux antibiotiques. Pendant cette première semaine, on a lu des articles afin d'avoir une idée de conmment reconstruire des MAG et des outils utilisés pour le faire. On a également decouvert les échantillons à analyser et leurs provenances. 

### En cours
- Bibliographie et découverte du sujet

### A faire
- Bibliographie
- Faire un plan pour le sujet et les outils à utilser
- Lecture des papiers de chaque outil pour voir une idée de comment ils traitent les données

---

## Semaine 19/01

### Objectifs
- Plan des étapes et outils afin d'atteindre les attendus du projet
- Bibliographies sur les outils à utiliser pour ce projet
  


### Complets
- Accès au serveur HCP mesocentre
- Lecture des papiers des outils Metabat2 [Kang et al.(2019)](https://doi.org/10.7717/peerj.7359), Semibin2 [Pan et al.(2023)](https://doi.org/10.1093/bioinformatics/btad209), COMEBin [Wang et al.(2024)](https://doi.org/10.1038/s41467-023-44290-z), DAS_Tool [Sieber et al.(2018)](https://doi.org/10.1038/s41564-018-0171-1),CoverM [Aroney et al.(2025)](https://doi.org/10.1093/bioinformatics/btaf147), dRep [Olm et al.(2017)](https://doi.org/10.1038/ismej.2017.126)
- Approfondissement des connaissances et explications sur les différents modes de binning
- Installation des outils de binning grâce informations des git de chaque outil : metabat2, semibin2, das_tool , dRep , CheckM2 , rgi 
- Test des outils metabat2, semibin2, drep, rgi sur un seul échantillon
- Plan des étapes à suivre et choix des outils à utiliser


### Discussion
Les premiers outils de binning qu'on va utiliser ont été vu en détail afin de savoir et d'avoir une idée de comment ils analysent des données. On a rencontré un peu de diffilculté à installer l'outil COMEBin malgré le suivie des instructions du git des auteurs. On avait faire les tests de certains outils avec les options par défaut, mais on a decouvert qu'on pouvais mettre la taille max des contigs en partitulier pour les outils comme metabat2 et semibin2. Lors de la petite réunion hebdomadaire, on a choisit de regrouper tout les echantillons assemblés du projet dissemin pour faire un seul binning (co-binning ou binning multi échantillons). Le choix des outils a été faire en suivant la biblio. 


### En cours
- Test des outils, bibliographie sur comment les faires fonctionner

### A faire
- Test avec plus d'échantillons
- Installer d'autres outils à utiliser
- Apprendre à les faire fonctionner, recherche sur leurs git

---


## Semaine 26/01

### Objectifs
- Installer d'autres outils de binnning qu'on va utiliser
- Continuer le test avec les outils déjà installés, en ajoutant les options des outils sur plus échantillons
- Tester les nouveaux outils installés


### Complets
- Installation des outils dans différents environnements: metabat2, semibin2, das_tool (env : binning), dRep (env : drep) , CheckM2 (env : checkm2), CheckM (env : checkm), rgi (env : rgi), coverm (env : coverm), gtdb-tk (env : gtdbtk), prokka (env : prokka)
- Biblio sur l'outi gtdb-tk [Chaumeil et al.(2019)](https://doi.org/10.1093/bioinformatics/btz848)
- Téléchargement des databases de checkm, checkm2, gtdb-tk
  


### Discussion
Les outils étaient dans le même environnement conda et on avait des conflits entre outils. Cette fois, ils sont installés dans différents environnement à l'exception des outils metabat2, semibin2, das-tool qui sont ensemble. On a rencontré des diffilcultés à faire des tests sur plus de deux échantillons car on travail dans le home du mesocentre. Lors de la réunion on a appris qu'on pouvait travailler dans le scratch de mesocentre, et on peut faire des copies d'un serveur à un autre donc on travailler avec plus d'échantillons. Dans le montage de scoere-meb on a assez d'espace pour tout les résultats à produire.

### En cours 
- Test des outils 

### A faire
- Faire les analyses avec les outils déjà tester sur l'ensemble des échantillons de dissémin
- Continuer à essayer de faire fonctionner les outils suivants
- Regarder outil cd-hit-est pour dérépliquer les contigs avant le binning


---


## Semaine 02/02


### Objectifs
- Faire les outils metabat2, semibin2, das_tool sur l'ensemble des échantillons du projet dissémin
- Installer cd-hit-est et l'utiliser
  

### Complets
- Utilisation de l'outil Cd-hit [Li et Godzik (2006)](https://doi.org/10.1093/bioinformatics/btl158), et installation dans l'environnement (env : binning)
- Recherche sur l'outil AMRFinderPlus [Feldgarden et al.(2021)](https://doi.org/10.1038/s41598-021-91456-0) : à utiliser, plus database pour la recherche de facteurs de virulences dans les MAG


### Discussion
L'outil cd-hit-est permet la déréplication de contigs, surtout dans notre cas où on concaterne tout les fasta. 
Pour l'annotation fonctionnelle, l'outil Bakta a été choisi lors de la réunion hebdomadaire car plus complet et avec une annotation direct des facteurs de virulence et de génes de résistances aux antibiotiques (contient ces databases)


### En cours 
- Faire les premieres étapes de binning en assemblant tout les données dissemin et non pas sous groupes

### A faire
- Pourvoir installer et faire fonctionner COMEBin, pour avoir une outil de binning en plus
- Regarder de plus prêt l'outil Bakta et sa base de données ainsi que les bases de données intégrés


---

## Semaine 09/02

### Objectifs
- Tester l'outil COMEBIN

### Complets
- Test de cd-hit-est sur un plus grand jeu de données : échec
- Test de CheckM et CheckM2 : pour comparaison de résultats

### Discussion
- Pendant cette semaine, on a essayé de faire les étapes, d'alignements des reads, metabat, semibin et das_tool ensemble. Mais pas assez de ressources ou jobs en attente ou pas assez de temps demandés. Du coup, on a eu l'idée de paralléliser les étapes : d'abord l'obtention des contigs_index, des bam et les binning , le tout séparé dans différents job.
- Pour Comebin, pas de reussite pour l'instant, affiche des erreurs qu'on ne comprends pas pour l'instant
- L'outil cd-hit-est permet la déréplication de contigs, surtout dans notre cas où on concaterne tout les fasta. Mais l'outil a des limites comme le fait de ne pas pourvoir gérer un contig de grand taille : limite à environ 7000 bp. Du coup, ceci est une des raisons pour lesquelles on abondanne l'idée et également le fait que dans la littérature cette étape n'est pas fait pour la formation des MAGS. Mais on pourvait également le faire avec mmseqs la déréplication des contigs

  
### En cours 
- Continuer à faire fonctionner l'outil Comebin
- Obtention des contigs_index et des bam de cette échantillons
    
### A faire
- Faire le binning sur l'ensemble de dissemin en parallélisant l'utilisation des différents outils


---

## Semaine 16/02

### Objectifs
- Faire le binning sur l'ensemble de dissemin en parallélisant l'utilisation des différents outils
- Test Bakta, Comebin

  
### Complets
- Lecture papier [De Yebra et al.(2026)](https://www.medrxiv.org/content/10.64898/2026.01.25.26344777v1) : regarde sur les résultats obtenus
- Lecture du papier de [Shen et al.(2026)](https://www.sciencedirect.com/science/article/pii/S0048969725027858) : regarde sur les résultats obtenus

### Discussion
Pendant la semaine, problème avec le montage du dossier où doit être les résultats sur le serveur soere-meb. Tout les jobs lancés ont été annulés. Également les bam formés sont tronqués, car on avait pas mise assez de ram pour les jobs. La formation des Bam ont été repris

### En cours 

### A faire



---

## Semaine 23/02

### Objectifs

### Complets

### Discussion

### En cours 

### A faire


----


































