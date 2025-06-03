--ulang
with
    ACRA_MATCHING as (
        select distinct
            SUBSTRING(LOWER(PAYEE_NAME), CHARINDEX('_', PAYEE_NAME) + 1, LEN(PAYEE_NAME)) as PAYEE_NAME,
            PRIMARY_SSIC_DESCRIPTION
        from
            DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA
    ),
    TX_TABLE as (
        select
            T1.PRIMARY_SSIC_DESCRIPTION, T2.*
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2
            left outer join ACRA_MATCHING T1 on T1.PAYEE_NAME = SUBSTRING(
                LOWER(T2.CARDUP_PAYMENT_PAYEE_NAME),
                CHARINDEX('_', T2.CARDUP_PAYMENT_PAYEE_NAME) + 1,
                LEN(T2.CARDUP_PAYMENT_PAYEE_NAME)
            )
        where
            true
            and T2.CARDUP_PAYMENT_USD_AMT is not null
            and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
    ),
    FIRST_TX_DATE as (
        SELECT
            CARDUP_PAYMENT_USER_ID,
            MIN(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS) AS FIRST_TX_DATE
        FROM
            TX_TABLE
        group by
            1
    ),
    FIRST_TX as (
        select distinct
            T1.CARDUP_PAYMENT_USER_ID,
            case
                when T1.CARDUP_PAYMENT_PAYMENT_TYPE = 'Misc' then T1.PRIMARY_SSIC_DESCRIPTION
                else T1.CARDUP_PAYMENT_PAYMENT_TYPE
            end as CARDUP_PAYMENT_PAYMENT_TYPE,
            T2.FIRST_TX_DATE
        from
            TX_TABLE T1
            join FIRST_TX_DATE T2 on T1.CARDUP_PAYMENT_USER_ID = T2.CARDUP_PAYMENT_USER_ID and T1.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS = T2.FIRST_TX_DATE
    )
select
    T2.CARDUP_PAYMENT_PAYMENT_TYPE FIRST_PAYMENT_TYPE,
    date(MIN(date_trunc(month, T1.CARDUP_PAYMENT_SUCCESS_AT_LCL_TS)) over(partition by T1.CARDUP_PAYMENT_USER_ID)) AS EARLIEST_MONTH,
    datediff(month, MIN(date_trunc(month, T1.CARDUP_PAYMENT_SUCCESS_AT_LCL_TS)) over(partition by T1.CARDUP_PAYMENT_USER_ID), date_trunc(month, T1.CARDUP_PAYMENT_SUCCESS_AT_LCL_TS)) as MONTHS_SINCE_FIRST_PAYMENT,
    T1.*
from
    TX_TABLE T1
    left outer join FIRST_TX T2 on T1.CARDUP_PAYMENT_USER_ID = T2.CARDUP_PAYMENT_USER_ID
where T2.CARDUP_PAYMENT_PAYMENT_TYPE = 'REAL ESTATE AGENCIES AND VALUATION SERVICES'
and CARDUP_PAYMENT_SUCCESS_AT_LCL_TS is not null and CARDUP_PAYMENT_STATUS in ('Complete', 'Payment Success');