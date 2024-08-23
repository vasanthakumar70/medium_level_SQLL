-- 1. No of people present insite the hospital
create table hospital ( emp_id int
, action varchar(10)
, time datetime);

insert into hospital values ('1', 'in', '2019-12-22 09:00:00');
insert into hospital values ('1', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:00:00');
insert into hospital values ('2', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:30:00');
insert into hospital values ('3', 'out', '2019-12-22 09:00:00');
insert into hospital values ('3', 'in', '2019-12-22 09:15:00');
insert into hospital values ('3', 'out', '2019-12-22 09:30:00');
insert into hospital values ('3', 'in', '2019-12-22 09:45:00');
insert into hospital values ('4', 'in', '2019-12-22 09:45:00');
insert into hospital values ('5', 'out', '2019-12-22 09:40:00');

with cte as (
select  *,max(time) over (partition by emp_id) as max_time from hospital 
)
select emp_id from cte where max_time=time and action='in'

------------------------------------------------------------------------------------------------------------------------------
---- 2 .Find the room types that are searched most no of times.
-----Output the room type alongside the number of searches for it.
----Sort the result based on the number of searches in descending order.


create table airbnb_searches 
(
user_id int,
date_searched date,
filter_room_types varchar(200)
);
delete from airbnb_searches;
insert into airbnb_searches values
(1,'2022-01-01','entire home,private room')
,(2,'2022-01-02','entire home,shared room')
,(3,'2022-01-02','private room,shared room')
,(4,'2022-01-03','private room')
;

select 
    value,
    count(*) from airbnb_searches  
cross APPLY string_split(filter_room_types,',')
group by value
order by 2 desc



-- 3 .write a SQL to return all employee whose salary is same in same department
CREATE TABLE [emp_salary]
(
    [emp_id] INTEGER  NOT NULL,
    [name] NVARCHAR(20)  NOT NULL,
    [salary] NVARCHAR(30),
    [dept_id] INTEGER
);


INSERT INTO emp_salary
(emp_id, name, salary, dept_id)
VALUES(101, 'sohan', '3000', '11'),
(102, 'rohan', '4000', '12'),
(103, 'mohan', '5000', '13'),
(104, 'cat', '3000', '11'),
(105, 'suresh', '4000', '12'),
(109, 'mahesh', '7000', '12'),
(108, 'kamal', '8000', '11');


select 
    e1.emp_id
from emp_salary e1
join emp_salary e2 on e1.dept_id=e2.dept_id and e1.salary=e2.salary and e1.emp_id<>e2.emp_id
group by e1.emp_id


---4 .write a query to print highest and lowest salary emp in each deprtment

create table employee 
(
emp_name varchar(10),
dep_id int,
salary int
);
delete from employee;
insert into employee values 
('Siva',1,30000),('Ravi',2,40000),('Prasad',1,50000),('Sai',2,20000)



with cte as(
select 
    *
    ,ROW_NUMBER()over(partition by dep_id order by salary ) as low_salary
    ,ROW_NUMBER()over(partition by dep_id order by salary desc) as top_salary 
from employee 
)
select 
    distinct dep_id
    ,(select emp_name from cte c2 where top_salary=1 and  c1.dep_id= c2.dep_id) as high_salary
    ,(select emp_name from cte c2 where low_salary=1 and  c1.dep_id= c2.dep_id) as low_salary
 from cte c1



--5 .write a query to get start time and end time of each call from below 2 tables. Also create a column of call
---duration in minutes. Please do take into account that there will be multiple calls from one phone number
---and each entry in start table has a corresponding entry in end table .

 create table call_start_logs
(
phone_number varchar(10),
start_time datetime
);
insert into call_start_logs values
('PN1','2022-01-01 10:20:00'),('PN1','2022-01-01 16:25:00'),('PN2','2022-01-01 12:30:00')
,('PN3','2022-01-02 10:00:00'),('PN3','2022-01-02 12:30:00'),('PN3','2022-01-03 09:20:00')
create table call_end_logs
(
phone_number varchar(10),
end_time datetime
);
insert into call_end_logs values
('PN1','2022-01-01 10:45:00'),('PN1','2022-01-01 17:05:00'),('PN2','2022-01-01 12:55:00')
,('PN3','2022-01-02 10:20:00'),('PN3','2022-01-02 12:50:00'),('PN3','2022-01-03 09:40:00')
;


with call_start as(
select *,ROW_NUMBER() over (partition by phone_number order by start_time) as call_start from call_start_logs 
),
call_end as(
select * ,ROW_NUMBER() over (partition by phone_number order by end_time) as call_end from call_end_logs
)
select  s.phone_number,start_time,end_time,DATEDIFF(MINUTE,start_time,end_time)
from call_start s 
join call_end e on s.phone_number=e.phone_number and s.call_start=e.call_end



---6 .Condition, if Criteria1 and Criteria2 both are Y and a minimum of 2 team members, should have y then the output should be Y else N
create table Ameriprise_LLC
(
teamID varchar(2),
memberID varchar(10),
Criteria1 varchar(1),
Criteria2 varchar(1)
);
insert into Ameriprise_LLC values 
('T1','T1_mbr1','Y','Y'),
('T1','T1_mbr2','Y','Y'),
('T1','T1_mbr3','Y','Y'),
('T1','T1_mbr4','Y','Y'),
('T1','T1_mbr5','Y','N'),
('T2','T2_mbr1','Y','Y'),
('T2','T2_mbr2','Y','N'),
('T2','T2_mbr3','N','Y'),
('T2','T2_mbr4','N','N'),
('T2','T2_mbr5','N','N'),
('T3','T3_mbr1','Y','Y'),
('T3','T3_mbr2','Y','Y'),
('T3','T3_mbr3','N','Y'),
('T3','T3_mbr4','N','Y'),
('T3','T3_mbr5','Y','N');


with cte1 as
(select 
    *
    ,case when criteria1='y' and criteria2='y' then 'Y' else 'N' end as output
 from Ameriprise_LLC
),
cte2 as(
select teamid,count(*) as count
from cte1
where [output]='y'
group by teamid)
select 
    cte1.teamid
    ,memberid
    ,criteria1
    ,criteria2
    ,case when [output]='y' and count>=2 then 'y' else 'N' end as output2
 from cte1
 left join cte2 on cte1.teamid=cte2.teamID




-- 7 . Person and type is the colnmn names and it is the input tahle
-- We need oulpul as pair lable
-- Like these are adult and child in the lable ul they are goiny for a fair fuid they have a ride on some jhooln, so one adult ean go ith one chihfand in last one adult will be alone
-- Any solution ftt this question

create table family 
(
person varchar(5),
type varchar(10),
age int
);
delete from family ;
insert into family values ('A1','Adult',54)
,('A2','Adult',53),('A3','Adult',52),('A4','Adult',58),('A5','Adult',54),('C1','Child',20),('C2','Child',19),('C3','Child',22),('C4','Child',15);


with cte as (
select *,ROW_NUMBER()over(partition by type order by type)  rn from family
)
select c1.person,c2.person
from cte c1
left join cte c2 on c1.rn=c2.rn and c1.type<>c2.type
where c1.type='adult'

with cte1 as (
select *,
ROW_NUMBER()over(partition by type order by age desc)  rn from family
where type='adult'
),
 cte2 as (
select *,
ROW_NUMBER()over(partition by type order by age)  rn from family
where type='child'
)
select c1.person,c2.person,c1.age,c2.age
from cte1 c1
left join cte2 c2 on c1.rn=c2.rn and c1.type<>c2.type
where c1.type='adult'

--8.   Find the company only whose revenue is increasing increasing every year.
-- Note : Suppose a company revenue is increasing for 3 years and a very next year revenue is dipped in that case it should not come in output

create table company_revenue 
(
company varchar(100),
year int,
revenue int
)

insert into company_revenue values 
('ABC1',2000,100),('ABC1',2001,110),('ABC1',2002,120),('ABC2',2000,100),('ABC2',2001,90),('ABC2',2002,120)
,('ABC3',2000,500),('ABC3',2001,400),('ABC3',2002,600),('ABC3',2003,800);


with cte as
(select 
    *
    ,lag(revenue,1,0)over (partition by company order by year) last_year
 from company_revenue ),
 cte2 as
 (select 
     *
     ,case when revenue-last_year<0 then 'N' else 'Y' end as flag
     ,count(*)over(partition by company) as year_count
  from cte)
  select 
    company,
    year_count,
    count(*) as count
from cte2
where flag='y'
group by 
    company,
    year_count
having year_count=count(*)


-- 9 .Write a query that prints the names of a child and his parents in individual columns respectively in
-- order of the name of the child.



create table people
(id int primary key not null,
 name varchar(20),
 gender char(2));

create table relations
(
    c_id int,
    p_id int,
    FOREIGN KEY (c_id) REFERENCES people(id),
    foreign key (p_id) references people(id)
);

insert into people (id, name, gender)
values
    (107,'Days','F'),
    (145,'Hawbaker','M'),
    (155,'Hansel','F'),
    (202,'Blackston','M'),
    (227,'Criss','F'),
    (278,'Keffer','M'),
    (305,'Canty','M'),
    (329,'Mozingo','M'),
    (425,'Nolf','M'),
    (534,'Waugh','M'),
    (586,'Tong','M'),
    (618,'Dimartino','M'),
    (747,'Beane','M'),
    (878,'Chatmon','F'),
    (904,'Hansard','F');

insert into relations(c_id, p_id)
values
    (145, 202),
    (145, 107),
    (278,305),
    (278,155),
    (329, 425),
    (329,227),
    (534,586),
    (534,878),
    (618,747),
    (618,904);




    with cte as(
select 
    c.id as child_id ,
    c.name as child_name,
    p.id as parent_id ,
    p.name as parent_name,
    p.gender
from relations r 
left join people c on r.c_id=c.id 
left join people p on r.p_id=p.id )
select 

    child_name
    ,max(case when gender='f' then parent_name end) as father_name
    ,max(case when gender='m' then parent_name end) as mother_name

from cte
group by child_name


--- 10 .cricket points table 

create table icc_world_cup
(
match_no int,
team_1 Varchar(20),
team_2 Varchar(20),
winner Varchar(20)
);
INSERT INTO icc_world_cup values(1,'ENG','NZ','NZ');
INSERT INTO icc_world_cup values(2,'PAK','NED','PAK');
INSERT INTO icc_world_cup values(3,'AFG','BAN','BAN');
INSERT INTO icc_world_cup values(4,'SA','SL','SA');
INSERT INTO icc_world_cup values(5,'AUS','IND','IND');
INSERT INTO icc_world_cup values(6,'NZ','NED','NZ');
INSERT INTO icc_world_cup values(7,'ENG','BAN','ENG');
INSERT INTO icc_world_cup values(8,'SL','PAK','PAK');
INSERT INTO icc_world_cup values(9,'AFG','IND','IND');
INSERT INTO icc_world_cup values(10,'SA','AUS','SA');
INSERT INTO icc_world_cup values(11,'BAN','NZ','NZ');
INSERT INTO icc_world_cup values(12,'PAK','IND','IND');
INSERT INTO icc_world_cup values(12,'SA','IND','DRAW');


with cte as(
select match_no,team_1,team_2,winner from icc_world_cup
union all
select match_no,team_2 ,team_1,winner from icc_world_cup)
select 
    team_1
    ,count(*) as match_played
    ,sum(case when winner=team_1 and winner<>'draw' then 1 else 0 end ) as match_win
    ,count(*) -sum(case when winner=team_1  then 1 
                        when winner='draw' then 1  else 0 end ) as match_loss
    ,sum(case when winner=team_1 then 1 else 0 end ) * 2 as points
from cte
group by team_1 
order by 5  desc


---11 . find orgin and destinaton
CREATE TABLE flights 
(
    cid VARCHAR(512),
    fid VARCHAR(512),
    origin VARCHAR(512),
    Destination VARCHAR(512)
);

INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f1', 'Del', 'Hyd');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('1', 'f2', 'Hyd', 'Blr');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f3', 'Mum', 'Agra');
INSERT INTO flights (cid, fid, origin, Destination) VALUES ('2', 'f4', 'Agra', 'Kol');

select f1.cid,f1.origin,f2.destination
from flights f1
join flights f2 on f1.Destination=f2.origin and f1.cid=f2.cid


---12 . new customer in each month

CREATE TABLE sales 
(
    order_date date,
    customer VARCHAR(512),
    qty INT
);

INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C1', '20');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-01-01', 'C2', '30');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C1', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-02-01', 'C3', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C5', '19');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-03-01', 'C4', '10');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C3', '13');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C5', '15');
INSERT INTO sales (order_date, customer, qty) VALUES ('2021-04-01', 'C6', '10');


with cte as (
select 
    *
    ,case when order_date=FIRST_VALUE(order_date)over(partition by customer order by order_date) then 1 else 0 end as flag
from sales
)
select order_date,sum(flag) from cte 
group by order_date




-- 13 . new in source , target , mimatch

create table source(id int, name varchar(5))

create table target(id int, name varchar(5))

insert into source values(1,'A'),(2,'B'),(3,'C'),(4,'D')

insert into target values(1,'A'),(2,'B'),(4,'X'),(5,'F');



select 
    isnull(s.id,t.id)
    ,case when t.name is null then 'new in source'
            when t.name<>s.name then ' mismatch'
            when s.name is null then 'new in target'
            end as name
    
from source s
full outer join target t on s.id=t.id 
where isnull(s.name,0)<>isnull(t.name,1)



----14 . find the words which are repeating more than once considering all the rows of content column

create table namaste_python (
file_name varchar(25),
content varchar(200)
);


insert into namaste_python values ('python bootcamp1.txt','python for data analytics 0 to hero bootcamp starting on Jan 6th')
,('python bootcamp2.txt','classes will be held on weekends from 11am to 1 pm for 5-6 weeks')
,('python bootcamp3.txt','use code NY2024 to get 33 percent off. You can register from namaste sql website. Link in pinned comment')

select value,count(*) from namaste_python
cross APPLY string_split(content,' ')
GROUP by value 
having COUNT(*)>1
order by 2 desc



----15. average rating in star

CREATE TABLE movies (
    id INT PRIMARY KEY,
    genre VARCHAR(50),
    title VARCHAR(100)
);

-- Create reviews table
CREATE TABLE reviews (
    movie_id INT,
    rating DECIMAL(3,1),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

-- Insert sample data into movies table
INSERT INTO movies (id, genre, title) VALUES
(1, 'Action', 'The Dark Knight'),
(2, 'Action', 'Avengers: Infinity War'),
(3, 'Action', 'Gladiator'),
(4, 'Action', 'Die Hard'),
(5, 'Action', 'Mad Max: Fury Road'),
(6, 'Drama', 'The Shawshank Redemption'),
(7, 'Drama', 'Forrest Gump'),
(8, 'Drama', 'The Godfather'),
(9, 'Drama', 'Schindler''s List'),
(10, 'Drama', 'Fight Club'),
(11, 'Comedy', 'The Hangover'),
(12, 'Comedy', 'Superbad'),
(13, 'Comedy', 'Dumb and Dumber'),
(14, 'Comedy', 'Bridesmaids'),
(15, 'Comedy', 'Anchorman: The Legend of Ron Burgundy');

-- Insert sample data into reviews table
INSERT INTO reviews (movie_id, rating) VALUES
(1, 4.5),
(1, 4.0),
(1, 5.0),
(2, 4.2),
(2, 4.8),
(2, 3.9),
(3, 4.6),
(3, 3.8),
(3, 4.3),
(4, 4.1),
(4, 3.7),
(4, 4.4),
(5, 3.9),
(5, 4.5),
(5, 4.2),
(6, 4.8),
(6, 4.7),
(6, 4.9),
(7, 4.6),
(7, 4.9),
(7, 4.3),
(8, 4.9),
(8, 5.0),
(8, 4.8),
(9, 4.7),
(9, 4.9),
(9, 4.5),
(10, 4.6),
(10, 4.3),
(10, 4.7),
(11, 3.9),
(11, 4.0),
(11, 3.5),
(12, 3.7),
(12, 3.8),
(12, 4.2),
(13, 3.2),
(13, 3.5),
(13, 3.8),
(14, 3.8),
(14, 4.0),
(14, 4.2),
(15, 3.9),
(15, 4.0),
(15, 4.1);



-- 16 . Write a query to print the maximum number of discounted tours any 1 family in the FAMILIES
-- table can choose from.
CREATE TABLE FAMILIES (
    ID VARCHAR(50),
    NAME VARCHAR(50),
    FAMILY_SIZE INT
);

-- Insert data into FAMILIES table
INSERT INTO FAMILIES (ID, NAME, FAMILY_SIZE)
VALUES 
    ('c00dac11bde74750b4d207b9c182a85f', 'Alex Thomas', 9),
    ('eb6f2d3426694667ae3e79d6274114a4', 'Chris Gray', 2),
  ('3f7b5b8e835d4e1c8b3e12e964a741f3', 'Emily Johnson', 4),
    ('9a345b079d9f4d3cafb2d4c11d20f8ce', 'Michael Brown', 6),
    ('e0a5f57516024de2a231d09de2cbe9d1', 'Jessica Wilson', 3);

-- Create COUNTRIES table
CREATE TABLE COUNTRIES (
    ID VARCHAR(50),
    NAME VARCHAR(50),
    MIN_SIZE INT,
 MAX_SIZE INT
);

INSERT INTO COUNTRIES (ID, NAME, MIN_SIZE,MAX_SIZE)
VALUES 
    ('023fd23615bd4ff4b2ae0a13ed7efec9', 'Bolivia', 2 , 4),
    ('be247f73de0f4b2d810367cb26941fb9', 'Cook Islands', 4,8),
    ('3e85ab80a6f84ef3b9068b21dbcc54b3', 'Brazil', 4,7),
    ('e571e164152c4f7c8413e2734f67b146', 'Australia', 5,9),
    ('f35a7bb7d44342f7a8a42a53115294a8', 'Canada', 3,5),
    ('a1b5a4b5fc5f46f891d9040566a78f27', 'Japan', 10,12);


    select top 1 f.name,COUNT(*)
from COUNTRIES C 
join FAMILIES f on f.FAMILY_SIZE BETWEEN c.MIN_SIZE and c.MAX_SIZE
group by f.name
order by 2 desc



--17 . /*write a query to find busiest route along with total ticket count
-- oneway_round ='0' -> One Way Trip
-- oneway_round ='R' -> Round Trip
-- Note: DEL -> BOM is different route from BOM -> DEL*/

CREATE TABLE tickets (
    airline_number VARCHAR(10),
    origin VARCHAR(3),
    destination VARCHAR(3),
    oneway_round CHAR(1),
    ticket_count INT
);


INSERT INTO tickets (airline_number, origin, destination, oneway_round, ticket_count)
VALUES
    ('DEF456', 'BOM', 'DEL', 'O', 150),
    ('GHI789', 'DEL', 'BOM', 'R', 50),
    ('JKL012', 'BOM', 'DEL', 'R', 75),
    ('MNO345', 'DEL', 'NYC', 'O', 200),
    ('PQR678', 'NYC', 'DEL', 'O', 180),
    ('STU901', 'NYC', 'DEL', 'R', 60),
    ('ABC123', 'DEL', 'BOM', 'O', 100),
    ('VWX234', 'DEL', 'NYC', 'R', 90);


    with cte as(
select * from tickets
union all
select airline_number,destination,origin,oneway_round ,ticket_count from tickets where oneway_round='r'
)
select origin,destination,sum(ticket_count) from cte
group by origin,destination
order by 3 desc




---18 . max,min population
CREATE TABLE city_population (
    state VARCHAR(50),
    city VARCHAR(50),
    population INT
);

-- Insert the data
INSERT INTO city_population (state, city, population) VALUES ('haryana', 'ambala', 100);
INSERT INTO city_population (state, city, population) VALUES ('haryana', 'panipat', 200);
INSERT INTO city_population (state, city, population) VALUES ('haryana', 'gurgaon', 300);
INSERT INTO city_population (state, city, population) VALUES ('punjab', 'amritsar', 150);
INSERT INTO city_population (state, city, population) VALUES ('punjab', 'ludhiana', 400);
INSERT INTO city_population (state, city, population) VALUES ('punjab', 'jalandhar', 250);
INSERT INTO city_population (state, city, population) VALUES ('maharashtra', 'mumbai', 1000);
INSERT INTO city_population (state, city, population) VALUES ('maharashtra', 'pune', 600);
INSERT INTO city_population (state, city, population) VALUES ('maharashtra', 'nagpur', 300);
INSERT INTO city_population (state, city, population) VALUES ('karnataka', 'bangalore', 900);
INSERT INTO city_population (state, city, population) VALUES ('karnataka', 'mysore', 400);
INSERT INTO city_population (state, city, population) VALUES ('karnataka', 'mangalore', 200);


with cte as(
select *
    ,row_number()OVER(partition by state order by population ) as ascn 
     ,row_number()OVER(partition by state order by population  desc) as descn
 from city_population
)
select 
    state
    ,max(case when descn=1 then city end) as max_pupulation
    ,max(case when ascn=1 then city end) as mix_pupulation
 from cte
 group by state
