with v as (

    select * from {{ ref('int_voertuigen_met_ex_lease') }}

),

b as (

    select * from {{ ref('int_brandstof_geaggregeerd') }}

)

select
    v.kenteken,

    -- Foreign Keys naar de dimensies
    cast(strftime(v.datum_eerste_toelating, '%Y%m%d') as int) as date_key,
    md5(coalesce(b.brandstof_type, 'Onbekend')) as brandstof_key,

    -- Quantitative Measures
    v.massa_ledig_voertuig_kg,
    b.co2_nedc_g_km,
    b.co2_wltp_g_km,

    -- Tellers voor Power BI aggregaties
    1 as aantal_voertuigen,
    case when b.co2_nedc_g_km is not null then 1 else 0 end as aantal_nedc_metingen,
    case when b.co2_wltp_g_km is not null then 1 else 0 end as aantal_wltp_metingen

from v
left join b on v.kenteken = b.kenteken