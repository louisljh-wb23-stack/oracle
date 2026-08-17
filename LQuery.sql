-- A4 landscape output
SET linesize 120
SET pagesize 35

--set output date in Malaysia date format
ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy';

Outstanding Invoice Report

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
TTITLE OFF

COLUMN institution FORMAT A30 HEADING 'Institution'
COLUMN invoice_id FORMAT A12 HEADING 'Invoice ID'
COLUMN issuance_date FORMAT A12 HEADING 'Invoice Date'
COLUMN amount FORMAT 999,999.99 HEADING 'Amount (RM)'

TTITLE CENTER 'Invoice Report Of Institutions' SKIP 2

BREAK ON institution SKIP 1

COMPUTE SUM LABEL 'Total Amount (RM): ' OF amount ON institution

ACCEPT v_status CHAR PROMPT 'Enter invoice status (PAID/PENDING/CANCELLED): '
ACCEPT v_customer_id CHAR PROMPT 'Enter Customer ID (or ALL): '
ACCEPT v_institution CHAR PROMPT 'Enter Institution (or ALL): '

SELECT
    c.institution,
    i.invoice_id,
    i.issuance_date,
    i.amount
FROM invoice i
JOIN booking b
    ON b.booking_id = i.booking_id
JOIN customer c
    ON c.customer_id = b.customer_id
WHERE UPPER(i.status) = UPPER('&v_status')
  AND (
        UPPER('&v_customer_id') = 'ALL'
        OR c.customer_id = '&v_customer_id'
      )
  AND (
        UPPER('&v_institution') = 'ALL'
        OR UPPER(c.institution) = UPPER('&v_institution')
      )
ORDER BY c.institution, i.issuance_date;

Revenue Checking monthly and annually
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
TTITLE OFF

COLUMN revenue_year FORMAT 9999 HEADING 'Year'
COLUMN booking_id FORMAT A12 HEADING 'Booking ID'
COLUMN status FORMAT A10 HEADING 'Status'
COLUMN revenue FORMAT 999,999.99 HEADING 'Revenue (RM)'

ACCEPT v_month CHAR FORMAT '99' PROMPT 'Enter month (01-12): '
ACCEPT v_status CHAR PROMPT 'Enter status (PAID/PENDING): '

TTITLE CENTER 'Revenue Report' SKIP 1

BREAK ON revenue_year SKIP 1

COMPUTE SUM LABEL 'Year Total (RM): ' OF revenue ON revenue_year

SELECT
    EXTRACT(YEAR FROM i.issuance_date) AS revenue_year,
    b.booking_id,
    i.status,
    i.amount AS revenue
FROM invoice i
JOIN booking b
    ON b.booking_id = i.booking_id
WHERE TO_CHAR(i.issuance_date, 'MM') = '&v_month'
  AND UPPER(i.status) = UPPER('&v_status')
ORDER BY revenue_year, b.booking_id;

Booking Checking and Price calculation based on distance
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
TTITLE OFF

COLUMN customer_id  FORMAT A12        HEADING 'Customer ID'
COLUMN booking_id   FORMAT A12        HEADING 'Booking ID'
COLUMN bus_id       FORMAT A10        HEADING 'Bus ID'
COLUMN bus_type     FORMAT A22        HEADING 'Bus Type'
COLUMN distance     FORMAT 9990.00    HEADING 'Distance (km)'
COLUMN custrmbooking_time FORMAT A20        HEADING 'Booking Time'
COLUMN price        FORMAT 999,999.99 HEADING 'Price'

-- one date, plus a start/end time window within that same day
ACCEPT v_Date CHAR FORMAT A10 PROMPT 'Enter date (dd/mm/yyyy): '
ACCEPT v_startTime CHAR PROMPT 'Enter start time (HH24:MI): '
ACCEPT v_endTime   CHAR PROMPT 'Enter end time (HH24:MI): '

TTITLE CENTER 'Booking Price Report' SKIP 2

BREAK ON customer_id SKIP 1 ON booking_id

COMPUTE SUM LABEL 'Booking Total: '
    OF price ON booking_id

SELECT
    b.customer_id,
    b.booking_id,
    bus.bus_id,
    bus.bus_type,
    t.distance,
    b.custrmbooking_time,
    CASE
        WHEN UPPER(bus.bus_type) = 'STANDARD SCHOOL BUS'
            THEN 50 + (t.distance * 1.50)
        WHEN UPPER(bus.bus_type) = 'DELUXE BUS'
            THEN 80 + (t.distance * 2.50)
        WHEN UPPER(bus.bus_type) = 'CHARTER BUS'
            THEN 120 + (t.distance * 4.00)
        WHEN UPPER(bus.bus_type) = 'MAGIC BUS'
            THEN 50 + (t.distance * 2.00)
    END AS price
FROM booking b
JOIN trip t
    ON t.booking_id = b.booking_id
JOIN trip_bus tb
    ON tb.trip_id = t.trip_id
JOIN bus
    ON bus.bus_id = tb.bus_id
WHERE b.custrmbooking_time >=
      TO_DATE('&v_Date ' || '&v_startTime', 'DD/MM/YYYY HH24:MI')
  AND b.custrmbooking_time <=
      TO_DATE('&v_Date ' || '&v_endTime', 'DD/MM/YYYY HH24:MI')
ORDER BY
    b.customer_id,
    b.booking_id,
    b.custrmbooking_time;


JOIN trip t
    ON t.booking_id = b.booking_id

JOIN trip_bus tb
    ON tb.trip_id = t.trip_id

JOIN bus
    ON bus.bus_id = tb.bus_id

WHERE b.booking_time >=
      TO_DATE('&v_Date', 'DD/MM/YYYY HH24:MI')

  AND b.booking_time <=
      TO_DATE('&v_endDate ' || '&v_endTime',
              'DD/MM/YYYY HH24:MI')

ORDER BY b.booking_id, b.booking_time; 


