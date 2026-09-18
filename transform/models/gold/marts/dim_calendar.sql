with
    date_sequence as (
        -- Vervanging van explode/sequence door DuckDB's range()
        select cast(range as date) as full_date
        from range(date '1940-01-01', date '2040-01-01', interval '1 day')
    ),

    week_anchors as (
        select
            date_trunc('week', current_date - interval '1' day) as current_week_start,
            date_trunc('week', current_date - interval '1' day) - interval '7' day as previous_week_start
    ),

    detailed_dates as (
        select
            full_date as calendar_date,
            day(full_date) as calendar_day_of_month,
            strftime(full_date, '%A') as calendar_day_name,
            
            -- DuckDB dayofweek: 0=zondag, 1=maandag, ..., 6=zaterdag
            case
                when dayofweek(full_date) = 0 then 7 
                else dayofweek(full_date) 
            end as calendar_day_of_week,
            
            dayofyear(full_date) as calendar_day_of_year,
            weekofyear(full_date) as calendar_week_of_year,
            month(full_date) as calendar_month_number,
            strftime(full_date, '%B') as calendar_month_name,
            quarter(full_date) as calendar_quarter_of_year,
            'Q' || quarter(full_date) as calendar_quarter_name,
            year(full_date) as calendar_year,
            
            case
                when dayofweek(full_date) between 1 and 5 then 1 else 0
            end as calendar_is_weekday,
            
            case
                when dayofweek(full_date) in (0, 6) then 1 else 0
            end as calendar_is_weekend,
            
            ceil(month(full_date) / 6.0)::int as calendar_semester,
            strftime(full_date, '%A, %B %d, %Y') as calendar_full_date_name,
            strftime(full_date, '%Y-%m') as calendar_year_month,
            
            year(full_date) || '-' || lpad(weekofyear(full_date)::varchar, 2, '0') as calendar_year_weeknumber,
            year(full_date) * 12 + month(full_date) - 1 as calendar_year_month_number,
            strftime(full_date, '%Y %B') as calendar_year_month_name,
            strftime(full_date, '%b %Y') as calendar_month_year_name,
            
            cast(calendar_date < current_date as int) as is_in_the_past,
            cast(calendar_date >= current_date as int) as is_in_the_future,
            
            cast(
                date_trunc('month', calendar_date) >= date_trunc('month', current_date - interval '12' month)
                and calendar_date <= current_date
            as int) as last_twelve_months,
            
            cast(
                date_trunc('month', calendar_date) >= date_trunc('month', current_date - interval '12' month)
                and date_trunc('month', calendar_date) < date_trunc('month', current_date)
            as int) as last_twelve_full_months,
            
            cast(
                date_trunc('month', calendar_date) >= date_trunc('month', current_date - interval '13' month)
                and date_trunc('month', calendar_date) < date_trunc('month', current_date)
            as int) as last_thirteen_full_months,
            
            date_trunc('week', calendar_date) = wa.current_week_start as is_current_week,
            date_trunc('week', calendar_date) = wa.previous_week_start as is_previous_week

        from date_sequence
        cross join week_anchors wa
    )

select
    cast(strftime(calendar_date, '%Y%m%d') as int) as date_key,
    calendar_date,
    calendar_day_of_month,
    calendar_day_name,
    calendar_day_of_week,
    calendar_day_of_year,
    calendar_week_of_year,
    calendar_month_number,
    calendar_month_name,
    calendar_quarter_of_year,
    calendar_quarter_name,
    calendar_year,
    calendar_is_weekday,
    calendar_is_weekend,
    calendar_semester,
    calendar_full_date_name,
    calendar_year_month,
    calendar_year_weeknumber,
    calendar_year_month_number,
    calendar_year_month_name,
    calendar_month_year_name,
    is_in_the_past,
    is_in_the_future,
    last_twelve_months,
    last_twelve_full_months,
    last_thirteen_full_months,
    is_current_week,
    is_previous_week
from detailed_dates