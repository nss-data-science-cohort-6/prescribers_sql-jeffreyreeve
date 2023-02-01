-- 1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
LIMIT 1 
-- NPI: 1275934788, total_claim_count: 50
-- b.  Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

