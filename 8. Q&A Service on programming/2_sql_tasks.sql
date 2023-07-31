---
SELECT COUNT(p.id)
FROM stackoverflow.posts p
JOIN stackoverflow.post_types pt ON p.post_type_id=pt.id
WHERE pt.type='Question'
  AND (p.score > 300 OR p.favorites_count >= 100);

---
WITH abc AS
            (SELECT DATE_TRUNC('day', p.creation_date):: date AS day_cr,
                    COUNT(p.id) AS amount
                    FROM stackoverflow.posts p
                    JOIN stackoverflow.post_types pt ON p.post_type_id=pt.id
                    WHERE DATE_TRUNC('day', p.creation_date) BETWEEN '2008-11-01' AND '2008-11-18'
                      AND pt.type  = 'Question'
                    GROUP BY day_cr)
SELECT ROUND(AVG(amount))
FROM abc;

---
WITH abc AS
            (SELECT COUNT(DISTINCT u.id) AS amount,
                   DATE_TRUNC('day', u.creation_date):: date AS profile_date,
                   DATE_TRUNC('day', b.creation_date):: date AS bedge_date
            FROM stackoverflow.users u
            JOIN stackoverflow.badges b ON u.id=b.user_id
            GROUP BY u.creation_date, bedge_date)
SELECT SUM(amount)
FROM abc
WHERE bedge_date = profile_date;

---
SELECT COUNT(DISTINCT p.id)
FROM stackoverflow.posts p
LEFT JOIN stackoverflow.votes v ON p.id=v.post_id
LEFT JOIN stackoverflow.users u ON p.user_id=u.id
WHERE u.display_name = 'Joel Coehoorn'
  AND v.vote_type_id IS NOT NULL;

---
SELECT *,
       ROW_NUMBER() OVER(ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types v
ORDER BY id;

---
SELECT v.user_id,
       COUNT(v.id) AS voice_count
FROM stackoverflow.votes v
JOIN stackoverflow.vote_types vt ON v.vote_type_id=vt.id
WHERE vt.name = 'Close'
GROUP BY v.user_id
ORDER BY voice_count DESC, v.user_id DESC
LIMIT 10;

---
WITH abc AS
            (SELECT u.id AS id,
                   COUNT(b.id) AS badges_count
            FROM stackoverflow.users u
            JOIN stackoverflow.badges b ON u.id=b.user_id
            WHERE DATE_TRUNC('day', b.creation_date)::date BETWEEN '2008-11-15' AND '2008-12-15'
            GROUP BY u.id
            ORDER BY badges_count DESC
            LIMIT 10)
SELECT id,
       badges_count,
       DENSE_RANK() OVER(ORDER BY badges_count DESC) AS rank
FROM abc;

---
SELECT title,
       user_id,
       score,
       ROUND(AVG(score) OVER(PARTITION BY user_id))
FROM stackoverflow.posts
WHERE title IS NOT NULL
  AND score != 0;

---
WITH abc AS
            (SELECT u.id,
                    COUNT(b.id) AS badges_count
            FROM stackoverflow.users u
            JOIN stackoverflow.badges b ON u.id=b.user_id
            GROUP BY u.id)
SELECT p.title
FROM stackoverflow.posts p
JOIN abc ON p.user_id=abc.id
WHERE abc.badges_count > 1000
  AND p.title IS NOT NULL;

---
SELECT id,
       views,
       CASE
           WHEN views >= 350 THEN 1
           WHEN views < 350 AND views >= 100 THEN 2
           WHEN views < 100 THEN 3
       END
FROM stackoverflow.users
WHERE views != 0
  AND location LIKE '%Canada%';

---
WITH abc AS           
           (SELECT id,
                   views,
                   CASE
                       WHEN views >= 350 THEN 1
                       WHEN views < 350 AND views >= 100 THEN 2
                       WHEN views < 100 THEN 3
                   END AS group_v
            FROM stackoverflow.users
            WHERE views != 0
              AND location LIKE '%Canada%'),
     abd AS
            (SELECT *,
                   MAX(views) OVER(PARTITION BY group_v) AS max_v
            FROM abc)
SELECT id,
       group_v,
       views  
FROM abd
WHERE views = max_v
ORDER BY views DESC, id ASC;

---
WITH abc AS
            (SELECT EXTRACT(DAY FROM creation_date) cr_day,
                   COUNT(DISTINCT id) AS u_amount
            FROM stackoverflow.users
            WHERE DATE_TRUNC('day', creation_date)::date BETWEEN '2008-11-01' AND '2008-11-30'
            GROUP BY cr_day)
SELECT *,
       SUM(u_amount) OVER(ORDER BY cr_day) AS daily_gain
FROM abc;

---
WITH abc AS
            (SELECT DISTINCT(u.id),
                   u.creation_date AS id_creation,
                   MIN(p.creation_date) OVER(PARTITION BY u.id) AS post_creation
            FROM stackoverflow.users u
            JOIN stackoverflow.posts p ON u.id=p.user_id)
SELECT id,
       (post_creation - id_creation) AS diff
FROM abc
GROUP BY id, post_creation, id_creation;

---
SELECT DATE_TRUNC('month', creation_date)::date AS posts_month,
       SUM(views_count) AS monthly_views
FROM stackoverflow.posts
WHERE EXTRACT(YEAR FROM creation_date) = 2008
GROUP BY posts_month
HAVING SUM(views_count) != 0
ORDER BY monthly_views DESC;

---
WITH correct_posts AS
                    (SELECT id,
                           user_id,
                           DATE_TRUNC('day', creation_date)::date AS post_date
                    FROM stackoverflow.posts
                    WHERE post_type_id IN (SELECT id
                                           FROM stackoverflow.post_types
                                           WHERE type='Answer')),
     correct_users AS
                      (SELECT id,
                             display_name,
                             DATE_TRUNC('day', creation_date)::date + INTERVAL '1 month' AS us_creation_plusmonth
                      FROM stackoverflow.users)
SELECT u.display_name,
       COUNT(DISTINCT u.id)
FROM correct_users u
JOIN correct_posts p ON u.id=p.user_id
WHERE p.post_date <= u.us_creation_plusmonth
GROUP BY u.display_name
HAVING COUNT(p.id) > 100
ORDER BY u.display_name;

---
SELECT DATE_TRUNC('month', creation_date)::date AS posts_month,
       COUNT(*)
FROM stackoverflow.posts
WHERE user_id IN (SELECT id
                  FROM stackoverflow.users 
                  WHERE DATE_TRUNC('month', creation_date):: date = '2008-09-01'
                  AND id IN (SELECT user_id
                             FROM stackoverflow.posts
                             WHERE DATE_TRUNC('month', creation_date):: date = '2008-12-01'
                             GROUP BY user_id
                             HAVING COUNT(*) >= 1))
GROUP BY posts_month
ORDER BY posts_month DESC;

---
SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER(PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts
ORDER BY user_id;

---
WITH abc AS
            (SELECT DISTINCT(user_id),
             COUNT(DISTINCT DATE_TRUNC('day', creation_date)::date) AS days_count
            FROM stackoverflow.posts
            WHERE creation_date BETWEEN '2008-12-01' AND '2008-12-07'
            GROUP BY user_id)
SELECT ROUND(AVG(days_count))
FROM abc;

---
WITH abc AS
            (SELECT EXTRACT(MONTH FROM creation_date) AS post_month,
                    COUNT(id) AS post_amount
            FROM stackoverflow.posts
            WHERE creation_date BETWEEN '2008-09-01' AND '2008-12-31'
            GROUP BY post_month
            ORDER BY post_month)
SELECT *,
       ROUND(post_amount::numeric / LAG(post_amount) OVER() - 1, 4)*100 AS dif
FROM abc;

---
WITH count_posts AS                   
                   (SELECT DISTINCT user_id,
                           COUNT(id)    
                    FROM stackoverflow.posts
                    GROUP BY user_id
                    ORDER BY COUNT(id) DESC
                    LIMIT 1),
     user_date AS    
                    (SELECT p.user_id, 
                            p.creation_date,
                            EXTRACT(WEEK FROM p.creation_date) AS week_number
                    FROM stackoverflow.posts p
                    JOIN count_posts cp ON p.user_id=cp.user_id
                    WHERE DATE_TRUNC('month', creation_date) = '2008-10-01')
SELECT DISTINCT week_number,
       MAX(creation_date) OVER(PARTITION BY week_number) AS last_time
FROM user_date;
