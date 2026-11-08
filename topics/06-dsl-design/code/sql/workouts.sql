CREATE TABLE athlete (id INTEGER, name TEXT);
CREATE TABLE workout (athlete_id INTEGER, distance INTEGER, date TEXT);
INSERT INTO athlete VALUES (1, 'Ana'), (2, 'Luis');
INSERT INTO workout VALUES (1, 10, '2026-05-03'), (2, 5, '2026-05-03'), (1, 8, '2026-05-04');
-- <<query>>
SELECT athlete.name, workout.distance
FROM athlete
JOIN workout ON athlete.id = workout.athlete_id
WHERE workout.date = '2026-05-03';
-- <<query.end>>
SELECT CASE WHEN (SELECT COUNT(*) FROM athlete JOIN workout
                  ON athlete.id = workout.athlete_id
                  WHERE workout.date = '2026-05-03') = 2
            AND (SELECT SUM(distance) FROM workout WHERE date = '2026-05-03') = 15
            THEN 'ok' ELSE 'FAIL' END;
