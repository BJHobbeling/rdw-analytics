with voertuigen as (

    select * from {{ ref('stg_rdw_voertuigen') }}

)

select
    kenteken,
    merk,
    handelsbenaming,
    voertuigsoort,
    datum_eerste_toelating,
    datum_tenaamstelling,
    bouwjaar,
    massa_ledig_voertuig_kg,

    -- Business Logic 1: Gewichtsklasse
    case
        when massa_ledig_voertuig_kg < 1000 then 'Compact (<1000kg)'
        when massa_ledig_voertuig_kg between 1000 and 1500 then 'Middenklasse (1000-1500kg)'
        when massa_ledig_voertuig_kg > 1500 then 'Zwaar (>1500kg)'
        else 'Onbekend'
    end as gewichtsklasse,

    -- Business Logic 2: Ex-Lease Proxy
    date_diff('day', datum_eerste_toelating, datum_tenaamstelling) as dagen_bij_huidige_houder,
    case 
        when date_diff('month', datum_eerste_toelating, datum_tenaamstelling) between 36 and 60 
        then true 
        else false 
    end as is_waarschijnlijk_ex_lease

from voertuigen