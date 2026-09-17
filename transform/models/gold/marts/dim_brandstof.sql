with source as (

    select distinct
        coalesce(brandstof_type, 'Onbekend') as brandstof_type
    from {{ ref('int_brandstof_geaggregeerd') }}

),

-- Zorg dat 'Onbekend' er altijd sowieso in staat als default rij
with_default as (

    select brandstof_type from source
    union
    select 'Onbekend' as brandstof_type

)

select
    md5(brandstof_type) as brandstof_key,
    brandstof_type,
    
    case 
        when brandstof_type like '%Elektriciteit%' and brandstof_type not like '%Benzine%' and brandstof_type not like '%Diesel%' then 'Volledig Elektrisch (BEV)'
        when brandstof_type like '%Elektriciteit%' then 'Plug-in / Hybride (PHEV/HEV)'
        when brandstof_type like '%Benzine%' then 'Benzine'
        when brandstof_type like '%Diesel%' then 'Diesel'
        when brandstof_type like '%LPG%' then 'LPG'
        else 'Overig'
    end as brandstof_hoofdcategorie

from with_default