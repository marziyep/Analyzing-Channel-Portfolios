
/*with gsearch doing well and the site performing better,we lunched a second paid channel,bsearch,around Agust 22.
Can you pull weekly trended session volume since then and compare to gsearch nonbrand.email date(Nov 29,2012)*/

select * from website_session
select * from orders


select * from website_session
where utm_source='bsearch'
order by created_at asc

create view df1 as
select website_session_id,convert(date,DATEADD(DD,-(CHOOSE(DATEPART(dw, created_at), 1,2,3,4,5,6,0)),created_at)) AS WeekStartDate,utm_source from website_session
where created_at<'2012-11-29' and created_at>'2012-08-22' and utm_source in ('gsearch','bsearch') and utm_campaign='nonbrand'


select WeekStartDate,sum(case  when utm_source='bsearch' then 1 else 0   end) as bsearch,
sum(case  when utm_source='gsearch' then 1 else 0   end) as gsearch,
count(website_session_id)
from df1
group by WeekStartDate
order by WeekStartDate



/*I would like to learn more about the bsearch nonbrand cmpaingn.
Could you please pull the percentage of traffic comming on mobile,and compare that to gsearch?Aggregate data since August 22nd.email(Nov30-2012)*/

create view df2 as 
 select * from website_session
where created_at<'2012-11-30' and created_at>'2012-08-22' and utm_source in ('gsearch','bsearch') and utm_campaign='nonbrand'

select utm_source,
count(website_session_id) as total_session,
sum(case when device_type='mobile' then 1  end ) as mobile_session

from df2
group by utm_source


/*I am wondering if bsearch nonbrand should have the same bids as gsearch.
Could you pull nonbrand conversion rates from session to order for gsearch and bsearch,and slice the data by device type>please analyze data from August22 to September18.*/


create view df3 as
select * from website_session
where created_at<'2012-09-18' and created_at>'2012-08-22' and utm_source in ('gsearch','bsearch') and utm_campaign='nonbrand'

create view df4 as
select df3.website_session_id,utm_source,device_type,order_id from df3
left join orders
on df3.website_session_id=orders.website_session_id

select utm_source,
count(website_session_id) as total_session,
count(order_id) as total_order,
count(case when device_type='desktop' then website_session_id else null end)  as desktop_session ,
count(case when device_type='desktop' then order_id else null end)  as desktop_order,
count(case when device_type='mobile' then website_session_id else null end)  as mobile_session ,
count(case when device_type='mobile' then order_id else null end)  mobile_order

from df4
group by utm_source

/*Can you weekly session volume for gsearch and bsearch nonbrand ,
broken down by device,since November 4th?email(December 22,2012)*/


create view d1 as
select website_session_id,created_at,utm_source,device_type,convert(date,DATEADD(DD,-(CHOOSE(DATEPART(dw, created_at), 1,2,3,4,5,6,0)),created_at)) AS WeekStartDate from website_session
where created_at<'2012-12-22' and created_at>'2012-11-04' and utm_source in ('gsearch','bsearch') and utm_campaign='nonbrand'

select WeekStartDate,
count(website_session_id) as total_session_per_week,
count(case when utm_source='gsearch' and device_type='mobile' then website_session_id else null end) as gsearch_mobile,
count(case when utm_source='gsearch' and device_type='desktop' then website_session_id else null end) as gsearch_desktop,
count(case when utm_source='bsearch' and device_type='mobile' then website_session_id else null end) as bsearch_mobile,
count(case when utm_source='bsearch' and device_type='desktop' then website_session_id else null end) as bsearch_desktop
from d1
group by WeekStartDate


/*Could you pull organic search ,direct type in,and paid brand search sessions by month?email(December 23,2012)*/


create view d2 as 
select website_session_id,month(created_at) as month_number ,utm_source,utm_campaign,http_referer from website_session
where created_at<'2012-12-23'

create view d3 as 
select month_number,
case
when utm_source is null  and http_referer   in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search'
when utm_source is  null and http_referer is null  then   'direct_type_in'
when utm_campaign='nonbrand' then 'paid_nonbrand'
when utm_campaign='brand' then 'paid_brand'
end as segment
from d2

select month_number,
sum(case  when segment='paid_nonbrand' then 1 else 0 end)  as nonbrand,
sum(case  when segment='paid_brand' then 1 else 0 end) as brand ,
sum(case  when segment='direct_type_in' then 1 else 0 end) as direct,
sum(case  when segment='organic_search' then 1 else 0 end) as organic
from d3
group by month_number
order by month_number