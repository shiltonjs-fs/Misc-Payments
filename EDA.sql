--Get list of P12M B2C payments under Miscellaneous, with payID, custID, date, payee name, oneoff/recurring, GTV, NetRev, Rev
select
    DWH_CARDUP_PAYMENT_ID PAYMENT_ID,
    cardup_payment_user_id user_id,
    DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS) PAYMENT_DATE,
    CARDUP_PAYMENT_PAYEE_NAME PAYEE_NAME,
    CARDUP_PAYMENT_SCHEDULE_TYPE SCHEDULE_TYPE,
    CARDUP_PAYMENT_PAYEE_BANK_COUNTRY PAYEE_COUNTRY,
    CARDUP_PAYMENT_USD_AMT GTV,
    CARDUP_PAYMENT_NET_REVENUE_USD_AMT NET_REVENUE,
    CARDUP_PAYMENT_TOTAL_REVENUE_USD_AMT REVENUE
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
where
    CARDUP_PAYMENT_STATUS NOT IN ('Payment Failed', 'Cancelled', 'Refunded', 'Refunding')
    and CARDUP_PAYMENT_PAYMENT_TYPE = 'Misc'
    and CARDUP_PAYMENT_USD_AMT is not null
    and CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) = '2024-05-01';


--Get list of P12M B2C payments under new Paytypes, with payID, custID, date, payee name, oneoff/recurring, GTV, NetRev, Rev
select
    CARDUP_PAYMENT_PAYMENT_TYPE PAYMENT_TYPE,
    sum(CARDUP_PAYMENT_USD_AMT) GTV
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
where
    CARDUP_PAYMENT_STATUS NOT IN ('Payment Failed', 'Cancelled', 'Refunded', 'Refunding')
    and CARDUP_PAYMENT_USD_AMT is not null
    and CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) = '2025-05-01'
group by 1;

