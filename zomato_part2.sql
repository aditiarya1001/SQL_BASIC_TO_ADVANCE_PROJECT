drop table if exists goldusers_signup;

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date);
select * from goldusers_signup;

INSERT INTO goldusers_signup(userid,gold_signup_date)
values(1,'04-06-2023');

INSERT INTO goldusers_signup(userid,gold_signup_date)
values(2,'03-05-2023')

INSERT INTO goldusers_signup(userid,gold_signup_date)
values(3,'02-04-2023'),
(4,'01-03-2023');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer);

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 


INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1.	Total amount each customer spent on zomato*/

select s.userid, sum(p.price) as total_amt_spnt from sales s inner join product p on s.product_id=p.product_id 
group by s.userid;

2.	How many days has each customer visited zomato?

select userid, count(distinct created_date) total_days_visited from sales group by userid;

3. Which was the first product purchased by each customer?

select * from 
(select *, rank() over(partition by userid order by created_date) rnk from sales) s where rnk=1; 

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select userid,count(product_id) from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid;


5. Which item was the most popular for each customer?

select * from
(select *,rank() over (partition by userid order by cnt desc) rnk from
(select userid,product_id, count(product_id) cnt from sales group by userid,product_id )a)b
where rnk=1;

6. Which item was purchased first by the customer after they became a member?

(select * from
(select a.*, rank() over(partition by userid order by created_date) rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s inner join 
goldusers_signup g on s.userid = g.userid and s.created_date >= g.gold_signup_date)a)b
where rnk=1);

7. Which item was purchased just before the customer bacame a member?

(select* from
(select a.*,rank() over(partition by userid order by created_date desc)rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s inner join 
goldusers_signup g on s.userid = g.userid and s.created_date <= g.gold_signup_date)a)b
where rnk=1);

8. What is the total orders and amount spent for each ember before they became a member?

select userid,count(created_date) total_order_purchased,sum(price) total_amount_spent from 
(select c.*,p.price from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s inner join 
goldusers_signup g on s.userid = g.userid and s.created_date <= g.gold_signup_date)c inner join product p on c.product_id = p.product_id)a
group by userid;


9. If buying each product generates points for eg 5rs=2 zomato points and each product has different purchasing for eg for p1 5rs=1 zomato point 

select f.product_id, sum(total_pts) total_earned from 
(select e.*, amt/points total_pts from
(select d.*,case  when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5
else 0 end as points from 
(select c.userid, c.product_id, sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id) c
group by userid,product_id)d)e)f group by product_id;

10.

select c.*,d.price*0,5 total_pts_earned from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s inner join 
goldusers_signup g on s.userid = g.userid and created_date <= DATEADD(year, 1, gold_signup_date))c
inner join product d on c.product_id=d.product_id;


11. rank all the transaction of the customer

select *,rank() over(partition by userid order by created_date) rnk from sales;

