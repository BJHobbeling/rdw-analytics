with source as (

    select * from {{ source('rdw_raw', 'rdw_brandstof') }}

)

select
    trim(kenteken) as kenteken,
    trim(brandstof_omschrijving) as brandstof_omschrijving,
    try_cast(co2_uitstoot_gecombineerd as integer) as co2_nedc_g_km,
    try_cast(emissie_co2_gecombineerd_wltp as integer) as co2_wltp_g_km

from source