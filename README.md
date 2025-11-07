# Netflix Movies and TV shows Data Analysis using SQL
![Netflix Logo](https://github.com/BavyaNalajala01/Netflix_SQL_Project/blob/main/NETFLIX_LOGO.jpg)
## 📊 Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.
## 🎯Objectives
- Analyze the distribution of content types (Movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.
## 📁 Dataset
The data set used for this project is sourced from Kaggle
- Data Link : [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)
## 🧩Schema

 ```sql
DROP TABLE IF EXISTS netflix;
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
```

## 💻Data Analysis

### 1. Number of Movies vs TV Shows

```sql
SELECT 
    type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;
```
### 2. Most Common Ratings: Movies vs TV Shows

```sql
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
```
### 3. Movies Released in 2020

```sql
SELECT * 
FROM netflix
WHERE 
  type = 'Movie'
  AND 
  release_year = 2020
```
### 4. Top 5 Countries with the Most Netflix Content

```sql
SELECT 
   UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, --UNNEST to break a list of items into separate rows to easily work with each item on its own.
   COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```
### 5. Movie with the Longest Duration on Netflix

```sql
SELECT * 
FROM netflix
WHERE 
   type = 'Movie'
   AND 
   duration = (SELECT MAX(duration) FROM netflix)
```

### 6. Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE 
  TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
```
### 7. Movies and TV Shows Directed by Rajiv Chilaka

```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'
```
### 8. All TV Shows Having Over 5 Seasons

```sql
SELECT *
FROM netflix
WHERE 
   type = 'TV Show'
   AND 
   SPLIT_PART(duration,' ', 1)::numeric > 5 
```
### 9. Content Count by Genre

```sql
SELECT
   UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
   COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
```
### 10. Top 5 Years with Highest Average Content Releases by India on Netflix

```sql
SELECT 
   EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
   COUNT(*) as yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 ,2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
```
### 11. List of Movies Categorized as 'Documentaries'

```sql
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%'
```
### 12. Content Without a Listed Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL
```
### 13. Movies Featuring Paris Hilton in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Paris Hilton%' --ILIKE to search text in a case-insensitive way, so it doesn’t matter if the letters are uppercase or lowercase.
      AND
	  release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
```
### 14. Top 10 Actors with the Most Movie Appearances in the USA

```sql
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%United States%'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10
```
### 15. Content is labeled 'Bad' if the description contains 'kill' or 'violence', and 'Good' otherwise, with a count of items in each category

```sql
WITH new_table  --Creating a new temporary table
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
```

## 💡 Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
