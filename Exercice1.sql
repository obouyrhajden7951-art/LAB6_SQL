-- ===============================
-- A. Création du schéma
-- ===============================
CREATE DATABASE universite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE universite;

-- Table ETUDIANT
CREATE TABLE ETUDIANT (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table PROFESSEUR
CREATE TABLE PROFESSEUR (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    departement VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table COURS
CREATE TABLE COURS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    credits INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table ENSEIGNEMENT
CREATE TABLE ENSEIGNEMENT (
    cours_id INT,
    professeur_id INT,
    semestre VARCHAR(20),
    PRIMARY KEY (cours_id, professeur_id, semestre),
    FOREIGN KEY (cours_id) REFERENCES COURS(id),
    FOREIGN KEY (professeur_id) REFERENCES PROFESSEUR(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table INSCRIPTION
CREATE TABLE INSCRIPTION (
    etudiant_id INT,
    enseignement_id INT,
    date_inscription DATE,
    PRIMARY KEY (etudiant_id, enseignement_id),
    FOREIGN KEY (etudiant_id) REFERENCES ETUDIANT(id),
    FOREIGN KEY (enseignement_id) REFERENCES ENSEIGNEMENT(cours_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table EXAMEN
CREATE TABLE EXAMEN (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inscription_id INT,
    date_examen DATE,
    score INT,
    CHECK (score BETWEEN 0 AND 20),
    FOREIGN KEY (inscription_id) REFERENCES INSCRIPTION(etudiant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ===============================
-- C. Insertion et tests
-- ===============================
-- Professeurs
INSERT INTO PROFESSEUR(nom,email,departement) VALUES
('Dr. Martin','martin@uni.com','Informatique'),
('Dr. Dupont','dupont@uni.com','Maths');

-- Cours
INSERT INTO COURS(titre,code,credits) VALUES
('Programmation','CS101',6),
('Mathématiques','MATH201',5),
('Physique','PHY101',4);

-- Etudiants
INSERT INTO ETUDIANT(nom,email) VALUES
('Alice','alice@mail.com'),
('Bob','bob@mail.com');

-- Enseignements
INSERT INTO ENSEIGNEMENT(cours_id,professeur_id,semestre) VALUES
(1,1,'S1'),
(2,2,'S1');

-- Inscriptions
INSERT INTO INSCRIPTION(etudiant_id,enseignement_id,date_inscription) VALUES
(1,1,'2025-09-01'),
(1,2,'2025-09-02'),
(2,1,'2025-09-01'),
(2,2,'2025-09-03');

-- Test erreur score invalide
-- INSERT INTO EXAMEN(inscription_id,date_examen,score) VALUES (1,'2025-12-09',25);
-- -> MySQL renverra une erreur : "CHECK constraint 'score between 0 and 20' fails"

-- Examens valides
INSERT INTO EXAMEN(inscription_id,date_examen,score) VALUES
(1,'2025-12-09',15),
(2,'2025-12-09',18),
(3,'2025-12-09',12),
(4,'2025-12-09',16);


-- ===============================
-- D. Sélection et filtrage
-- ===============================
-- Étudiants inscrits au cours CS101
SELECT e.nom
FROM ETUDIANT e
JOIN INSCRIPTION i ON e.id=i.etudiant_id
JOIN ENSEIGNEMENT en ON i.enseignement_id=en.cours_id
JOIN COURS c ON en.cours_id=c.id
WHERE c.code='CS101';

-- Professeurs du département Informatique
SELECT nom,email
FROM PROFESSEUR
WHERE departement='Informatique';

-- Inscriptions de Alice triées
SELECT *
FROM INSCRIPTION i
JOIN ETUDIANT e ON i.etudiant_id=e.id
WHERE e.nom='Alice'
ORDER BY date_inscription DESC;


-- ===============================
-- E. Jointures et sous-requêtes
-- ===============================
-- Pour chaque inscription : nom étudiant, titre cours, semestre, date inscription
SELECT e.nom AS etudiant, c.titre AS cours, en.semestre, i.date_inscription
FROM INSCRIPTION i
JOIN ETUDIANT e ON i.etudiant_id=e.id
JOIN ENSEIGNEMENT en ON i.enseignement_id=en.cours_id
JOIN COURS c ON en.cours_id=c.id;

-- Nombre de cours par étudiant (sous-requête corrélée)
SELECT e.nom,
   (SELECT COUNT(*)
    FROM INSCRIPTION i2
    WHERE i2.etudiant_id=e.id) AS nb_cours
FROM ETUDIANT e;

-- Vue regroupant nombre d'inscriptions et somme des crédits
CREATE OR REPLACE VIEW vue_etudiant_charges AS
SELECT e.id AS etudiant_id, e.nom AS etudiant_nom,
       COUNT(i.enseignement_id) AS nb_inscriptions,
       SUM(c.credits) AS total_credits
FROM ETUDIANT e
JOIN INSCRIPTION i ON e.id=i.etudiant_id
JOIN ENSEIGNEMENT en ON i.enseignement_id=en.cours_id
JOIN COURS c ON en.cours_id=c.id
GROUP BY e.id,e.nom;


-- ===============================
-- F. Agrégation et rapports
-- ===============================
-- Nombre d'inscriptions par cours
SELECT c.titre, COUNT(*) AS nb_inscriptions
FROM COURS c
JOIN ENSEIGNEMENT en ON c.id=en.cours_id
JOIN INSCRIPTION i ON en.cours_id=i.enseignement_id
GROUP BY c.id,c.titre;

-- Cours avec plus de 10 inscriptions
SELECT c.titre
FROM COURS c
JOIN ENSEIGNEMENT en ON c.id=en.cours_id
JOIN INSCRIPTION i ON en.cours_id=i.enseignement_id
GROUP BY c.id
HAVING COUNT(*)>10;

-- Moyenne des scores par semestre
SELECT en.semestre, ROUND(AVG(ex.score),2) AS moyenne_score
FROM EXAMEN ex
JOIN INSCRIPTION i ON ex.inscription_id=i.etudiant_id
JOIN ENSEIGNEMENT en ON i.enseignement_id=en.cours_id
GROUP BY en.semestre;


-- ===============================
-- G. Maintenance du schéma
-- ===============================
-- Ajouter colonne commentaire
ALTER TABLE EXAMEN ADD commentaire TEXT;

-