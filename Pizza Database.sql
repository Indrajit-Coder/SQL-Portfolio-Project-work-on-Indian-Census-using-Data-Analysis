-- "SQL Portfolio Project work on Indian Census using Data Analysis"

select * from Project.dbo.Dataset1;

select * from Project.dbo.Dataset2;

-- Number of rows into our dataset

select count(*) from Project..Dataset1;
select count(*) from Project..Dataset2;

-- Dataset for West Bangal and Tripura

select * from Project..Dataset1 where state in ('West Bengal','Tripura');

-- Population of India

select * from Project..Dataset2;
select sum(Population) Population from Project..Dataset2;

-- Average growth

select avg(growth) from Project..Dataset1;

select state, avg(growth) avg_growth from Project..Dataset1 group by State;
select state, avg(growth) avg_growth from Project..Dataset1 group by State order by avg_growth desc; 
select state, avg(growth) avg_growth from Project..Dataset1 group by State order by avg_growth asc;

-- Average sex ratio

select state, avg(sex_ratio) avg_sex_ratio from Project..Dataset1 group by State;
select state, round(avg(sex_ratio),0) avg_sex_ratio from Project..Dataset1 group by State order by avg_sex_ratio desc;
select state, round(avg(sex_ratio),0) avg_sex_ratio from Project..Dataset1 group by State order by avg_sex_ratio asc;

-- Average literacy rate

select state, round(avg(literacy),0) avg_literacy_ratio from Project..Dataset1 group by State order by avg_literacy_ratio desc;

select state, round(avg(literacy),0) avg_literacy_ratio from Project..Dataset1
group by State having round(avg(literacy),0)>90 order by avg_literacy_ratio desc;

-- Top 3 state showing highest growth ratio

select top 3 state, avg(growth) avg_growth from Project..Dataset1 group by State order by  avg_growth desc;

-- Bottom 3 state showing lowest sex ratio

select top 3 state, round(avg(sex_ratio),0) avg_sex_ratio from Project..Dataset1 group by State order by avg_sex_ratio asc;

-- Top & Bottom 3 states in literacy state

drop table if exists #Topstates;
create table #Topstates
( state nvarchar(50),
   Topstates float )

insert into  #Topstates
select state, round(avg(literacy),0) avg_literacy_ratio from Project..Dataset1 
group by State order by avg_literacy_ratio desc;

select top 3 * from  #Topstates order by #Topstates.Topstates desc;

drop table if exists #Bottomstates;
create table #Bottomstates
( state nvarchar(50),
   Bottomstates float )

insert into  #Bottomstates
select state, round(avg(literacy),0) avg_literacy_ratio from Project..Dataset1 
group by State order by avg_literacy_ratio desc;

select top 3 * from  #Bottomstates order by #Bottomstates.Bottomstates asc;

-- Union operator

select * from (
select top 3 * from  #Topstates order by #Topstates.Topstates desc) a

union 

select * from (
select top 3 * from  #Bottomstates order by #Bottomstates.Bottomstates asc) b;

-- States starting with letter a

select * from Project..Dataset1 where lower(state) like 'a%'

select distinct state from Project..Dataset1 where lower(state) like 'a%'

select distinct state from Project..Dataset1 where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from Project..Dataset1 where lower(state) like 'a%' or lower(state) like '%d'

select distinct state from Project..Dataset1 where lower(state) like 'a%' and lower(state) like 'b%'

select distinct state from Project..Dataset1 where lower(state) like 'a%' and lower(state) like '%m'

-- Joining both table

select a.District,a.State,a.sex_ratio,b.Population from Project..Dataset1 a inner join Project..Dataset2 b on a.District = b.District;

select d.State,sum(d.Males) Total_Males,sum(d.Females) Total_Females from
(select c.District, c.State,round(c.Population/(c.sex_ratio+1),0) Males, round((c.Population*c.sex_ratio)/(c.sex_ratio+1),0) Females from  
(select a.District,a.State,a.sex_ratio/1000 sex_ratio,b.Population from Project..Dataset1 a inner join Project.. Dataset2 b on a.District=b.District) c) d
group by d.State;

-- FORMULAS
-- Females/Males = Sex_Ratio                                      .......1
-- Females + Males = Population                                   .......2
-- Females = Population-Males                                     .......3
-- (Population-Males) = (Sex_Ratio)*males                         .......4
-- Population = Males(Sex_Ratio+1)                                .......5
-- Males = Population/(Sex_Ratio+1)                               .......Males
-- Females = Population-Population/(Sex_Ratio+1)                  .......Females
-- Females = Population(1-1/(Sex_Ratio+1))                        .......Females
-- Females = (Population*(Sex_Ratio))/(Sex_Ratio+1)               .......Females]

-- Total Literacy Rate

select a.District,a.State,round(a.literacy,0) Literacy_Ratio,b.Population from Project..Dataset1 a inner join Project.. Dataset2 b on a.District=b.District

-- FORMULAS
-- Total Literacy People/Population = Literacy_Ratio
-- Total Literacy People = Literacy_Ratio*Population
-- Total Illiteracy People = (1-Literacy_Ratio)*Population

select c.State,Sum(c.Literate_People) Total_Literate_Population,Sum(c.Illiterate_People) Total_Illiterate_Population from
(select d.District, d.State, round(d.literacy_ratio*d.Population,0) Literate_People,round((1-d.literacy_ratio)*d.Population,0) Illiterate_People from 
(select a.District,a.State,a.literacy/100 literacy_ratio,b.Population from Project..Dataset1 a inner join Project..Dataset2 b on a.District=b.District) d) c
group by c.State

-- Population in Previous Census

select d.District,d.State,round(d.Population/(1+d.Growth),0) Previous_Census_Population,d.Population Current_Census_Population from
(select a.District,a.State,a.Growth/100 Growth,b.Population from Project..Dataset1 a inner join Project.. Dataset2 b on a.District=b.District) d

select sum(m.Previous_Census_Population) Previous_Census_Population,sum(m.Current_Census_Population) Current_Census_Population from(
select e.State,sum(e.Previous_Census_Population) Previous_Census_Population,sum(e.Current_Census_Population) Current_Census_Population from 
(select d.District,d.State,round(d.Population/(1+d.Growth),0) Previous_Census_Population,d.Population Current_Census_Population from
(select a.District,a.State,a.Growth/100 Growth,b.Population from Project..Dataset1 a inner join Project.. Dataset2 b on a.District=b.District) d) e
group by e.State)m

-- FORMULAS
-- Previous_Census+Growth*Previous_Census = Population
-- Previous_Census = Population/(1+Growth)

-- Population vs Area

select (g.Total_Area/g.Previous_Census_Population) as Previous_Census_Population_vs_Area ,(g.Total_Area/g.Current_Census_Population) as Current_Census_Population_vs_Area from
(select q.*,r.Total_Area from (

select '1' as keyy,n.* from
(select sum(m.Previous_Census_Population) Previous_Census_Population,sum(m.Current_Census_Population) Current_Census_Population from(
select e.State,sum(e.Previous_Census_Population) Previous_Census_Population,sum(e.Current_Census_Population) Current_Census_Population from 
(select d.District,d.State,round(d.Population/(1+d.Growth),0) Previous_Census_Population,d.Population Current_Census_Population from
(select a.District,a.State,a.Growth/100 Growth,b.Population from Project..Dataset1 a inner join Project.. Dataset2 b on a.District=b.District) d) e
group by e.State)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(Area_km2) Total_Area from Project..Dataset2)z) r on q.keyy=r.keyy)g

-- Window

Output Top 3 Districts from each State with Highest Literacy Rate

select a.* from
(select District,State,Literacy,rank() over(Partition by State Order by Literacy desc) Rank from Project..Dataset1) a

where a.Rank in (1,2,3) order by State