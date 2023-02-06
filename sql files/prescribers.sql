-- 1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;
-- NPI: 1881634483, total_claim_count: 99,707

-- 1 b.  Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT nppes_provider_first_name AS first_name, nppes_provider_last_org_name AS last_name, specialty_description, SUM(total_claim_count) AS total_claims
FROM  prescription
INNER JOIN prescriber
USING(npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claims DESC;
-- Bruce Pendley, Family Practice, 99,707

WITH sum_claims AS (
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 5
)
SELECT sum_claims.npi,
 nppes_provider_first_name AS first_name,
 nppes_provider_last_org_name AS last_name,
 specialty_description,
 total_claims
FROM sum_claims
INNER JOIN prescriber AS p
ON sum_claims.npi = p.npi
ORDER BY total_claims DESC;

-- 2. 
   -- a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;
-- Family Practice

-- b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS claims
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y' 
GROUP BY specialty_description
ORDER BY claims DESC;
-- Nurse Practitioner
-- Another way:
SELECT specialty_description, SUM(total_claim_count) AS claims
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN
(
SELECT DISTINCT drug_name,
 opioid_drug_flag
FROM drug
) sub
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY claims DESC;

   -- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT specialty_description, COUNT(total_claim_count)
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
HAVING COUNT(total_claim_count) = 0;
-- OR
(
SELECT DISTINCT specialty_description
FROM prescriber
)
EXCEPT
(
SELECT DISTINCT specialty_description
FROM prescriber
INNER JOIN prescription
USING(npi)
);
-- OR
SELECT DISTINCT specialty_description  
FROM prescriber
WHERE specialty_description NOT IN
		(
			select distinct specialty_description  
			from prescriber pr
			inner join prescription pn 
			on pr.npi= pn.npi 
		)
ORDER BY specialty_description;
-- OR
SELECT *
FROM (SELECT DISTINCT specialty_description
	  FROM prescriber -- There are 107 specialites here
	 ) AS all_specialties
WHERE specialty_description NOT IN (SELECT DISTINCT specialty_description
									FROM prescription as rx
									LEFT JOIN prescriber as doc
									USING(npi)) -- There are 92 specialites here

   -- d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost)::money AS highest_cost
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY highest_cost DESC;
-- Insulin

   --  b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name, SUM(total_drug_cost)::money AS total_cost, SUM(total_day_supply) AS total_supply, SUM(total_drug_cost)::money / SUM(total_day_supply) AS cost_per_day
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;

-- 4. 
   -- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name, (CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 		                      'opioid'
                   WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
                   ELSE 'neither'
                   END) AS drug_type
FROM drug
ORDER BY drug_type;

  -- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT (CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 		                      'opioid'
        WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
        ELSE 'neither'
        END) AS drug_type,
	    SUM(total_drug_cost) AS total_cost
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY (CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 		                     'opioid'
          WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
          ELSE 'neither'
          END)
ORDER BY total_cost DESC;
-- More money was spent on opiods.
5. 
   -- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN';
-- 33

  --  b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population) AS total_population
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC
-- Nashville-Davidson

  --  c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, population
FROM fips_county
INNER JOIN population
USING(fipscounty)
WHERE fipscounty NOT IN 
                       (SELECT fipscounty
					    FROM cbsa)
GROUP BY county, population
ORDER BY population DESC; 
-- Sevier
6. 
   -- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count AS total_claims
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claims DESC;

  --  b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
-- SELECT drug_name, total_claim_count AS total_claims, 
-- 	(CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 		                    'Yes'
--      ELSE 'No'
--      END) AS opioid
-- FROM prescription
-- INNER JOIN drug
-- USING(drug_name) 
-- WHERE total_claim_count >= 3000
-- ORDER BY total_claims DESC;

SELECT drug_name, total_claim_count, opioid_drug_flag AS opioid
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count >= 3000
 AND opioid_drug_flag = 'Y' OR opioid_drug_flag = 'N'
ORDER BY opioid DESC;

   -- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
-- SELECT drug_name, total_claim_count AS total_claims, 
-- 	(CASE WHEN opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y' THEN 		                    'Yes'
--      ELSE 'No'
--      END) AS opioid, nppes_provider_last_org_name, nppes_provider_first_name
-- FROM prescription
-- INNER JOIN drug
-- USING(drug_name) 
-- WHERE total_claim_count >= 3000
-- ORDER BY total_claims DESC;

SELECT drug_name, total_claim_count, opioid_drug_flag AS opioid, nppes_provider_last_org_name, nppes_provider_first_name
FROM prescription 
LEFT JOIN prescriber 
USING(npi)
LEFT JOIN drug 
USING(drug_name)
WHERE total_claim_count >= 3000
 AND opioid_drug_flag = 'Y'OR opioid_drug_flag = 'N'
ORDER BY opioid DESC;

7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

  --  a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
-- SELECT npi, drug_name
-- FROM prescriber
-- CROSS JOIN drug
-- WHERE specialty_description = 'Pain Management'
-- AND nppes_provider_city = 'NASHVILLE'
-- AND opioid_drug_flag = 'Y';

SELECT npi, drug_name
FROM prescriber, drug
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE' 
AND opioid_drug_flag = 'Y';

  --  b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT prescriber.npi, drug.drug_name AS drug_name, SUM(total_claim_count) AS claims
FROM prescriber, drug
INNER JOIN prescription
USING(drug_name) 
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE' 
AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug_name
ORDER BY claims DESC;

   -- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
   
   
   
   









