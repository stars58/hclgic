Prompt **** breakdown of cluster waits
SELECT event, SUM(total_waits) total_waits,
           ROUND(SUM(time_waited_micro) / 1000000, 2)
             time_waited_secs,
           ROUND(SUM(time_waited_micro) / 1000 /
             SUM(total_waits), 2) avg_ms
    FROM gv$system_event
    WHERE       event LIKE 'gc%block%way'
          OR event LIKE 'gc%multi%'
          OR event LIKE 'gc%grant%'
         OR event LIKE 'cell single%'
   GROUP BY event
   HAVING SUM(total_waits) > 0
   ORDER BY event;