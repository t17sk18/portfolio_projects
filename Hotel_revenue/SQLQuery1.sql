-- Querying data from the tables after importing from excel
select * from dbo.['2018$'];
select * from dbo.['2019$'];
select * from dbo.['2020$'];

-- Creating the Revenues table to combine all the data
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'revenues$')
BEGIN
    CREATE TABLE dbo.['revenues$'](
	[hotel] [nvarchar](255) NULL,
	[is_canceled] [float] NULL,
	[lead_time] [float] NULL,
	[arrival_date_year] [float] NULL,
	[arrival_date_month] [nvarchar](255) NULL,
	[arrival_date_week_number] [float] NULL,
	[arrival_date_day_of_month] [float] NULL,
	[stays_in_weekend_nights] [float] NULL,
	[stays_in_week_nights] [float] NULL,
	[adults] [float] NULL,
	[children] [float] NULL,
	[babies] [float] NULL,
	[meal] [nvarchar](255) NULL,
	[country] [nvarchar](255) NULL,
	[market_segment] [nvarchar](255) NULL,
	[distribution_channel] [nvarchar](255) NULL,
	[is_repeated_guest] [float] NULL,
	[previous_cancellations] [float] NULL,
	[previous_bookings_not_canceled] [float] NULL,
	[reserved_room_type] [nvarchar](255) NULL,
	[assigned_room_type] [nvarchar](255) NULL,
	[booking_changes] [float] NULL,
	[deposit_type] [nvarchar](255) NULL,
	[agent] [float] NULL,
	[company] [nvarchar](255) NULL,
	[days_in_waiting_list] [float] NULL,
	[customer_type] [nvarchar](255) NULL,
	[adr] [float] NULL,
	[required_car_parking_spaces] [float] NULL,
	[total_of_special_requests] [float] NULL,
	[reservation_status] [nvarchar](255) NULL,
	[reservation_status_date] [datetime] NULL
);
END;

-- Combining the Data and Inserting into revenues table by using union
insert into dbo.['revenues$']
select * from dbo.['2018$'] union
select * from dbo.['2019$'] union
select * from dbo.['2020$'];

select * from dbo.['revenues$'];

/* Exploratory Data Analysis (EDA)
Is our hotel revenue growing yearly?
Should we increase our parking lot size?
What trends can we see in the data?
*/

-- Total Revenue from the Hotel Bookings only by year
select r.arrival_date_year, sum((r.stays_in_week_nights+r.stays_in_weekend_nights)*r.adr) as revenue
from dbo.['revenues$'] as r
group by r.arrival_date_year;

-- Total Revenue from the Hotel Bookings only by year and hotel
select r.arrival_date_year, r.hotel, cast(sum((r.stays_in_week_nights+r.stays_in_weekend_nights)*r.adr) as decimal(10,2)) as revenue
from dbo.['revenues$']as r
group by r.hotel, r.arrival_date_year
order by r.hotel;

-- Total Revenue from the Hotel Bookings only by year and hotel; Percentagae of Parking occupied/left over these years
select r.arrival_date_year, r.hotel, cast(sum((r.stays_in_week_nights+r.stays_in_weekend_nights)*r.adr) as decimal(10,2)) as revenue,
CONCAT( round( (sum(r.required_car_parking_spaces)/sum(r.stays_in_week_nights + r.stays_in_weekend_nights)) *100 , 2), '%') as parking_percentage
from dbo.['revenues$'] as r
group by r.arrival_date_year, r.hotel
order by r.hotel;

-- Actual total revenue from the hotel booking, market segmentation and meals
select * from dbo.['revenues$']
left join dbo.market_segment$
on ['revenues$'].market_segment = [market_segment$].market_segment
left join dbo.meal_cost$
on [meal_cost$].meal = ['revenues$'].meal;

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




