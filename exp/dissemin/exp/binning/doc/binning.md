## Documentation du dossier binning

### Objectifs du dossier  
Ce dossier ```binning```comprend les étapes de reconstruction des génomes métagénomiques (MAGs) à partir des contigs assemblés issus de nos échantillons.
Il contient les scripts nécessaires pour :
- Préparer les fichiers d'entrée (BAM, Contigs indexés)
- Générer des bins avec les outils **MetaBAT2** et **SemiBin2**
- Raffiner les bins pour obtenir des MAGs de bonne qualité avec **DAS_Tool**
- La déréplication des bins pour éviter des MAGs redondants avec **dRep**

### Organisation du dossier

```
.
├── bin
│   ├── array_bam.slurm
│   ├── contig_index.slurm
│   └── metabat.slurm
├── doc
│   └── binning.md
├── env
├── log
└── results

```

### Description des étapes


### Résultats obtenus
