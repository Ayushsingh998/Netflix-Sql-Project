CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

select * from netflix

select count(*) from netflix

select distinct type from netflix

-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

-- 1. Count the number of Movies vs TV Shows

select 
type,count(type)
from netflix
group by type

-- 2. Find the most common rating for movies and TV shows

with data as(
select
type,rating,count(*) as count_rating
from netflix
group by 1,2
order by 1,3 desc
)

select * from data
where (type,count_rating) in (
select type , max(count_rating)
from data
group by type)

-- or

with data as(
select
type,rating,count(*) as count_rating,
dense_rank()over(partition by type order by count(*) desc) as rnk
from netflix
group by 1,2
order by 1,3 desc
)
select type,rating from data
where rnk = 1

 -- 3. List all movies released in a specific year (e.g., 2020)

select 
type , title 
from netflix
where release_year = '2020' and type = 'Movie'

-- 4. Find the top 5 countries with the most content on Netflix

select 
trim(unnest(string_to_array(country , ','))) as new_country,
count(show_id) as count_country
from netflix
group by new_country
order by count_country desc
limit 5


-- 5. Identify the longest movie

select  
title ,
cast(replace(duration,'min','') as integer) as duration_time
from netflix
where type = 'Movie' and duration is not null 
order by duration_time desc
limit 1

-- 6. Find content added in the last 5 years

Select *
from netflix
where TO_DATE(date_added,'month DD, YYYY') >= current_date - interval '5 years'


select current_date - interval '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from (
select 
*,
trim(unnest(string_to_array(director , ','))) as new_director
from netflix)as x
where x.new_director = 'Rajiv Chilaka'

-- or ----

select * 
from netflix
where director like '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons

with tv_data as(
select * ,
cast(replace(duration,'Seasons','') as integer) as seasons
from(
select * from netflix
where duration like '%Seasons%') ) 

select type , title , duration 
from tv_data 
where seasons > 5

-- 9. Count the number of content items in each genre

select 
unnest(string_to_array(listed_in,',')) as genre,
count(*) as count_of_content
from netflix
group by 1;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select 
country,
release_year,
count(*) as total_content,
round(count(show_id)::numeric/(select count(show_id) from netflix where country = 'India')::numeric * 100,2) as avg_value
from netflix
where country ='India'
group by 1,2
order by 4 desc
limit 5

-- 11. List all movies that are documentaries

select *
from netflix
where listed_in like '%Documentaries%' and type = 'Movie'

-- 12. Find all content without a director

select *
from netflix 
where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where casts like '%Salman Khan%' 
and release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
and type = 'Movie'

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
unnest(string_to_array(casts,',')) as cast_member,
count(*) as count_of_movie
from netflix
group by 1
order by 2 desc
limit 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

select x.label_content , type , count(*) from (
select * , 
case when description like '%kill%' or description like '%violence%' then 'Bad' else 'Good' end as Label_content
from netflix ) as x
group by 1,2
order by 3;

