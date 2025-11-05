--Netflix Project

CREATE TABLE netflix
(
     show_id VARCHAR(6),
     type	VARCHAR(10),
     title	VARCHAR(150),
     director VARCHAR(208),
     casts	VARCHAR(1000),
     country VARCHAR(150),
     date_added	VARCHAR(50),
     release_year	INT,
     rating	VARCHAR(10),
     duration	VARCHAR(15),
     listed_in	VARCHAR(100),
     description VARCHAR(250)
);

SELECT * FROM netflix;

--No.of movies vs TV shows

SELECT 
    type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type

--Most common rating for movies and TV shows

SELECT 
     type,
	 rating
FROM 
 (SELECT 
    type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2) as t1
WHERE ranking = 1

--All movies released in a specific year 2020

SELECT * 
FROM netflix
WHERE 
  type = 'Movie'
  AND 
  release_year = 2020

--Top 5 countries with the most content on Netflix

SELECT 
   UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
   COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Longest Movie on Netflix

SELECT * 
FROM netflix
WHERE 
   type = 'Movie'
   AND 
   duration = (SELECT MAX(duration) FROM netflix)

--Content added in the last 5 years

SELECT *
FROM netflix
WHERE 
  TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--All the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

--All TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
   type = 'TV Show'
   AND 
   SPLIT_PART(duration,' ', 1)::numeric > 5 

--The no.of content items in each genre

SELECT
   UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
   COUNT(show_id) as total_content
FROM netflix
GROUP BY 1 

--Each year and the average no.of content release by India on Netflix.
-- Returning the top 5 years with the highest avg content release!

SELECT 
   EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
   COUNT(*) as yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 ,2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

--All movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%'

--All the content without a director

SELECT * 
FROM netflix
WHERE director IS NULL

--Movies that the actor 'Paris Hilton' appeared in the last 10 years!

SELECT *
FROM netflix
WHERE casts ILIKE '%Paris Hilton%'
      AND
	  release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--Top 10 actors who have appeared in the highest no.of movies produced in the USA

SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%United States%'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10

--Categorizing the content based on the presence of the keywords 'kill' and 'violence' in
--the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. 
--How many items fall into each category?

WITH new_table 
AS
(
SELECT *,
   CASE 
   WHEN description ILIKE '%kill%' OR
        description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good Content'
	END category
FROM netflix
)
SELECT category,
     COUNT(*) as total_content
FROM new_table
GROUP BY 1