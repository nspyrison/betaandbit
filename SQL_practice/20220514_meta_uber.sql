-- https://www.youtube.com/watch?v=3raOQS1hbcc
--
-- User:
-- date_signup  datetime
-- user_id      int
-- name         char
--
-- Activity:
-- datetime     datetime
-- user_id      int
-- event        categorical char
-- time_spent   int
-- 
-- Q: for each user who signed up after 2020-01-01 what is the prop of time spent per event type?
--
-- Assume: no duplications/missing. Return name, user_id, event, prop.




-- first take:
-- good first go, when you start asking about over partition by, may as well make a new CTE.
WITH activity_agg AS (
    SELECT
      user_id,
      event,
      SUM(time_spent) AS time_spent
    FROM activity
    GROUP BY user_id, event
)

SELECT
  b.name,
  a.user_id,
  a.event,
  a.time_spent / SUM(time_spent) as prop, -- Over partition by?
  a.time_spent
  OVER(SUM(a.time_spent) partition BY user_id) -- 
FROM activity_agg a
  LEFT JOIN user b ON a.user_id = b.user_id
WHERE b.date_signup >= "2020-01-01"
GROUP BY
  b.name,
  a.user_id,
  a.event


-- Their solution:
with TimePerUserEvent AS (
    SELECT u.user_id, name, event, SUM(time_spent) AS time_per_userevent
    FROM (SELECT * FROM User WHERE date_signup >= '2020-01-01') U
    LEFT JOIN activity USING user_id
    GROUP BY 1, 2, 3
),
TimerPerUser AS (
    SELECT user_id, SUM(time_per_userevent) as time_per_userevent
    FROM TimePerUserEvent
    GROUP BY 1
)
SELECT TE.user_id, name, event, timer_per_userevent / time_per_user AS proportion
FROM TimePerUser TU JOIN TimePerUserEvent TE USING user_id;

-----------------------------------------------------------------------------

-- RideStatus:
-- order_date       datetime
-- user_id          int
-- ride_id          int
-- status_of_order  categorical
-- price            double
-- service_name     categorical
--
-- UserProfile:
-- joined_date      datetime
-- user_id          int
-- market_id        int
-- uber_one         bool
--
-- Q: Among *uber_one* users, who are the top three riders in terms of *successful* ride count per market?
--
-- A: Assume no duplications/missing. Return market_id, user_id, ride_count, rank.

-- first take:
WITH Ride_Counts AS
(
    SELECT RS.rider_id, UP.market_id, COUNT(1) AS ride_count,
    FROM RideStatus RS
    JOIN UserProfile UP USING user_id
    WHERE RS.status_of_order = 'Success', UP.uber_one = 1
    GROUP BY 1, 2
)
SELECT 
  market_id, user_id, ride_count, RANK(ride_count) AS rank
FROM Ride_Counts


-- Their answer:
WITH RideCountPerUserMarket(
    SELECT U.user_id, market_id
    FROM (SELECT user_id FROM RideStatus WHERE status_of_order = 'Success') R
    JOIN (SELECT user_id, market_id FROM UserProfile WHERE uber_one = 1) U
    USING (user_id)
    GROUP BY 1, 2
),
RankPerMarket AS(
    SELECT user_id, market_id, ride_count, RANK() OVER(PARTITION BY market_id ORDER BY ride_count DESC) AS RankPerMarket
    FROM RideCountPerUserMarket
)
SELECT user_id, market_id, ride_count, rank 
FROM RankPerMarket
WHERE rank < 4;
----------------------------------------------------------------------------


---- Take Aways:
-- 1) use ' instead of "".
-- 2) When in doubt add a CTE; WITH name AS (<query>)
-- 3) use windowed queries for WHERE logic (?)