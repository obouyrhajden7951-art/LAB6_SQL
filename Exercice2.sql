-- ===============================
-- Exercice 2 – Jointures et vues
-- ===============================

-- Sélection de la base
USE universite;

-- ===============================
-- INNER JOIN : nom étudiant, titre cours, date examen, score
-- On relie EXAMEN à INSCRIPTION, ETUDIANT et ENSEIGNEMENT puis COURS
SELECT e.nom AS etudiant, c.titre AS cours, ex.date_examen, ex.score
FROM EXAMEN ex
JOIN INSCRIPTION i ON ex.inscription_id = i.etudiant_id
JOIN ETUDIANT e ON i.etudiant_id = e.id
JOIN ENSEIGNEMENT en ON i.enseignement_id = en.cours_id
JOIN COURS c ON en.cours_id = c.id;

-- ===============================
-- LEFT JOIN : tous les étudiants et nombre d'examens passés
-- Si un étudiant n'a passé aucun examen, afficher 0
SELECT e.nom, COUNT(ex.id) AS nb_examens
FROM ETUDIANT e
LEFT JOIN INSCRIPTION i ON e.id = i.etudiant_id
LEFT JOIN EXAMEN ex ON i.etudiant_id = ex.inscription_id
GROUP BY e.id, e.nom;

-- ===============================
-- RIGHT JOIN : tous les cours et nombre d'étudiants inscrits
-- Affiche 0 si aucun étudiant
SELECT c.titre, COUNT(DISTINCT i.etudiant_id) AS nb_etudiants
FROM COURS c
RIGHT JOIN ENSEIGNEMENT en ON c.id = en.cours_id
LEFT JOIN INSCRIPTION i ON en.cours_id = i.enseignement_id
GROUP BY c.id, c.titre;

-- ===============================
-- CROSS JOIN : toutes les paires Étudiant–Professeur
-- Limite aux 20 premières lignes
-- Attention : CROSS JOIN génère toutes les combinaisons possibles, donc le nombre de lignes = nb_etudiants * nb_professeurs
SELECT e.nom AS etudiant, p.nom AS professeur
FROM ETUDIANT e
CROSS JOIN PROFESSEUR p
LIMIT 20;

-- ===============================
-- Création d'une vue : vue_performances
-- Pour chaque étudiant, renvoie la moyenne des scores
-- Les étudiants n'ayant passé aucun examen apparaissent avec NULL
CREATE OR REPLACE VIEW vue_performances AS
SELECT e.id AS etudiant_id,
       e.nom,
       AVG(ex.score) AS moyenne_score
FROM ETUDIANT e
LEFT JOIN INSCRIPTION i ON e.id = i.etudiant_id
LEFT JOIN EXAMEN ex ON i.etudiant_id = ex.inscription_id
GROUP BY e.id, e.nom;

-- ===============================
-- Common Table Expression (CTE) : top 3 cours avec meilleure moyenne
-- top_cours contient cours_id et moyenne_score
WITH top_cours AS (
    SELECT c.id AS cours_id, AVG(ex.score) AS moyenne_score
    FROM COURS c
    JOIN ENSEIGNEMENT en ON c.id = en.cours_id
    JOIN INSCRIPTION i ON en.cours_id = i.enseignement_id
    JOIN EXAMEN ex ON i.etudiant_id = ex.inscription_id
    GROUP BY c.id
    ORDER BY moyenne_score DESC
    LIMIT 3
)
-- Requête principale : afficher titre, credits, moyenne_score des cours top 3
SELECT c.titre, c.credits, t.moyenne_score
FROM top_cours t
JOIN COURS c ON t.cours_id = c.id;
