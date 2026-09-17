with v as (

    select * from {{ ref('int_voertuigen_met_ex_lease') }}

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
    gewichtsklasse,
    dagen_bij_huidige_houder,
    is_waarschijnlijk_ex_lease,
    case 
        when is_waarschijnlijk_ex_lease is true then 'Waarschijnlijk Ex-Lease (3-5 jaar)'
        else 'Overige Markt'
    end as ex_lease_cohort_label

from v