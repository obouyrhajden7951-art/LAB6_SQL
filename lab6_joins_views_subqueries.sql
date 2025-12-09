-- =========================================
-- Lab 6 – Jointures, vues et sous-requêtes
-- =========================================

-- =========================================
-- Étape 1 – Connexion et contexte
-- =========================================
-- mysql -u root -p
-- USE bibliotheque;

-- =========================================
-- Étape 2 – Jointures classiques
-- =========================================

-- INNER JOIN : tous les emprunts avec le nom de l'abonné
SELECT e.id, a.nom, e.date_debut
FROM emprunt e
INNER JOIN abonne a 
  ON e.abonne_id = a.id;

-- LEFT JOIN : tous les ouvrages et dernier emprunt si disponible
SELECT o.titre, MAX(e.date_debut) AS dernier_emprunt
FROM ouvrage o
LEFT JOIN emprunt e 
  ON e.ouvrage_id = o.id
GROUP BY o.id, o.titre;

-- RIGHT JOIN : symétrique du LEFT JOIN (moins utilisé)
-- Exemple non obligatoire, syntaxe similaire

-- CROSS JOIN : produit cartésien abonnés × auteurs
SELECT a.nom AS abonne, au.nom AS auteur
FROM abonne a
CROSS JOIN auteur au;

-- =========================================
-- Étape 3 – Création et utilisation de vues
-- =========================================

-- Créer une vue : nombre d'emprunts par abonné
CREATE OR REPLACE VIEW vue_emprunts_par_abonne AS
SELECT a.id, a.nom, COUNT(e.id) AS total_emprunts
FROM abonne a
LEFT JOIN emprunt e 
  ON e.abonne_id = a.id
GROUP BY a.id, a.nom;

-- Interroger la vue
SELECT * 
FROM vue_emprunts_par_abonne
WHERE total_emprunts > 5;

-- Supprimer la vue si nécessaire
-- DROP VIEW vue_emprunts_par_abonne;

-- =========================================
-- Étape 4 – Sous-requêtes non corrélées
-- =========================================

-- Sous-requête dans SELECT : nb d'emprunts par ouvrage
SELECT 
  titre,
  (SELECT COUNT(*) 
   FROM emprunt e 
   WHERE e.ouvrage_id = o.id
  ) AS nb_emprunts
FROM ouvrage o;

-- Sous-requête dans WHERE : abonnés > 3 emprunts
SELECT nom, email
FROM abonne
WHERE id IN (
  SELECT abonne_id
  FROM emprunt
  GROUP BY abonne_id
  HAVING COUNT(*) > 3
);

-- =========================================
-- Étape 5 – Sous-requêtes corrélées
-- =========================================

-- Premier emprunt de chaque abonné
SELECT a.nom,
  (SELECT o.titre 
   FROM emprunt e2 
   JOIN ouvrage o ON e2.ouvrage_id = o.id
   WHERE e2.abonne_id = a.id
   ORDER BY e2.date_debut
   LIMIT 1
  ) AS premier_titre
FROM abonne a;

-- =========================================
-- Étape 6 – Combiner vues et sous-requêtes
-- =========================================

-- Vue résumant les emprunts par mois
CREATE OR REPLACE VIEW vue_emprunts_mensuels AS
SELECT 
  YEAR(date_debut) AS annee,
  MONTH(date_debut) AS mois,
  COUNT(*) AS total_emprunts
FROM emprunt
GROUP BY annee, mois;

-- Mois les plus chargés par année
SELECT v.annee, v.mois, v.total_emprunts
FROM vue_emprunts_mensuels v
WHERE v.total_emprunts = (
  SELECT MAX(total_emprunts)
  FROM vue_emprunts_mensuels
  WHERE annee = v.annee
);

-- =========================================
-- Étape 7 – Exercices pratiques
-- =========================================

-- Exercice 1 : auteurs sans ouvrage
SELECT au.nom
FROM auteur au
LEFT JOIN ouvrage o ON o.auteur_id = au.id
WHERE o.id IS NULL;

-- Exercice 2 : nombre d'abonnés ayant emprunté au moins une fois par mois
CREATE OR REPLACE VIEW vue_abonnes_mensuels AS
SELECT 
  YEAR(e.date_debut) AS annee,
  MONTH(e.date_debut) AS mois,
  COUNT(DISTINCT e.abonne_id) AS nb_abonnes
FROM emprunt e
GROUP BY annee, mois;

SELECT * FROM vue_abonnes_mensuels;

-- Exercice 3 : abonné ayant emprunté le plus récemment chaque ouvrage
SELECT o.titre, 
  (SELECT a.nom
   FROM emprunt e2
   JOIN abonne a ON e2.abonne_id = a.id
   WHERE e2.ouvrage_id = o.id
   ORDER BY e2.date_debut DESC
   LIMIT 1
  ) AS dernier_abonne
FROM ouvrage o;


