
-- Question 1   : How many olympics games have been held?

SELECT COUNT(DISTINCT Games) as Total_Olympic_Games
    FROM [dbo].[athlete_events_1]

-- Question 2   : List down all Olympics games held so far.

SELECT DISTINCT Year, Season
	FROM athlete_events_1
	ORDER BY YEAR ASC

-- Question 3   : Mention the total no of nations who participated in each olympics game?
		-- The reason of using CTE is that it looks like the Summer games in 1956 have occurred in Stockholm and Melbourne

-- Shows the total number of nations in each game		
WITH CityNations AS (
    SELECT
        Year,
        Season,
        City,
        COUNT(DISTINCT NOC) AS Total_Nations
    FROM
        athlete_events_1
    GROUP BY
        Year, Season, City
) -- Groups the cities and add the number of nations for grouped cities
SELECT
    Year,
    Season,
    STRING_AGG(City, ', ') AS Cities,
    SUM(Total_Nations) AS Total_Nations
FROM
    CityNations
GROUP BY
    Year, Season
ORDER BY
    Year;

-- Question 4   : Which year saw the highest and lowest no of countries participating in olympics?

WITH CountryCounts AS (
    SELECT
        e.Year,
        COUNT(DISTINCT e.NOC) AS CountryCount
    FROM
        athlete_events_1 AS e
    GROUP BY
        e.Year
)
SELECT
    'Highest' AS Participation,
    c.Year,
    c.CountryCount
FROM
    CountryCounts c
WHERE
    c.CountryCount = (SELECT MAX(CountryCount) FROM CountryCounts)
UNION ALL
SELECT
    'Lowest' AS Participation,
    c.Year,
    c.CountryCount
FROM
    CountryCounts c
WHERE
    c.CountryCount = (SELECT MIN(CountryCount) FROM CountryCounts);

-- Question 5   : Which nation has participated in all of the olympic games?

WITH TotGames AS (
    SELECT
        r.region,
        COUNT(DISTINCT a.Games) AS Total_Games
    FROM
        athlete_events_1 AS a
    INNER JOIN
        national_olympic_commitiee_regions_1 AS r ON a.noc = r.noc
    GROUP BY
        r.region
)
SELECT
    region,
    Total_Games
FROM
    TotGames
WHERE
    Total_Games = (SELECT COUNT(DISTINCT Games) FROM athlete_events_1);


-- Question 6   : Identify the sport which was played in all summer olympics.

WITH summer_olympics AS (
    SELECT
        DISTINCT a.sport,
        COUNT(DISTINCT a.Games) AS Total_Games
    FROM
        athlete_events_1 AS a
    INNER JOIN
        national_olympic_commitiee_regions_1 AS r ON a.noc = r.noc
    WHERE
        a.season = 'Summer' -- filter for summer games
    GROUP BY
        a.sport
)
SELECT
    sport,
    Total_Games
FROM
    summer_olympics
WHERE
    Total_Games = (SELECT COUNT(DISTINCT Games) FROM athlete_events_1 WHERE season = 'Summer');

-- Question 7   : Which Sports were just played only once in the olympics?

WITH t1 AS (
    SELECT DISTINCT games, sport
    FROM athlete_events_1
),

t2 AS (
    SELECT sport, COUNT(DISTINCT a.Games) AS Total_Games
    FROM athlete_events_1 a
    GROUP BY sport
)

SELECT t1.*, t2.Total_Games
FROM t1
INNER JOIN t2 ON t1.sport = t2.sport
WHERE Total_Games = 1
ORDER BY t1.games;

-- Question 8   : Fetch the total no of sports played in each olympic games.

SELECT
    games,
    COUNT(DISTINCT sport) AS Num_sports
FROM
    athlete_events_1
GROUP BY
    games
ORDER BY
    Num_sports;

-- Question 9   : Fetch details of the oldest athletes to win a gold medal.

SELECT
    name,
    sex,
    CASE
        WHEN ISNUMERIC(Age) = 1 THEN MAX(CAST(Age AS INT))
        ELSE NULL -- or a default value for non-numeric entries
    END AS Age,
    height,
    weight,
    team,
    Games,
    Year,
    Season,
    City,
    region,
    Sport,
    Event,
    Medal
FROM
    athlete_events_1 a
INNER JOIN
    national_olympic_commitiee_regions_1 b ON a.noc = b.noc
WHERE
    Medal = 'Gold'
    AND ISNUMERIC(Age) = 1 -- Only include rows where Age can be converted to an integer
GROUP BY
    name,
    sex,
    height,
    weight,
    team,
    Games,
    Year,
    Season,
    City,
    region,
    Sport,
    Event,
    Medal,
    age
HAVING -- maximum age with gold medal where age is numeric
    CASE
        WHEN ISNUMERIC(Age) = 1 THEN MAX(CAST(Age AS INT))
        ELSE NULL
    END = (SELECT MAX(CAST(Age AS INT)) FROM athlete_events_1 WHERE Medal = 'Gold' AND ISNUMERIC(Age) = 1)
ORDER BY
    Age DESC;

-- Question 10  : Find the Ratio of male and female athletes participated in all olympic games.

WITH t1 AS (
    SELECT 'Males' AS Gender, COUNT(sex) AS Number FROM athlete_events_1 WHERE sex = 'M'
    UNION ALL
    SELECT 'Females' AS Gender, COUNT(sex) AS Number FROM athlete_events_1 WHERE sex = 'F'
),
MaxNumber AS (
    SELECT MAX(Number) AS MaxValue FROM t1
)
SELECT
    t1.Gender,
    t1.Number,
    CASE
        WHEN t1.Number = MaxNumber.MaxValue THEN 1
        ELSE CAST(ROUND(CAST(MaxNumber.MaxValue AS DECIMAL) / t1.Number, 2) AS DECIMAL(10, 2))
    END AS Ratio
FROM
    t1,
    MaxNumber;

-- Question 11  : Fetch the top 5 athletes who have won the most gold medals.

SELECT TOP 5
    Name,
    Team,
    COUNT(Medal) AS Nr_Gold_Medals
FROM
    athlete_events_1
WHERE
    Medal = 'Gold'
GROUP BY
    Name,
    Team
ORDER BY
    Nr_Gold_Medals DESC;

------OR----------- Using Windows Function---------------

WITH GoldMedalCounts AS (
    SELECT
        Name,
        Team,
        COUNT(medal) AS Nr_Gold_Medals,
        DENSE_RANK() OVER (ORDER BY COUNT(medal) DESC) AS rnk
    FROM
        athlete_events_1
    WHERE
        Medal = 'Gold'
    GROUP BY
        Name,
        Team
)
SELECT
    Name,
    Team,
    Nr_Gold_Medals
FROM
    GoldMedalCounts
WHERE
    rnk <= 5;


-- Question 12  : Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH MedalCounts AS (
    SELECT
        name,
        Team,
        COUNT(medal) AS Nr_Medals,
        DENSE_RANK() OVER (ORDER BY COUNT(medal) DESC) AS rnk
    FROM
        athlete_events_1
    WHERE
        medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY
        name, team
)
SELECT
    name,
    Team,
    Nr_Medals
FROM
    MedalCounts
WHERE
    rnk <= 5;

-- Question 13  : Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH MedalCounts AS (
    SELECT
        n.region,
        COUNT(a.medal) AS Nr_Medals,
        DENSE_RANK() OVER (ORDER BY COUNT(a.medal) DESC) AS rnk
    FROM
        athlete_events_1 a
    INNER JOIN
        national_olympic_commitiee_regions_1 n ON a.NOC = n.NOC
    WHERE
        a.medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY
        n.region
)
SELECT
    region,
    Nr_Medals
FROM
    MedalCounts
WHERE
    rnk <= 5;

-- Question 14  : List down total gold, silver and broze medals won by each country.

SELECT
    n.region AS Country,
    SUM(CASE WHEN a.medal = 'Gold' THEN 1 ELSE 0 END) AS Total_Gold,
    SUM(CASE WHEN a.medal = 'Silver' THEN 1 ELSE 0 END) AS Total_Silver,
    SUM(CASE WHEN a.medal = 'Bronze' THEN 1 ELSE 0 END) AS Total_Bronze,
    SUM(CASE WHEN a.medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS Total_Medals
FROM
    athlete_events_1 a
INNER JOIN
    national_olympic_commitiee_regions_1 n ON a.NOC = n.NOC
WHERE
    a.medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY
    n.region
ORDER BY
    Total_Medals DESC, Total_Gold DESC, Total_Silver DESC, Total_Bronze DESC;

-- Question 15  : List down total gold, silver and broze medals won by each country corresponding to each olympic games.

SELECT
    n.region AS Country,
    a.Games,
    SUM(CASE WHEN a.medal = 'Gold' THEN 1 ELSE 0 END) AS Total_Gold,
    SUM(CASE WHEN a.medal = 'Silver' THEN 1 ELSE 0 END) AS Total_Silver,
    SUM(CASE WHEN a.medal = 'Bronze' THEN 1 ELSE 0 END) AS Total_Bronze,
    SUM(CASE WHEN a.medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS Total_Medals
FROM
    athlete_events_1 a
INNER JOIN
    national_olympic_commitiee_regions_1 n ON a.NOC = n.NOC
WHERE
    Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY
    n.region, a.Games
ORDER BY
    a.Games;

-- Question 16  : Identify which country won the most gold, most silver and most bronze medals in each olympic games.

WITH MedalCounts AS (
    SELECT
        n.region AS Country,
        a.Games,
        SUM(CASE WHEN a.medal = 'Gold' THEN 1 ELSE 0 END) AS Total_Gold,
        SUM(CASE WHEN a.medal = 'Silver' THEN 1 ELSE 0 END) AS Total_Silver,
        SUM(CASE WHEN a.medal = 'Bronze' THEN 1 ELSE 0 END) AS Total_Bronze,
        ROW_NUMBER() OVER (PARTITION BY a.Games ORDER BY SUM(CASE WHEN a.medal = 'Gold' THEN 1 ELSE 0 END) DESC) AS Gold_Rank,
        ROW_NUMBER() OVER (PARTITION BY a.Games ORDER BY SUM(CASE WHEN a.medal = 'Silver' THEN 1 ELSE 0 END) DESC) AS Silver_Rank,
        ROW_NUMBER() OVER (PARTITION BY a.Games ORDER BY SUM(CASE WHEN a.medal = 'Bronze' THEN 1 ELSE 0 END) DESC) AS Bronze_Rank
    FROM
        athlete_events_1 a
    INNER JOIN
        national_olympic_commitiee_regions_1 n ON a.NOC = n.NOC
    WHERE
        a.medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY
        n.region, a.Games
)
SELECT
    Games,
    MAX(CASE WHEN Gold_Rank = 1 THEN Country END) AS Most_Gold_Country,
    MAX(CASE WHEN Gold_Rank = 1 THEN Total_Gold END) AS Most_Gold,
    MAX(CASE WHEN Silver_Rank = 1 THEN Country END) AS Most_Silver_Country,
    MAX(CASE WHEN Silver_Rank = 1 THEN Total_Silver END) AS Most_Silver,
    MAX(CASE WHEN Bronze_Rank = 1 THEN Country END) AS Most_Bronze_Country,
    MAX(CASE WHEN Bronze_Rank = 1 THEN Total_Bronze END) AS Most_Bronze
FROM
    MedalCounts
GROUP BY
    Games
ORDER BY
    Games;

-- Question 17  : Which countries have never won gold medal but have won silver/bronze medals?

WITH MedalCounts AS (
    SELECT
        n.NOC,
		n.region AS Country,
        SUM(CASE WHEN a.medal = 'Gold' THEN 1 ELSE 0 END) AS Gold_Count,
        SUM(CASE WHEN a.medal = 'Silver' THEN 1 ELSE 0 END) AS Silver_Count,
        SUM(CASE WHEN a.medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze_Count
    FROM
        athlete_events_1 a
    INNER JOIN
        national_olympic_commitiee_regions_1 n ON a.NOC = n.NOC
    GROUP BY
        n.NOC, n.region
)
SELECT
    mc.Country,
    mc.Gold_Count AS Gold_Medals,
    mc.Silver_Count AS Silver_Medals,
    mc.Bronze_Count AS Bronze_Medals
FROM
    MedalCounts mc
WHERE
    mc.Gold_Count = 0
    AND (mc.Silver_Count > 0 OR mc.Bronze_Count > 0);

-- Question 18  : In which Sport/event, USA has won highest medals.
select top 5 * from athlete_events_1

WITH MedalCounts AS (
    SELECT
        Sport,
        Event,
        SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS Total_Medals
    FROM
        athlete_events_1
    WHERE
        NOC = 'USA'
    GROUP BY
        Sport, Event
)
SELECT TOP 1
    Sport,
    Event,
    Total_Medals
FROM
    MedalCounts
ORDER BY
    Total_Medals DESC;

-- Question 19  : Break down all olympic games where USA won medal for Swimming and how many medals in each olympic games.

SELECT 
    Games,
    Event,
    SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Total_Gold,
    SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Total_Silver,
    SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS Total_Bronze,
    SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS Total_medals
FROM
    athlete_events_1 a
INNER JOIN
    national_olympic_commitiee_regions_1 n ON a.NOC = n.NOC
WHERE
    Sport = 'Swimming'
GROUP BY
    Games, Event
ORDER BY
    Games DESC, Total_medals DESC;
