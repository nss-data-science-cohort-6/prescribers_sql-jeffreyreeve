-- 1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY NPI
ORDER BY total_claims DESC;
-- NPI: 1275934788, total_claim_count: 50

-- 1 b.  Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT nppes_provider_first_name AS first_name, nppes_provider_last_org_name AS last_name, specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claims DESC;
-- Bruce Pendley

-- 2. 
   -- a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;
-- Family Practice

-- b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS claims
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
INNER JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY claims DESC;
-- Nurse Practitioner

   -- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

   -- d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost) AS highest_cost
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY highest_cost DESC;
-- Insulin

   --  b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT *
FROM prescription
LIMIT 5; 
   
   
   
   









