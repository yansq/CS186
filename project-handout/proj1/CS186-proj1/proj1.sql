-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS CAcollege;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthyear
  FROM people
  WHERE weight > 300; 
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthyear
  FROM people
  WHERE nameFirst LIKE '% %'
  ORDER BY nameFirst, nameLast;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height), COUNT(1)
  FROM people
  GROUP BY birthYear
  ORDER BY birthYear;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, avgHeight, count
  FROM (
    SELECT birthYear, AVG(height) as avgHeight, COUNT(1) as count
	  FROM people
	  GROUP BY birthYear) a
  WHERE avgHeight > 70
  ORDER BY birthYear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.nameFirst, p.nameLast, p.playerID, h.yearid
  FROM people p
  INNER JOIN halloffame h
  ON p.playerID = h.playerID
  AND inducted = 'Y'
  ORDER BY h.yearid DESC, p.playerID
;

-- Question 2ii
CREATE VIEW CAcollege(playerid, schoolid)
AS 
  SELECT c.playerid, s.schoolID
  FROM collegeplaying c 
  INNER JOIN schools s
  ON c.schoolID = s.schoolID
  AND s.schoolState = 'CA'
;

CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.nameFirst, p.nameLast, p.playerID, c.schoolid, h.yearid
  FROM people p
  INNER JOIN halloffame h
  ON p.playerID = h.playerID
  AND h.inducted = 'Y'
  INNER JOIN CAcollege c
  ON p.playerID = c.playerid
  ORDER BY h.yearid DESC, c.schoolid, p.playerID
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, c.schoolID
  FROM people p
  INNER JOIN halloffame h
  ON p.playerID = h.playerID
  AND h.inducted = 'Y'
  LEFT JOIN collegeplaying c
  ON p.playerID = c.playerid
  ORDER BY p.playerID DESC, c.schoolID
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID, (SUM(b.H2B) + SUM(b.H3B) * 2 + SUM(b.HR) * 3 + b.H) * 1.0 / SUM(b.AB) slg
  FROM people p
  INNER JOIN batting b
  ON p.playerID = b.playerID
  GROUP BY p.playerID, b.yearID, b.teamID
  HAVING SUM(b.AB) > 50
  ORDER BY slg DESC, b.yearID, p.playerID
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, (SUM(b.sH2B) + SUM(b.sH3B) * 2 + SUM(b.sHR) * 3 + b.sH) * 1.0 / SUM(b.sAB) lslg
  FROM people p
  INNER JOIN (
    SELECT playerID, SUM(H) sH, SUM(H2B) sH2B, SUM(H3B) sH3B, SUM(HR) sHR, SUM(AB) sAB
    FROM batting
    GROUP BY playerID
    HAVING SUM(AB) > 50
  ) b
  ON p.playerID = b.playerID
  GROUP BY p.playerID, p.nameFirst, p.nameLast
  ORDER BY lslg DESC, p.playerID
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT aa.nameFirst, aa.nameLast, aa.lslg
  FROM (
    SELECT p.nameFirst, p.nameLast, (SUM(b.sH2B) + SUM(b.sH3B) * 2 + SUM(b.sHR) * 3 + b.sH) * 1.0 / SUM(b.sAB) lslg
    FROM people p
    INNER JOIN (
      SELECT playerID, SUM(H) sH, SUM(H2B) sH2B, SUM(H3B) sH3B, SUM(HR) sHR, SUM(AB) sAB
      FROM batting
      GROUP BY playerID
      HAVING SUM(AB) > 50
    ) b
    ON p.playerID = b.playerID
    GROUP BY p.playerID, p.nameFirst, p.nameLast
  ) aa
  WHERE aa.lslg > (
    SELECT (SUM(sH2B) + SUM(sH3B) * 2 + SUM(sHR) * 3 + sH) * 1.0 / SUM(sAB) 
    FROM (
      SELECT SUM(H) sH, SUM(H2B) sH2B, SUM(H3B) sH3B, SUM(HR) sHR, SUM(AB) sAB
      FROM batting
      WHERE playerID = 'mayswi01'
    )
  )
  ORDER BY lslg DESC
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID
;

-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT aa.binid, lStart, lEnd, COUNT(1) count
  FROM (
    SELECT binid, (max - min) / 10 * binid + min lStart, (max - min) / 10 * (binid + 1) + min lEnd
    FROM (
      SELECT MIN(salary) min, MAX(salary) max
      FROM salaries
      WHERE yearID = '2016'
    ) a, binids b
  ) aa, salaries ss
  WHERE ss.yearID = '2016'
  AND ss.salary >= lStart
  AND ss.salary < lEND
  GROUP BY aa.binid, lStart, lEnd
  ORDER BY aa.binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH temp as (
    SELECT yearID, MIN(salary) min, MAX(salary) max, AVG(salary) avg
    FROM salaries
    GROUP BY yearID
  )

  SELECT t2.yearID, t2.min - t1.min minsa, t2.max - t1.max maxsa, t2.avg - t1.avg avgsa
  FROM temp t1, temp t2
  WHERE t2.yearID - t1.yearID = 1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s1.playerID, p.nameFirst, p.nameLast, s1.salary ,s1.yearID
  FROM salaries s1
  INNER JOIN (
    SELECT yearID, MAX(salary) max
    FROM salaries
    GROUP BY yearID
  ) s2
  ON s1.yearID = s2.yearID
  AND s1.salary = s2.max
  INNER JOIN people p
  ON s1.playerID = p.playerID
  WHERE s1.yearID IN ('2000', '2001')
  ORDER BY s1.yearID, s1.playerID
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamID, MAX(s.salary) - MIN(s.salary) diffAvg
  FROM allstarfull a
  LEFT JOIN salaries s
  ON a.playerID = s.playerID
  AND s.yearID = a.yearID
  WHERE a.yearID = '2016'
  GROUP BY a.teamID
  ORDER BY a.teamID
;