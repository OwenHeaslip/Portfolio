-- List the top ten most visited players and how many times they have visited.
SELECT P.Name AS PlayerName, COUNT(V.VID) AS VisitCount 
FROM Visits V, Player P 
WHERE V.PID = P.PID 
GROUP BY P.Name 
ORDER BY VisitCount DESC 
LIMIT 10;

-- List the three most used equipment, how many times it has been used, and its description.
SELECT E.Name AS EquipmentName, COUNT(V.VID) AS UsageCount, E.Description 
FROM Visits V, Equipment E 
WHERE V.EID = E.EID 
GROUP BY E.Name, E.Description 
ORDER BY UsageCount DESC 
LIMIT 3;

-- List the three least used equipment, how many times it has been used, and its description.
SELECT E.Name AS EquipmentName, COUNT(V.VID) AS UsageCount, E.Description 
FROM Visits V, Equipment E 
WHERE V.EID = E.EID 
GROUP BY E.Name, E.Description 
ORDER BY UsageCount ASC 
LIMIT 3;

-- Find the average amount of visits per day for every month.
SELECT Year, Month, (COUNT(VID) / COUNT(DISTINCT Day)) AS AvgVisitsPerDay 
FROM Visits 
GROUP BY Year, Month;

-- For every month, display each team and how many times they visited.
SELECT V.Year, V.Month, P.Sport AS Team, COUNT(V.VID) AS VisitCount 
FROM Visits V, Player P 
WHERE V.PID = P.PID 
GROUP BY V.Year, V.Month, P.Sport 
ORDER BY V.Year, V.Month, VisitCount DESC;

-- Select each day where Float Tank, Compression Pants, and Massage Chair were used in the same day.
SELECT Year, Month, Day 
FROM Visits V, Equipment E 
WHERE V.EID = E.EID AND ( E.Name = "Float Tank" OR E.Name = "Compression Boots" OR E.Name = "Massage Chair" )
GROUP BY Year, Month, Day 
HAVING COUNT(DISTINCT E.Name) = 3;

-- Find the workers who have signed in on the most visits.
SELECT W.Name AS WorkerName, COUNT(V.VID) AS TotalVisits 
FROM Visits V, Worker W
WHERE V.WID = W.WID 
GROUP BY W.Name 
ORDER BY TotalVisits DESC;

-- Show the number of workers in each grade and order by grade.
SELECT Grade, Count(WID) as WorkerCount
FROM Worker 
GROUP BY Grade
ORDER BY Grade DESC;

-- Select the teams that have the most workers. 
SELECT Sport AS Team, COUNT(WID) AS WorkerCount 
FROM Worker 
GROUP BY Sport 
ORDER BY WorkerCount DESC;

-- Find the total amount of male and female visits. 
SELECT P.Gender, COUNT(V.VID) AS TotalVisits
FROM Player P, Visits V
WHERE V.PID = P.PID
GROUP BY P.Gender;

-- List each location and the total quantity of equipment in each room.
SELECT Location, SUM(Quantity) AS TotalQuantity 
FROM Equipment
GROUP BY Location
ORDER BY TotalQuantity DESC;

-- What is the average amount of equipment per room?
SELECT AVG(Quantity) AS AverageQuantity
FROM Equipment;

-- Who is the oldest worker according to their grade? 
SELECT Name, Grade
FROM Worker
WHERE Grade = (SELECT MIN(Grade) 
		FROM Worker);

-- Who is the youngest worker according to their grade? 
SELECT Name, Grade
FROM Worker
WHERE Grade = (SELECT MAX(Grade) 
		FROM Worker);

 -- Who was the first person to use the Lab this year?
SELECT P.Name, V.Month, V.Day
FROM Visits V, Player P
WHERE V.PID = P.PID AND V.VID = (SELECT MIN(VID)
				FROM Visits);

-- Find the days worked by workers who play no sport. 
SELECT DISTINCT Year, Month, Day 
FROM Visits V 
WHERE V.WID IN (SELECT WID
		 FROM Worker 
		 WHERE Sport = 'NO SPORT' ) 
ORDER BY Year, Month, Day;


