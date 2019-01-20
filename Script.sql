drop table if exists Fct_trade

drop table if exists Dim_item

drop table if exists Dim_trader

drop table if exists Dim_broker

drop table if exists Dim_commision

drop table if exists Dim_operation

drop table if exists Dim_date

create table Dim_item (
id int(3) not null auto_increment,
name varchar(40) unique,
primary key(id)
)

create table Dim_trader (
id int(3) not null auto_increment,
name varchar(50) unique,
category varchar(40),
primary key(id)
)

create table Dim_commision (
id int(3) not null auto_increment,
commision_rate float(3,2),
primary key(id)
)

create table Dim_broker (
id int(3) not null auto_increment,
name varchar(40),
commision_id int(3),
primary key(id),
foreign key(commision_id) references Dim_commision(id) 
on update cascade on delete set null
)

create table Dim_operation (
id int(1) not null auto_increment,
name varcharacter(10) unique,
primary key(id)
)

create table Dim_date (
id int(8) not null auto_increment,
date_of date,
dow varchar(20),
year_of int(4),
primary key(id)
)

create table Fct_trade (
id int(3) not null auto_increment,
item_id int(3),
trader_id int(3), 
broker_id int(3),
operation_id int(1),
date_id int(8),
quantity int(3), 
price int(4),
primary key(id),
foreign key(item_id) references Dim_item(id)
on update cascade on delete set null,
foreign key(trader_id) references Dim_trader(id)
on update cascade on delete set null,
foreign key(broker_id) references Dim_broker(id)
on update cascade on delete set null,
foreign key(operation_id) references Dim_operation(id)
on update cascade on delete set null,
foreign key(date_id) references Dim_date(id)
on update cascade on delete set null
)

insert into dim_trader (name, category) values 
('Oracle', 'Corp'),
('Microsoft', 'Corp'),
('IBM', 'Corp'),
('Apple', 'Corp'),
('McDonalds', 'Small'),
('BurgerKing', 'Small'),
('KFC', 'Small'),
('Joe', 'Private'),
('Ben', 'Private'),
('Sam', 'Private')

insert into dim_operation (name) values
('buy'),
('sell')

insert into dim_commision (dim_commision.commision_rate) values
(0.95),
(1.40),
(5.20),
(3.75),
(4.10),
(8.08),
(2.25),
(6.10),
(7.77),
(9.02)

insert into dim_broker(dim_broker.name, commision_id) values
('Jane', (select id from dim_commision where dim_commision.id = 1)),
('Jack', (select id from dim_commision where dim_commision.id = 2)),
('Jude', (select id from dim_commision where dim_commision.id = 3)),
('Bill', (select id from dim_commision where dim_commision.id = 4)),
('Sally', (select id from dim_commision where dim_commision.id = 5)),
('Sandy', (select id from dim_commision where dim_commision.id = 6)),
('Sarah', (select id from dim_commision where dim_commision.id = 7)),
('Marcus', (select id from dim_commision where dim_commision.id = 8)),
('Thomas', (select id from dim_commision where dim_commision.id = 9)),
('Ann', (select id from dim_commision where dim_commision.id = 10))

insert into dim_item (dim_item.name) values
('Nokia'),
('Samsung'),
('Apple'),
('Intel'),
('AMD'),
('Nvidia'),
('Sony'),
('Microsoft'),
('Huawei'),
('Tesla')

/* Generate random dates for the last 5 years */
insert into dim_date(date_of, dow, year_of) values
((select now() - interval floor(rand() * 1825) day), dayname(date_of) , year(date_of))

/* Create random trade operations in random order */
insert into fct_trade (item_id, trader_id, broker_id, operation_id, date_id, quantity, price) 
values
((select dim_item.id from dim_item order by rand() limit 1), 
(select dim_trader.id from dim_trader order by rand() limit 1),
(select dim_broker.id from dim_broker order by rand() limit 1),
(select dim_operation.id from dim_operation order by rand() limit 1),
(select dim_date.id from dim_date where weekday(dim_date.date_of) < 5 order by rand() limit 1),
floor(rand()*100),
floor(rand()*100))

/* Group 3 best trades per each category for year */
(select dt.category Category, dt.name Trader, ft.quantity*ft.price Total, dd.year_of
from dim_trader dt 
join fct_trade ft on ft.trader_id = dt.id
join dim_date dd on dd.id = ft.date_id
where category = 'Corp'
and dd.year_of = '2018'
order by total desc
limit 3)
union all
(select dt.category Category, dt.name Trader, ft.quantity*ft.price Total, dd.year_of
from dim_trader dt 
join fct_trade ft on ft.trader_id = dt.id
join dim_date dd on dd.id = ft.date_id
where category = 'Small'
and dd.year_of = '2018'
order by total desc
limit 3)
union all
(select dt.category Category, dt.name Trader, ft.quantity*ft.price Total, dd.year_of
from dim_trader dt 
join fct_trade ft on ft.trader_id = dt.id
join dim_date dd on dd.id = ft.date_id
where category = 'Private'
and dd.year_of = '2018'
order by total desc
limit 3)

/* Display stock sell profit/loss ratio */
select
(select name from dim_item 
join fct_trade 
on fct_trade.item_id = dim_item.id 
and fct_trade.id = 14) as 'Stock name',
(select @units := quantity 
from fct_trade where id = 14) as 'Units',
(select truncate (@sell_price := quantity/price, 2) 
from fct_trade where id = 12) as 'Sell price',
(select truncate (@buy_price := quantity/price, 2) from fct_trade where id = 21) as 'Buy price',
(select truncate (@units*(@sell_price-@buy_price), 2)) as 'Profit'