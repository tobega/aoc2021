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

WITH RECURSIVE nums AS (
  SELECT 2 as num
  UNION 
  select num + 1 as num
  from nums
  where num < (select max("value") from input)
), mods AS (
  select i."value", mod(i."value", n.num) as rem
  from input i join nums n on n.num < i."value"
)
SELECT distinct "value"
into temp table composites
from mods
where rem = 0;

INSERT INTO solutions (part, result)
SELECT 'part1', SUM((linenum-1) * "value")
FROM input i natural left join composites c
where c."value" is null;

INSERT INTO solutions (part, result)
SELECT 'part2', SUM(case
  when mod(linenum,2) = 1 then "value"
  else -"value"
end)
FROM input i natural join composites c;

SELECT result
FROM solutions
JOIN part ON part.part = solutions.part;
