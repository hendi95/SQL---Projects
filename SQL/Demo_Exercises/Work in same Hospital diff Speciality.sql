-- DROP TABLE IF EXISTS users
DROP TABLE IF EXISTS doctors;

-- UP Metadata
CREATE TABLE doctors (
    id int primary key,
	name varchar(50) not null,
	speciality varchar(100),
	hospital varchar(50),
	city varchar(50),
	consultation_fee int
);

-- UP DATA
INSERT INTO doctors VALUES
    (1, 'Dr. Michael', 'Ayurveda', 'Mayo Clinic', 'New York', 2500),
    (2, 'Dr. Jessica', 'Homeopathy', 'Cleveland Clinic', 'Cleveland', 2000),
    (3, 'Dr. Christopher', 'Homeopathy', 'Johns Hopkins Hospital', 'Baltimore', 1000),
    (4, 'Dr. Williams', 'Dermatology', 'Massachusetts General Hospital', 'Boston', 1500),
    (5, 'Dr. Emily', 'Physician', 'Stanford Hospital', 'Palo Alto', 1700),
    (6, 'Dr. Daniel', 'Physician', 'UCSF Medical Center', 'San Francisco', 1500),
    (7, 'Dr. David', 'Cardiology', 'Mount Sinai Hospital', 'New York', 3000),
    (8, 'Dr. Olivia', 'Pediatrics', 'Childrens Hospital of Philadelphia', 'Philadelphia', 2200),
    (9, 'Dr. Andrew', 'Orthopedics', 'Brigham and Womens Hospital', 'Boston', 2800),
    (10, 'Dr. Sophia', 'Gynecology', 'Northwestern Memorial Hospital', 'Chicago', 2300),
    (11, 'Dr. Ethan', 'Ophthalmology', 'Bascom Palmer Eye Institute', 'Miami', 1900),
    (12, 'Dr. Ava', 'Dentistry', 'NYU Langone Health', 'New York', 1600),
    (13, 'Dr. William', 'Neurology', 'UCSF Medical Center', 'San Francisco', 3300),
    (14, 'Dr. Mia', 'Psychiatry', 'Massachusetts General Hospital', 'Boston', 2100),
    (15, 'Dr. Ethan', 'ENT', 'Johns Hopkins Hospital', 'Baltimore', 2500),
    (16, 'Dr. Olivia', 'General Surgery', 'Cleveland Clinic', 'Cleveland', 2400),
    (17, 'Dr. Liam', 'Urology', 'Mayo Clinic', 'Rochester', 2700),
    (18, 'Dr. Emma', 'Dermatology', 'Stanford Hospital', 'Palo Alto', 1500),
    (19, 'Dr. Lucas', 'Physiotherapy', 'UPMC Presbyterian Shadyside', 'Pittsburgh', 2000),
    (20, 'Dr. Harper', 'Homeopathy', 'Massachusetts General Hospital', 'Boston', 1800);


-- Verify
SELECT * FROM doctors;





-- Query 4: From the doctors table, fetch the details of doctors who work in the same hospital but in different speciality.

SELECT Distinct
    d1.id AS id1, d1.name AS name1, d1.speciality AS speciality1, d1.hospital AS hospital1, d1.city AS city1, d1.consultation_fee AS consultation_fee1
FROM doctors d1
JOIN doctors d2 ON d1.hospital = d2.hospital -- doctors at the same hospital
	AND d1.id < d2.id -- unique pairs of doctors
WHERE d1.speciality <> d2.speciality -- having different specialities

UNION ALL

SELECT 
    d2.id AS id2, d2.name AS name2, d2.speciality AS speciality2, d2.hospital AS hospital2, d2.city AS city2, d2.consultation_fee AS consultation_fee2
FROM doctors d1
JOIN doctors d2 ON d1.hospital = d2.hospital AND d1.id < d2.id
WHERE d1.speciality <> d2.speciality
order by hospital1
