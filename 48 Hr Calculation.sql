select
        event_log_id,
         ( CAST(DATEDIFF(mm, s.actual_date, s.date_entered) AS DECIMAL(8,2))   /    CAST((24*60) AS DECIMAL(8,2))    )

                - cast (
                            (  
                            SELECT COUNT(*)
                            FROM dates
                            WHERE dates_id BETWEEN CAST(s.actual_date as                                 date) AND CAST(s.date_entered as date)
                            AND DATEPART(weekday,dates_id) IN ('1','7')
                            ) -- Subtract out weekend days
                as numeric)

                            + (CASE WHEN DATENAME(dw, s.actual_date) =                              'Sunday' THEN cast (1 as numeric) ELSE cast (0 as numeric) END)
        + (CASE WHEN DATENAME(dw, s.date_entered) = 'Saturday' THEN cast             (1 as numeric) ELSE cast (0 as numeric) END)
        -- Exclude Hoildays
                - cast (
                        (
                            SELECT COUNT(*)
                            FROM agency_holiday_details
                            WHERE start_date BETWEEN CAST(CONVERT                                       (VARCHAR,s.actual_date,101) AS DATETIME)                                 AND CAST(CONVERT(VARCHAR,s.date_entered                                 ,101) AS DATETIME)
                    )
        as numeric)
                                as daysdiff
from event_log s