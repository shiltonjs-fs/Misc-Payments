with
    FOO as (
        select
            CARDUP_PAYMENT_USER_ID,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Car Loan' then 1
                    else 0
                end
            ) as PAYTYPE_CARLOAN,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Condo & MCST fees' then 1
                    else 0
                end
            ) as PAYTYPE_CONDO,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Education' then 1
                    else 0
                end
            ) as PAYTYPE_EDUCATION,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Helper Salary' then 1
                    else 0
                end
            ) as PAYTYPE_HELPER,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Income Tax' then 1
                    else 0
                end
            ) as PAYTYPE_INCOME,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Insurance' then 1
                    else 0
                end
            ) as PAYTYPE_INSURANCE,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Misc' then 1
                    else 0
                end
            ) as PAYTYPE_MISC,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Mortgage' then 1
                    else 0
                end
            ) as PAYTYPE_MORTGAGE,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Parking' then 1
                    else 0
                end
            ) as PAYTYPE_PARKING,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Property Tax' then 1
                    else 0
                end
            ) as PAYTYPE_PROPERTYTAX,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Renovation' then 1
                    else 0
                end
            ) as PAYTYPE_RENOVATION,
            MAX(
                case
                    when CARDUP_PAYMENT_PAYMENT_TYPE = 'Rent' then 1
                    else 0
                end
            ) as PAYTYPE_RENT
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
        where
            true
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
        group by
            1
    )
select
    *
from
    FOO
where
    PAYTYPE_MISC = 1;

with
    FOO as (
        select
            DWH_CARDUP_PAYMENT_ID PAYMENT_ID,
            CARDUP_PAYMENT_USER_ID USER_ID,
            DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS) PAYMENT_DATE,
            CARDUP_PAYMENT_PAYEE_NAME PAYEE_NAME,
            CARDUP_PAYMENT_SCHEDULE_TYPE SCHEDULE_TYPE,
            CARDUP_PAYMENT_USD_AMT GTV,
            CARDUP_PAYMENT_NET_REVENUE_USD_AMT NET_REVENUE,
            CARDUP_PAYMENT_TOTAL_REVENUE_USD_AMT REVENUE
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
        where
            CARDUP_PAYMENT_PAYMENT_TYPE = 'Misc'
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    ),
    BAR as (
        select
            USER_ID,
            PAYEE_NAME,
            CAST(COUNT(distinct PAYMENT_ID) as FLOAT) COUNT_PAYMENT_ID
        from
            FOO
        group by
            1,
            2
    )
select
    APPROX_PERCENTILE(COUNT_PAYMENT_ID, 0.5),
    AVG(COUNT_PAYMENT_ID)
from
    BAR;

with
    FOO as (
        select
            DWH_CARDUP_PAYMENT_ID PAYMENT_ID,
            CARDUP_PAYMENT_USER_ID USER_ID,
            DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS) PAYMENT_DATE,
            CARDUP_PAYMENT_PAYEE_NAME PAYEE_NAME,
            CARDUP_PAYMENT_SCHEDULE_TYPE SCHEDULE_TYPE,
            CARDUP_PAYMENT_PAYMENT_FREQUENCY FREQ,
            CARDUP_PAYMENT_PAYMENT_TYPE,
            CARDUP_PAYMENT_USD_AMT GTV,
            CARDUP_PAYMENT_NET_REVENUE_USD_AMT NET_REVENUE,
            CARDUP_PAYMENT_TOTAL_REVENUE_USD_AMT REVENUE
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
        where
            CARDUP_PAYMENT_PAYMENT_TYPE = 'Misc'
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    )
select
    SCHEDULE_TYPE,
    FREQ,
    COUNT(distinct PAYEE_NAME),
    COUNT(distinct USER_ID),
    COUNT(distinct PAYMENT_ID)
from
    FOO
group by
    1,
    2;

select
    DWH_CARDUP_PAYMENT_ID,
    CARDUP_PAYMENT_PAYMENT_FREQUENCY,
    CARDUP_PAYMENT_USER_ID
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
where
    CARDUP_PAYMENT_PAYMENT_TYPE = 'Misc'
    and CARDUP_PAYMENT_SCHEDULE_TYPE = 'recurring'
    and CARDUP_PAYMENT_USD_AMT is not null
    and CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01';

select
    *
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
limit
    10;

with
    T1 as (
        select distinct
            T1.DWH_CARDUP_PAYMENT_ID,
            T1.CARDUP_PAYMENT_USER_ID,
            T2.MISC_CODED_1,
            T1.CARDUP_PAYMENT_PAYMENT_TYPE,
            T1.CARDUP_PAYMENT_USD_AMT GTV,
            T1.CARDUP_PAYMENT_NET_REVENUE_USD_AMT NET_REVENUE,
            T1.CARDUP_PAYMENT_TOTAL_REVENUE_USD_AMT REVENUE
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
            join DEV.SBOX_SHILTON.MISC_PAY_TYPE T2 on T1.CARDUP_PAYMENT_USER_ID = T2.USER_ID
        where
            MISC_CODED_1 = 'car leasing/rental'
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    ),
    T2 as (
        select
            CARDUP_PAYMENT_PAYMENT_TYPE,
            CARDUP_PAYMENT_USER_ID,
            SUM(GTV) GTV,
            COUNT(distinct DWH_CARDUP_PAYMENT_ID) COUNT_PAYMENT,
        from
            T1
        group by
            1,
            2
    )
select
    CARDUP_PAYMENT_PAYMENT_TYPE,
    APPROX_PERCENTILE(GTV, 0.5),
    APPROX_PERCENTILE(COUNT_PAYMENT, 0.5),
    SUM(COUNT_PAYMENT),
    COUNT(distinct CARDUP_PAYMENT_USER_ID)
from
    T2
group by
    1;

with
    T1 as (
        select distinct
            T1.DWH_CARDUP_PAYMENT_ID,
            T1.CARDUP_PAYMENT_USER_ID,
            T2.MISC_CODED_1,
            T1.CARDUP_PAYMENT_PAYMENT_TYPE,
            T1.CARDUP_PAYMENT_USD_AMT GTV,
            T1.CARDUP_PAYMENT_NET_REVENUE_USD_AMT NET_REVENUE,
            T1.CARDUP_PAYMENT_TOTAL_REVENUE_USD_AMT REVENUE
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
            join DEV.SBOX_SHILTON.MISC_PAY_TYPE T2 on T1.CARDUP_PAYMENT_USER_ID = T2.USER_ID
        where
            MISC_CODED_1 = 'car leasing/rental'
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    ),
    T2 as (
        select
            CARDUP_PAYMENT_PAYMENT_TYPE,
            CARDUP_PAYMENT_USER_ID,
            SUM(GTV) GTV,
            COUNT(distinct DWH_CARDUP_PAYMENT_ID) COUNT_PAYMENT,
        from
            T1
        group by
            1,
            2
    )
select
    CARDUP_PAYMENT_PAYMENT_TYPE,
    APPROX_PERCENTILE(GTV, 0.5),
    APPROX_PERCENTILE(COUNT_PAYMENT, 0.5),
    SUM(COUNT_PAYMENT),
    COUNT(distinct CARDUP_PAYMENT_USER_ID)
from
    T2
group by
    1;

select
    DATE_TRUNC(month, DATE(CARDUP_PAYMENT_SUCCESS_AT_LCL_TS)) as month,
    SUM(CARDUP_PAYMENT_USD_AMT)
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
    join DEV.SBOX_SHILTON.MISC_PAY_TYPE T2 on T1.CARDUP_PAYMENT_USER_ID = T2.USER_ID
where
    MISC_CODED_1 = 'lawyer/legal'
    and CARDUP_PAYMENT_USD_AMT is not null
    and CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
group by
    1;

select
    A.ENTITY_NAME,
    AD.*
from
    DEV.SBOX_ADITHYA.SG_GOV_ACRA A
    full outer join DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA AD on AD.UEN = A.UEN
where
    AD.UEN is not null
    and LOWER(ENTITY_NAME) like '%era%'
    and LOWER(ENTITY_NAME) like '%realty%';

select
    A.ENTITY_NAME,
    AD.*
from
    DEV.SBOX_ADITHYA.SG_GOV_ACRA A
    full outer join DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA AD on AD.UEN = A.UEN
where
    AD.UEN is not null
    and A.UEN like '%198103027M%';

select
    *
from
    DEV.SBOX_ADITHYA.SG_GOV_ACRA
where
    UEN like '%198103027M%';

select
    *
from
    DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA
where
    UEN like '%198103027M%';

select
    COUNT(distinct UEN)
from
    DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA;

select distinct
    (ENTITY_TYPE)
from
    DEV.SBOX_ADITHYA.SG_GOV_ACRA A
    left outer join DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA AD on AD.UEN = A.UEN
where
    AD.UEN is not null
    and UEN_STATUS = 'R';

select
    *
from
    DEV.SBOX_ADITHYA.SG_GOV_ACRA A
    left outer join DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA AD on AD.UEN = A.UEN
where
    AD.UEN is not null
    and AD.UEN = 'T08CC4085D';

select
    CARDUP_PAYMENT_PAYEE_BANK_COUNTRY
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T
limit
    10;

with
    T1 as (
        select distinct
            T1.DWH_CARDUP_PAYMENT_ID,
            T1.CARDUP_PAYMENT_USER_ID,
            T2.PRIMARY_SSIC_DESCRIPTION,
            T1.CARDUP_PAYMENT_PAYMENT_TYPE,
            T1.CARDUP_PAYMENT_USD_AMT GTV,
            T1.CARDUP_PAYMENT_NET_REVENUE_USD_AMT NET_REVENUE,
            T1.CARDUP_PAYMENT_TOTAL_REVENUE_USD_AMT REVENUE
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
            join DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA T2 on T1.CARDUP_PAYMENT_USER_ID = T2.USER_ID
        where
            PRIMARY_SSIC_DESCRIPTION in (
                'RENTING AND LEASING OF PRIVATE CARS WITHOUT DRIVER (EXCLUDING ONLINE MARKETPLACES)',
                'RENTAL AND LEASING OF CARS WITH DRIVER (EXCLUDING STREET-HAIL AND RIDE-HAIL SERVICE PROVIDERS)'
            )
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30'
    ),
    T2 as (
        select
            CARDUP_PAYMENT_PAYMENT_TYPE,
            CARDUP_PAYMENT_USER_ID,
            SUM(GTV) GTV,
            COUNT(distinct DWH_CARDUP_PAYMENT_ID) COUNT_PAYMENT,
        from
            T1
        group by
            1,
            2
    )
select
    CARDUP_PAYMENT_PAYMENT_TYPE,
    APPROX_PERCENTILE(GTV, 0.5),
    APPROX_PERCENTILE(COUNT_PAYMENT, 0.5),
    SUM(COUNT_PAYMENT),
    COUNT(distinct CARDUP_PAYMENT_USER_ID)
from
    T2
group by
    1;

-- check whether car buyer is local or not
with
    CAR_BUYER_USERDATA as (
        select distinct
            T1.CARDUP_PAYMENT_USER_ID,
            case
                when PRIMARY_SSIC_DESCRIPTION in ('RETAIL SALE OF MOTOR VEHICLES EXCEPT MOTORCYCLES AND SCOOTERS') then 'car buyer'
                else 'not car buyer'
            end as CAR_BUYER
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
            join DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA T2 on T1.CARDUP_PAYMENT_USER_ID = T2.USER_ID
        where
            true
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30'
    )
select
    T1.CAR_BUYER,
    T2.CARDUP_PAYMENT_USER_ID,
    T2.CARDUP_PAYMENT_PAYMENT_TYPE,
    APPROX_PERCENTILE(T2.CARDUP_PAYMENT_USD_AMT, 0.5) MEDIAN_GTV,
    COUNT(distinct T2.CARDUP_PAYMENT_USER_ID)
from
    CAR_BUYER_USERDATA T1
    join ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2 on T1.CARDUP_PAYMENT_USER_ID = T2.CARDUP_PAYMENT_USER_ID
where
    true
    and T2.CARDUP_PAYMENT_USD_AMT is not null
    and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30'
group by
    ROLLUP (1, 2);

select distinct
    T1.CARDUP_PAYMENT_USER_ID,
    COUNT(distinct DWH_CARDUP_PAYMENT_ID)
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
    join DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA T2 on T1.DWH_CARDUP_PAYMENT_ID = T2.PAYMENT_ID
where
    PRIMARY_SSIC_DESCRIPTION in ('RETAIL SALE OF MOTOR VEHICLES EXCEPT MOTORCYCLES AND SCOOTERS')
    and CARDUP_PAYMENT_USD_AMT is not null
    and CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30'
group by
    1;

select
    T1.CARDUP_PAYMENT_USER_ID,
    MAX(
        case
            when PRIMARY_SSIC_DESCRIPTION in ('RETAIL SALE OF MOTOR VEHICLES EXCEPT MOTORCYCLES AND SCOOTERS') then 1
            else 0
        end
    ) as CARBUYER,
    MAX(
        case
            when PRIMARY_SSIC_DESCRIPTION in ('REPAIR AND MAINTENANCE OF MOTOR VEHICLES (INCLUDING INSTALLATION OF PARTS & ACCESSORIES)') then 1
            else 0
        end
    ) as CAREPAIR
from
    ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
    join DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA T2 on T1.DWH_CARDUP_PAYMENT_ID = T2.PAYMENT_ID
where
    true
    and CARDUP_PAYMENT_USD_AMT is not null
    and CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30'
group by
    1;

--month education for transport payors
with
    TRANSPORT_USERDATA as (
        select distinct
            T1.CARDUP_PAYMENT_USER_ID,
            case
                when PRIMARY_SSIC_DESCRIPTION in ('CHARTERED BUS SERVICES (INCLUDING SCHOOL BUSES)') then 'transport'
                else 'not transport'
            end as TRANSPORT
        from
            ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T1
            join DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA T2 on T1.CARDUP_PAYMENT_USER_ID = T2.USER_ID
        where
            true
            and CARDUP_PAYMENT_USD_AMT is not null
            and CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
            and DATE_TRUNC('month', DATE(CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-11-30'
    )
select distinct
    T2.CARDUP_PAYMENT_USER_ID,
    T2.DWH_CARDUP_PAYMENT_ID,
    DATE_TRUNC(month, DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS))
from
    TRANSPORT_USERDATA T1
    join ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2 on T1.CARDUP_PAYMENT_USER_ID = T2.CARDUP_PAYMENT_USER_ID
where
    T1.TRANSPORT = 'transport'
    and T2.CARDUP_PAYMENT_PAYMENT_TYPE = 'Education'
    and T2.CARDUP_PAYMENT_USD_AMT is not null
    and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2023-10-01'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30';


--P36 Lawyer
with
    ACRA_MATCHING as (
        select distinct
            SUBSTRING(LOWER(PAYEE_NAME), CHARINDEX('_', PAYEE_NAME) + 1, LEN(PAYEE_NAME)) as PAYEE_NAME,
            PRIMARY_SSIC_DESCRIPTION
        from
            DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA
    )
select distinct
    T2.CARDUP_PAYMENT_USER_ID,
    T2.DWH_CARDUP_PAYMENT_ID,
    DATE_TRUNC(month, DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS))
from
    ACRA_MATCHING T1
    join ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2 on T1.PAYEE_NAME = SUBSTRING(
        LOWER(T2.CARDUP_PAYMENT_PAYEE_NAME),
        CHARINDEX('_', T2.CARDUP_PAYMENT_PAYEE_NAME) + 1,
        LEN(T2.CARDUP_PAYMENT_PAYEE_NAME)
    )
where
    T1.PRIMARY_SSIC_DESCRIPTION = 'LEGAL ACTIVITIES (EXCLUDING ONLINE MARKETPLACES)'
    and T2.CARDUP_PAYMENT_USD_AMT is not null
    and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2021-10-01'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30';

--P36 Transport
with
    ACRA_MATCHING as (
        select distinct
            SUBSTRING(LOWER(PAYEE_NAME), CHARINDEX('_', PAYEE_NAME) + 1, LEN(PAYEE_NAME)) as PAYEE_NAME,
            PRIMARY_SSIC_DESCRIPTION
        from
            DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA
    )
select distinct
    T2.CARDUP_PAYMENT_USER_ID,
    T2.DWH_CARDUP_PAYMENT_ID,
    DATE_TRUNC(month, DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS))
from
    ACRA_MATCHING T1
    join ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2 on T1.PAYEE_NAME = SUBSTRING(
        LOWER(T2.CARDUP_PAYMENT_PAYEE_NAME),
        CHARINDEX('_', T2.CARDUP_PAYMENT_PAYEE_NAME) + 1,
        LEN(T2.CARDUP_PAYMENT_PAYEE_NAME)
    )
where
    T1.PRIMARY_SSIC_DESCRIPTION = 'CHARTERED BUS SERVICES (INCLUDING SCHOOL BUSES)'
    and T2.CARDUP_PAYMENT_USD_AMT is not null
    and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2021-10-01'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30';

--P36 Transport Educ
with
    ACRA_MATCHING as (
        select distinct
            SUBSTRING(LOWER(PAYEE_NAME), CHARINDEX('_', PAYEE_NAME) + 1, LEN(PAYEE_NAME)) as PAYEE_NAME,
            PRIMARY_SSIC_DESCRIPTION
        from
            DEV.SBOX_SHILTON.MISC_PAYMENT_TYPES_ACRA
    ),
    USERS_TRANSPORT as (
        select distinct
            T2.CARDUP_PAYMENT_USER_ID
        from
            ACRA_MATCHING T1
            join ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2 on T1.PAYEE_NAME = SUBSTRING(
                LOWER(T2.CARDUP_PAYMENT_PAYEE_NAME),
                CHARINDEX('_', T2.CARDUP_PAYMENT_PAYEE_NAME) + 1,
                LEN(T2.CARDUP_PAYMENT_PAYEE_NAME)
            )
        where
            T1.PRIMARY_SSIC_DESCRIPTION = 'CHARTERED BUS SERVICES (INCLUDING SCHOOL BUSES)'
            and T2.CARDUP_PAYMENT_USD_AMT is not null
            and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
            and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2021-10-01'
            and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30'
    )
select distinct
    T2.CARDUP_PAYMENT_USER_ID,
    T2.DWH_CARDUP_PAYMENT_ID,
    DATE_TRUNC(month, DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS))
from
    USERS_TRANSPORT T3
    join ADM.TRANSACTION.CARDUP_PAYMENT_DENORM_T T2 on T3.CARDUP_PAYMENT_USER_ID = T2.CARDUP_PAYMENT_USER_ID
where
    true
    and T2.CARDUP_PAYMENT_USD_AMT is not null
    and T2.CARDUP_PAYMENT_USER_TYPE = 'consumer'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) >= '2021-10-01'
    and DATE_TRUNC('month', DATE(T2.CARDUP_PAYMENT_SUCCESS_AT_UTC_TS)) <= '2024-09-30';


select * from DEV.SBOX_SHILTON.CU_B2C_PAYEE_NAME_MATCHED limit 10;