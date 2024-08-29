-- Creating a temporary table to merge the data from all the tables using union
with ['temp_revenues$'] as (
select * from dbo.['2018$']
union
select * from dbo.['2019$']
union
select * from dbo.['2020$'])

-- Actual total revenue from the hotel booking, market segmentation and meals
select * from dbo.['revenues$']
left join dbo.market_segment$
on ['revenues$'].market_segment = [market_segment$].market_segment
left join dbo.meal_cost$
on meal_cost$.meal = ['revenues$'].meal

-- Calcualting Actual Revenue
select r.arrival_date_year, r.hotel,
round (sum(((r.stays_in_week_nights+r.stays_in_weekend_nights) * r.adr * (1 - ms.Discount)) + 
	((r.adults + r.children + r.babies) * mc.Cost)), 2) as revenue
from dbo.['revenues$'] as r
left join dbo.market_segment$ as ms
on r.market_segment = ms.market_segment
left join dbo.meal_cost$ as mc
on mc.meal = r.meal
group by r.arrival_date_year, r.hotel
order by r. hotel, r.arrival_date_year ;