# Prompt pour Claude Code : Tchip !

Tu vas m'aider à développer « Tchip ! », une app Android en Flutter qui lit les SMS Mobile Money (MTN, Moov, Celtiis au Bénin), classe les dépenses et aide à rester sous un plafond en FCFA.

## Ce que tu as dans ce dossier

- `docs/Plan_projet_Tchip.pdf` : le plan complet (périmètre v1, stack, tables SQLite, planning sur 5 semaines, critères de réussite). C'est la référence fonctionnelle.
- `docs/Tchip_design_Hux_palette.xlsx` : la palette, l'évaluation de Hux UI et les règles de lisibilité.
- `maquette/*.dc.html` : la maquette validée, un fichier par écran. Le HTML ne s'ouvre pas seul dans un navigateur (il dépend d'un runtime absent), lis-le comme une spécification : structure, textes, tailles, couleurs, espacements, états.
- `maquette/canvas.json` : la liste des écrans et leur ordre.

Lis le PDF et tous les fichiers de la maquette avant d'écrire du code.

## Écrans à reproduire

| Fichier | Écran |
|---|---|
| Splash.dc.html | Écran de chargement animé |
| Onboarding.dc.html | Bienvenue et permission SMS |
| Main.dc.html | Accueil (plan en cours, carte Aujourd'hui, reçu et frais du mois, dernières opérations). États OK / alerte 80 % / dépassé |
| Jour.dc.html | Écran du jour : dépensé, plafond et reste par catégorie, sélecteur Lun à Dim, plafond ponctuel |
| Operations.dc.html | Liste des opérations, recherche, filtres par opérateur, bandeau « à classer », frais sous chaque montant |
| Ajout.dc.html | Ajout d'une dépense en espèces |
| Budget.dc.html | Plans : période (un jour, une semaine, dates libres), plafond global, plafonds par catégorie « par jour » ou « sur la période », plafonds ponctuels, alertes |
| Bilan.dc.html | Bilan : sélecteur de période, totaux, frais par type, répartition par catégorie, tendance 3 mois, top contreparties |
| Reglages.dc.html | Réglages : langue (automatique, français, anglais), opérateurs suivis, données 100 % locales |
| Widget.dc.html | Widget d'écran d'accueil Android : catégorie puis montant, en deux touches |
| Tablette.dc.html | Accueil sur tablette en paysage : 3 colonnes et navigation latérale (NavigationRail) |

Navigation du bas sur téléphone : Accueil, Opérations, bouton + central (ajout espèces), Bilan, Plans. L'icône réglages est en haut à droite de l'accueil.

## Design

- Mode sombre par défaut. Fond `#121212`, cartes `#1B1B1B`, bordures `#262626`, texte `#F2F2F2`, texte secondaire `#9A9A9A`.
- Jaune principal `#E8B931` (boutons, éléments actifs), jaune clair `#FBF1D3` (puces, sélection), jaune foncé `#A87F12` (bouton pressé), texte sur jaune `#1F1B10`.
- États du budget : OK `#2E9E6A`, alerte 80 % `#E07A2E`, dépassé `#D64545`. Ne jamais écrire en jaune sur fond blanc.
- Couleurs de catégories : Nourriture `#7FB7FF`, Transport `#C79BFF`, Forfaits `#5FD0C4`, Famille `#FF9DB8`, Loisirs `#D7C96A`.
- Police Geist pour l'interface, Geist Mono pour les montants (package google_fonts ou polices embarquées).
- Hux UI pour les composants de base, fl_chart pour les graphiques. Centralise couleurs, tailles et rayons dans un fichier de thème à moi (`lib/theme/`), pas en dur dans les widgets.
- Le nom s'écrit « Tchip ! » avec une espace insécable fine avant le « ! », et le « ! » en jaune.

## Écran de chargement (à respecter précisément)

1. `flutter_native_splash` : fond `#121212` au démarrage natif.
2. Puis animation Flutter : les lettres T, c, h, i, p apparaissent une à une (0,35 s chacune, décalage de 80 ms, légère montée de 14 px).
3. Le « ! » jaune tombe de 60 px à 0,5 s et rebondit deux fois (0,6 s).
4. Le message « Tes finances sous contrôle. » apparaît en fondu à 1,1 s et reste affiché, sans clignoter.
5. Effet domino tant que le chargement des données est en cours : chaque lettre pivote de 16° vers la droite (pivot en bas à droite) puis se redresse, en décalé de 100 ms de T jusqu'au « ! », et la vague repart toutes les 1,8 s.
6. Dès que les données sont prêtes, arrêter la boucle et passer à l'accueil. Respecter le réglage « réduire les animations » du système.

## Contraintes

- Données 100 % locales (sqflite), aucun appel réseau.
- Aucun texte en dur : tout passe par `flutter_localizations` + `intl` avec des fichiers ARB `fr` et `en`. Langue de l'appareil par défaut, modifiable dans Réglages. Montants et dates au format de la langue (12 500 F en français, 12,500 F en anglais).
- Responsive : LayoutBuilder et MediaQuery, rien de coupé à 320 dp de large ni avec la police système à 130 %, mode paysage et tablette gérés.
- Zones tactiles d'au moins 48 dp, libellés d'accessibilité sur les boutons icône.
- Riverpod pour l'état. Tests unitaires du parser avec flutter_test.
- Package `com.tchipmo.app`. Le keystore et `key.properties` restent hors du dépôt (`.gitignore`).

## Comment avancer

1. Commence par me proposer l'arborescence du projet et la liste des étapes, calée sur le planning du PDF (semaine 1 : parser, semaine 2 : données, etc.). Attends ma validation avant de coder.
2. Mets en place le thème, la traduction FR / EN et la navigation avant le premier écran.
3. Avance par étapes courtes : à chaque étape, dis ce que tu as fait, comment le tester sur mon téléphone (`flutter run`) et ce qui vient ensuite.
4. Tant que le parser n'est pas prêt, utilise des données d'exemple qui ressemblent à celles de la maquette.
5. Si un point de la maquette contredit le PDF, suis le PDF et signale-le moi.
