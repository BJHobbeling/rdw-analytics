with brandstof as (

    select * from {{ ref('stg_rdw_brandstof') }}

)

select
    kenteken,
    string_agg(distinct brandstof_omschrijving, ' / ') as brandstof_type,
    max(co2_nedc_g_km) as co2_nedc_g_km,
    max(co2_wltp_g_km) as co2_wltp_g_km

from brandstof
group by 1