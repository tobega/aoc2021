CREATE TEMP TABLE part (part CHAR(5) NOT NULL);
-- COPY is server-process-perspective, \copy is client-process-perspective, same command
\copy part FROM PROGRAM 'echo ${part:-part1}';

CREATE TEMP TABLE input (linenum SMALLSERIAL, "value" INTEGER NOT NULL);
\copy input ("value") FROM 'input.txt';

\copy (SELECT 'SQL') TO STDOUT;

CREATE TEMP TABLE solutions (
  part CHAR(5) NOT NULL,
  result INTEGER
);

with steps as (
  select case
    when prev."value" < n."value" then 1
    else 0
  end inc
  from input prev join input n on prev.linenum + 1 = n.linenum
)
INSERT INTO solutions (part, result)
SELECT 'part1', SUM(inc) FROM steps;

WITH triples AS (
  select linenum, sum("value") over (order by linenum asc rows between current row and 2 following) t
  from input
), steps as (
  select case
    when prev.t < n.t then 1
    else 0
  end inc
  from triples prev join triples n on prev.linenum + 1 = n.linenum
)
INSERT INTO solutions (part, result)
SELECT 'part2', SUM(inc) FROM steps;

SELECT result
FROM solutions
JOIN part ON part.part = solutions.part;
