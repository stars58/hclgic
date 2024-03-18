SELECT TO_CHAR (COMPLETION_TIME, 'DD/MM/YYYY') DAY,
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '00', 1, NULL))
            "00-01",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '01', 1, NULL))
            "01-02",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '02', 1, NULL))
            "02-03",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '03', 1, NULL))
            "03-04",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '04', 1, NULL))
            "04-05",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '05', 1, NULL))
            "05-06",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '06', 1, NULL))
            "06-07",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '07', 1, NULL))
            "07-08",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '08', 1, NULL))
            "08-09",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '09', 1, NULL))
            "09-10",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '10', 1, NULL))
            "10-11",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '11', 1, NULL))
            "11-12",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '12', 1, NULL))
            "12-13",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '13', 1, NULL))
            "13-14",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '14', 1, NULL))
            "14-15",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '15', 1, NULL))
            "15-16",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '16', 1, NULL))
            "16-17",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '17', 1, NULL))
            "17-18",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '18', 1, NULL))
            "18-19",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '19', 1, NULL))
            "19-20",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '20', 1, NULL))
            "20-21",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '21', 1, NULL))
            "21-22",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '22', 1, NULL))
            "22-23",
         SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'HH24'), '23', 1, NULL))
            "23-00",
         COUNT (*) TOTAL
    FROM V$ARCHIVED_LOG
WHERE ARCHIVED='YES'
and trunc(COMPLETION_TIME) between trunc(sysdate-7) and trunc(sysdate)
GROUP BY TO_CHAR (COMPLETION_TIME, 'DD/MM/YYYY')
ORDER BY TO_DATE (DAY, 'DD/MM/YYYY')