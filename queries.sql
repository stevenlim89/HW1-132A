/*
 * Name: Steven Lim
 * PID: A10565388
 */

.mode columns
.headers on

/*
 * Part A
 */
 /*
CREATE TABLE sailor(sname text PRIMARY KEY, rating integer);
CREATE TABLE boat(bname text PRIMARY KEY, color text, rating integer);
CREATE TABLE reservation(sname text NOT NULL REFERENCES sailor(sname), bname text NOT NULL REFERENCES boat(bname), day text, start integer, finish integer CHECK (finish > start), PRIMARY KEY(bname, day, start, finish));

INSERT INTO sailor(sname, rating) VALUES("Brutus", 1);
INSERT INTO sailor(sname, rating) VALUES("Andy", 8);
INSERT INTO sailor(sname, rating) VALUES("Horatio", 7);
INSERT INTO sailor(sname, rating) VALUES("Rusty", 8);
INSERT INTO sailor(sname, rating) VALUES("Bob", 1);

INSERT INTO boat(bname, color, rating) VALUES("SpeedQueen", "white", 9);
INSERT INTO boat(bname, color, rating) VALUES("Interlake", "red", 8);
INSERT INTO boat(bname, color, rating) VALUES("Marine", "blue", 7);
INSERT INTO boat(bname, color, rating) VALUES("Bay", "red", 3);

INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Andy", "Interlake", "Monday", 10, 14);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Andy", "Marine", "Saturday", 14, 16);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Andy", "Bay", "Wednesday", 8, 12);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Rusty", "Bay", "Sunday", 9, 12);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Rusty", "Interlake", "Wednesday", 13, 20);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Rusty", "Interlake", "Monday", 9, 11);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Bob", "Bay", "Monday", 9, 12);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Andy", "Bay", "Wednesday", 9, 10);
INSERT INTO reservation(sname, bname, day, start, finish) VALUES("Horatio", "Marine", "Tuesday", 15, 19);
*/

/* 
 * Part B
 */
SELECT * FROM sailor;
SELECT * FROM boat;
SELECT * FROM reservation;

/* 
 * Part C
 */

/* Number 1 */
SELECT s.sname, b.bname FROM sailor s, boat b WHERE s.rating >= b.rating; 

/* Number 2 */
SELECT s.sname, COUNT(s.rating) AS 'number' FROM sailor s, boat WHERE s.rating >= boat.rating GROUP BY s.sname
	UNION SELECT st.sname, 0 AS 'number' FROM sailor st WHERE st.sname NOT IN 
	(SELECT s.sname FROM sailor s, boat WHERE s.rating >= boat.rating)
ORDER BY COUNT(s.rating) DESC;

/* Number 3 */
SELECT s.sname FROM sailor s WHERE s.rating = (SELECT MIN(rating) FROM sailor) ORDER BY s.sname;

/* Without MIN */
SELECT DISTINCT s.sname FROM sailor s LEFT JOIN sailor st ON st.rating < s.rating WHERE st.rating IS NULL;

/* Number 4 */
SELECT s.sname FROM sailor s, reservation r, boat b WHERE s.sname <> 
	(SELECT st.sname FROM sailor st, boat bt, reservation rt WHERE bt.color = "white" OR bt.color = "blue" AND st.sname = rt.sname) AND s.sname = r.sname AND r.bname = b.bname AND b.color = "red" 
GROUP BY s.sname HAVING COUNT(r.sname) >= 1 ORDER BY s.sname DESC;

/* Number 5 */
SELECT s.sname FROM sailor s, boat b WHERE s.sname NOT IN (
	SELECT st.sname FROM sailor st, boat bt, reservation rt WHERE bt.color = "red" AND st.sname = rt.sname AND rt.bname = bt.bname) 
GROUP BY s.sname;

/* Number 6 Using NOT IN*/
SELECT r.sname FROM reservation r WHERE r.sname NOT IN(
	SELECT rt.sname FROM reservation rt, boat bt WHERE bt.color = "red" AND
	rt.sname NOT IN (SELECT rb.sname FROM reservation rb WHERE bt.bname = rb.bname))
GROUP BY r.sname;	

/* Number 6 Using NOT EXISTS*/
SELECT r.sname FROM reservation r WHERE NOT EXISTS(
	SELECT rt.sname FROM reservation rt, boat bt WHERE bt.color = "red" AND
	NOT EXISTS (SELECT rb.sname FROM reservation rb WHERE bt.bname = rb.bname AND rb.sname = r.sname))
GROUP BY r.sname;

/* Number 6 Using COUNT*/
SELECT s.sname FROM sailor s, boat b, reservation r WHERE s.sname = r.sname AND b.bname = r.bname AND 
	(SELECT COUNT(*) FROM boat bt, reservation rt WHERE s.sname = rt.sname AND bt.bname = rt.bname AND bt.color = "red") > 1 
GROUP BY s.sname;

/* Number 7 */
CREATE VIEW uniqueView AS SELECT DISTINCT sailor.sname, sailor.rating, reservation.bname FROM sailor, reservation WHERE sailor.sname = reservation.sname;
SELECT bname, AVG(rating * 1.0) AS average FROM uniqueView GROUP BY bname ORDER BY AVG(rating * 1.0) DESC;

/* 
 * Part D
 */
 SELECT r.bname, r.day, r.sname AS sname1, r.start AS start1, r.finish AS finish1, rt.sname AS sname2, rt.start AS start2, rt.finish AS finish2
 	FROM reservation r, reservation rt
 	WHERE r.bname = rt.bname AND r.day = rt.day AND ((r.start = rt.start AND r.finish = rt.finish AND r.sname < rt.sname)
	OR (r.start = rt.start AND rt.finish < r.finish) 
 	OR (r.start < rt.start AND rt.start < r.finish))
 ORDER BY r.bname DESC;

/*
 * Part E
 */
 /* Changing boats from red to blue or vice versa */
 UPDATE boat SET color = CASE color WHEN 'blue' THEN 'red' WHEN 'red' THEN 'blue' END WHERE color IN ('red', 'blue');
 
 /* Deleting from the database sailors who cannot reserve any boats */
 DELETE FROM reservation WHERE EXISTS (SELECT s.sname FROM sailor s, boat b, reservation rt WHERE s.sname = reservation.sname AND b.bname = reservation.bname AND s.rating < b.rating);
 DELETE FROM sailor WHERE EXISTS (SELECT COUNT(st.sname) FROM sailor st, boat b WHERE sailor.rating >= b.rating AND sailor.sname <> st.sname GROUP BY st.sname) = 0;
 
 /*
  * Part F
  */
SELECT * FROM sailor;
SELECT * FROM boat;
SELECT * FROM reservation;