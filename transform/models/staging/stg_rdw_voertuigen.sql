with source as (

    select * from {{ source('rdw_raw', 'rdw_voertuigen') }}

)

select
    trim(kenteken) as kenteken,
    trim(voertuigsoort) as voertuigsoort,
    trim(merk) as merk,
    trim(handelsbenaming) as handelsbenaming,
    strptime(datum_eerste_toelating, '%Y%m%d')::date as datum_eerste_toelating,
    strptime(datum_tenaamstelling, '%Y%m%d')::date as datum_tenaamstelling,
    try_cast(massa_ledig_voertuig as integer) as massa_ledig_voertuig_kg,
    try_cast(datum_eerste_toelating as integer) // 10000 as bouwjaar

from source