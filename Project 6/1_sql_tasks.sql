---
SELECT COUNT(id)
FROM company
WHERE status = 'closed';

---
SELECT funding_total
FROM company
WHERE category_code = 'news'
  AND country_code = 'USA'
ORDER BY funding_total DESC;

---
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
  and EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN 2011 AND 2013;

---
SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

---
SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
  AND last_name LIKE 'K%';

---
SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

---
SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) > 0
   AND MIN(raised_amount) != MAX(raised_amount);

---
SELECT *,
       CASE
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN 20 <= invested_companies AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies < 20 THEN 'low_activity'
       END
FROM fund;

---
WITH
fn AS (SELECT *,
              CASE
                  WHEN invested_companies>=100 THEN 'high_activity'
                  WHEN invested_companies>=20 THEN 'middle_activity'
                  ELSE 'low_activity'
              END AS activity
       FROM fund)

SELECT activity,
       ROUND(AVG(investment_rounds))
FROM fn
GROUP BY activity
ORDER BY ROUND(AVG(investment_rounds));

---
SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) between 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC
LIMIT 10;


---
SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT OUTER JOIN education AS e ON p.id=e.person_id;

---
SELECT c.name,
       COUNT(DISTINCT e.instituition)
FROM company AS c
LEFT OUTER JOIN people AS p ON c.id=p.company_id
JOIN education AS e ON p.id=e.person_id
GROUP BY c.name
ORDER BY COUNT(DISTINCT e.instituition) DESC
LIMIT 5;

---
SELECT DISTINCT(c.name)
FROM company AS c
LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
WHERE c.status = 'closed'
  AND (fr.is_first_round = 1 AND fr.is_last_round = 1);

---
SELECT p.id
FROM people AS p
LEFT OUTER JOIN company AS c ON p.company_id=c.id
WHERE c.name IN (SELECT DISTINCT(c.name)
                 FROM company AS c
                 LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                 WHERE c.status = 'closed'
                   AND (fr.is_first_round = 1 AND fr.is_last_round = 1))

---
WITH 
n AS (SELECT p.id
      FROM people AS p
      LEFT OUTER JOIN company AS c ON p.company_id=c.id
      WHERE c.name IN (SELECT DISTINCT(c.name)
                       FROM company AS c
                       LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                       WHERE c.status = 'closed'
                         AND (fr.is_first_round = 1 AND fr.is_last_round = 1)))
SELECT DISTINCT(n.id),
       e.instituition
FROM n
JOIN education AS e ON n.id=e.person_id;

---
SELECT nn.id,
       COUNT(nn.instituition)
FROM (WITH 
      n AS (SELECT p.id
            FROM people AS p
            LEFT OUTER JOIN company AS c ON p.company_id=c.id
            WHERE c.name IN (SELECT DISTINCT(c.name)
                             FROM company AS c
                             LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                             WHERE c.status = 'closed'
                             AND (fr.is_first_round = 1 AND fr.is_last_round = 1)))
      SELECT n.id,
             e.instituition
      FROM n
      JOIN education AS e ON n.id=e.person_id) AS nn
GROUP BY id;

---
WITH
nnn AS (SELECT nn.id,
               COUNT(nn.instituition)
        FROM (WITH 
              n AS (SELECT p.id
                    FROM people AS p
                    LEFT OUTER JOIN company AS c ON p.company_id=c.id
                    WHERE c.name IN (SELECT DISTINCT(c.name)
                                     FROM company AS c
                                     LEFT OUTER JOIN funding_round AS fr ON c.id=fr.company_id
                                     WHERE c.status = 'closed'
                                       AND (fr.is_first_round = 1 AND fr.is_last_round = 1)))
      SELECT n.id,
             e.instituition
      FROM n
      JOIN education AS e ON n.id=e.person_id) AS nn
GROUP BY id)
SELECT AVG(nnn.COUNT)
FROM nnn;

---
WITH
nnn AS (SELECT nn.id,
               COUNT(nn.instituition)
        FROM (WITH 
              n AS (SELECT p.id
                    FROM people AS p
                    LEFT OUTER JOIN company AS c ON p.company_id=c.id
                    WHERE c.name = 'Facebook')
              SELECT n.id,
                     e.instituition
              FROM n
              JOIN education AS e ON n.id=e.person_id) AS nn
              GROUP BY id)
SELECT AVG(nnn.COUNT)
FROM nnn;

---
WITH
c AS (SELECT id,
             name
      FROM company
      WHERE milestones > 6),
fr AS (SELECT id,
              company_id,
              raised_amount
       FROM funding_round
       WHERE EXTRACT(YEAR FROM CAST(funded_at AS date)) BETWEEN 2012 AND 2013)
SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM fund AS f
JOIN investment AS i ON f.id=i.fund_id
JOIN fr ON i.funding_round_id=fr.id
JOIN c ON fr.company_id=c.id;

---
SELECT c.name AS acquiring_company,
       a.price_amount,
       cc.name AS acquired_company,
       cc.funding_total,
       ROUND(a.price_amount/cc.funding_total)
FROM acquisition AS a
JOIN company AS c ON a.acquiring_company_id=c.id
LEFT OUTER JOIN company AS cc ON a.acquired_company_id=cc.id
WHERE price_amount != 0 AND cc.funding_total !=0
GROUP BY a.acquiring_company_id, c.name, a.acquired_company_id, cc.name, a.price_amount, cc.funding_total
ORDER BY a.price_amount DESC, cc.name ASC
LIMIT 10;

---
SELECT c.name,
       EXTRACT(MONTH FROM CAST(f.funded_at AS date)) AS month
FROM company AS c
LEFT OUTER JOIN funding_round AS f ON c.id=f.company_id
WHERE c.category_code='social'
  AND EXTRACT(YEAR FROM CAST(f.funded_at AS date)) BETWEEN 2010 AND 2013
  AND f.raised_amount != 0;

---
WITH
a AS (SELECT EXTRACT(MONTH FROM CAST(acquired_at AS date)) AS month,
             COUNT(acquired_company_id) AS acquired_company,
             SUM(price_amount) AS amountsum
      FROM acquisition
      WHERE EXTRACT(MONTH FROM CAST(acquired_at AS date)) IS NOT NULL
        AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN 2010 AND 2013
      GROUP BY month
      ORDER BY month),
p AS (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) AS month,
             COUNT(DISTINCT f.name) AS fundcount
      FROM funding_round AS fr
      JOIN investment AS i ON fr.id=i.funding_round_id
      LEFT OUTER JOIN fund AS f ON i.fund_id=f.id
      WHERE f.country_code='USA'
        AND EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) IS NOT NULL
        AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2010 AND 2013
      GROUP BY month
      ORDER BY month)
SELECT p.month,
       p.fundcount,
       a.acquired_company,
       a.amountsum
FROM p
LEFT OUTER JOIN a ON p.month=a.month;

---
WITH
     inv_2011 AS (SELECT country_code AS country,
                         AVG(funding_total) AS avg2011
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at AS date))=2011
                  GROUP BY country),
     inv_2012 AS (SELECT country_code AS country,
                         AVG(funding_total) AS avg2012
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at AS date))=2012
                  GROUP BY country),
     inv_2013 AS (SELECT country_code AS country,
                         AVG(funding_total) AS avg2013
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at AS date))=2013
                  GROUP BY country)
SELECT inv_2011.country,
       inv_2011.avg2011,
       inv_2012.avg2012,
       inv_2013.avg2013
FROM inv_2011
INNER JOIN inv_2012 ON inv_2011.country=inv_2012.country
INNER JOIN inv_2013 ON inv_2012.country=inv_2013.country
ORDER BY inv_2011.avg2011 DESC;

