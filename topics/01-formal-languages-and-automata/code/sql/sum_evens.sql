CREATE TABLE numbers (value INTEGER);
INSERT INTO numbers VALUES (1), (2), (3), (4);
-- <<sumevens>>
SELECT SUM(value) FROM numbers WHERE value % 2 = 0;
-- <<sumevens.end>>
SELECT CASE WHEN (SELECT SUM(value) FROM numbers WHERE value % 2 = 0) = 6
            THEN 'ok' ELSE 'FAIL' END;
