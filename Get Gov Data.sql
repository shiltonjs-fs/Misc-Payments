select
    A.*,
    AD.*
from
    DEV.SBOX_ADITHYA.SG_GOV_ACRA A
    left outer join DEV.SBOX_ADITHYA.SG_GOV_ADDITIONAL_DATA AD on AD.UEN = A.UEN
where
    AD.UEN is not null
    and UEN_STATUS = 'R';