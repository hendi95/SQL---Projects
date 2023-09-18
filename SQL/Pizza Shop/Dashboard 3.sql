--Dashboard 3

ALTER VIEW vw_Dashboard3 AS
SELECT 
    ws.date,
	st.staff_id,
    st.first_name,
    st.last_name,
    st.hourly_rate,
    s.start_time,
    s.end_time,
    CASE
        WHEN s.end_time < s.start_time THEN DATEDIFF(hour, s.start_time, s.end_time) + 24
        ELSE DATEDIFF(hour, s.start_time, s.end_time)
    END AS hours_in_shift,
    CASE
        WHEN s.end_time < s.start_time THEN (DATEDIFF(hour, s.start_time, s.end_time) + 24) * st.hourly_rate
        ELSE DATEDIFF(hour, s.start_time, s.end_time) * st.hourly_rate
    END AS staff_cost
FROM work_schedule ws
LEFT JOIN staff st ON ws.staff_id = st.staff_id
LEFT JOIN shifts s ON ws.shift_id = s.shift_id;
