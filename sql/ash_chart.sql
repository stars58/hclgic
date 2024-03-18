SELECT sample_time,
  cpu/60            AS cpu,
  bcpu/60           AS bcpu,
  scheduler/60      AS scheduler,
  uio/60            AS uio,
  sio/60            AS sio,
  concurrency/60    AS concurrency,
  application/60    AS application,
  COMMIT/60         AS COMMIT,
  configuration/60  AS configuration,
  administrative/60 AS administrative,
  network/60        AS network,
  queueing/60       AS queueing,
  clust/60          AS clust,
  other/60          AS other
FROM (SELECT
        TRUNC(sample_time,'MI') AS sample_time,
        DECODE(session_state,'ON CPU',DECODE(session_type,'BACKGROUND','BCPU','ON CPU'), wait_class) AS wait_class
      FROM v$active_session_history
      WHERE sample_time>sysdate- INTERVAL '1' HOUR
      AND sample_time<=TRUNC(SYSDATE,'MI')) ash
PIVOT (COUNT(*) FOR wait_class IN ('ON CPU' AS cpu,'BCPU' AS bcpu,'Scheduler' AS scheduler,'User I/O' AS uio,'System I/O' AS sio,
'Concurrency' AS concurrency,'Application' AS application,'Commit' AS COMMIT,'Configuration' AS configuration,
'Administrative' AS administrative,'Network' AS network,'Queueing' AS queueing,'Cluster' AS clust,'Other' AS other));