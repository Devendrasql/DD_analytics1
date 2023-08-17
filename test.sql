select B.User_Email, B.List_name, B.Assignee, B.ListId, C.Assign_Phone_Count, B.Called_phone_count
from
-- This code lookup count of phone numbers "Called to Cx." against particular assignee with list id
-- and get user_email from users table with u.iD
(select pn.assignto                    as Assignee,
        cl.id                          as ListId,
        count(distinct bc.buyernumber) as Called_phone_count,
        cl.name                        as List_name,
        u.email                        as User_Email
 from buyer_calls bc
          left join calling_list cl on bc.listname = cl.name
          left join phonenumbers pn on pn.listid = cl.id and pn.phonenumber = bc.buyernumber
          left join users u on u.id = pn.assignto
 where bc.status = 'completed'
--    and bc.listname = 'Runo calls 1'
 group by pn.assignto, cl.id, u.email)
    as B
    inner join
-- This code lookup count of phone numbers "assign to" against particular assignee with list id
    (select pn.assignto AS Assignee, pn.listid AS ListId, count(pn.phonenumber) As Assign_Phone_Count
     from phonenumbers pn
              left join calling_list cl on cl.id = pn.listid
     where pn.assignto is not null
--        and pn.listid = 166 and pn.assignto=2361
     group by pn.assignto, pn.listid) as C
on B.Assignee = C.Assignee and B.ListId = C.ListId

select distinct count(c_mobile)
from sales_ecogreen
where length(c_mobile) = 10


select distinct pos_item_code, composition
from medicines
where isdeleted is false;


select *
from sales_ecogreen
where channel is not null

select distinct c_mobile, c_patient
from sales_ecogreen
where channel is not null

select se.c_mobile
     , max(se.c_patient)
     , max(se.c_br_code)                                                     as branch
     , s.city
     , string_agg(concat(se.inv_no, ' ', se.d_date, ' = ', se.c_name), ' ,') as invoiceNumber
from sales_ecogreen se
         inner join stores s on s.code = left(se.inv_no, 3)
where channel = 'secondmedic'
group by se.c_mobile, s.city;

select id, pos_item_code, tags
from medicines
where post_type ilike 'fmcg'

select *
from sales_ecogreen
where c_cat_code ilike 'fmcgpp'
  and d_date = (current_date - 1)
  and c_br_code in ('029', '031', '061', '202', '401', '409')
  and n_disc_per = 0

Select distinct us."PhoneNumber" as umang_number,
                cast(bc.datetime as date),
                bc.buyernumber,
                bc.status,
                i.invoicenoupdatetime,
                i.invoicenumber
from umangSales us
         left join buyer_calls bc on bc.buyernumber = us."PhoneNumber"
         left join indent i on i.indentnumber = bc.indentnumber
where (us."SalesDate") >= Date('2023-05-01') - 17
  AND (us."SalesDate") <= Date('2023-05-10') - 17
  AND cast(bc.datetime as DATE) >= DATE('2023-05-1')
  AND cast(bc.datetime as DATE) <= DATE('2023-05-20')


select A.SaleDate,
       count(distinct A.umang_number) as UmangNumbers,
       count(distinct B.buyernumber)  as CalledNumbers,
       count(distinct c_mobile)       as Converted
from (Select distinct us."SalesDate" as SaleDate, us."PhoneNumber" as umang_number
      from umangSales us

      where (us."SalesDate") >= Date('2023-01-01') - 17
        AND (us."SalesDate") <= Date('2023-05-20') - 17) A
         left join
     (select cast(datetime as date) as CallDate, buyernumber
      from buyer_calls
      where cast(datetime as date) >= Date('2023-01-01')
        and cast(datetime as date) <= Date('2023-05-20') + 20
        and status is not null
        and call_initiated_from ilike '%list%') B on A.umang_number = B.buyernumber
         left join (select c_mobile, inv_no
                    from sales_ecogreen
                    where c_br_code = '6'
                      and d_date >= Date('2023-01-01')
                      and d_date <= Date('2023-05-01') + 30) C
                   on A.umang_number = C.c_mobile
group by A.SaleDate


select n_disc_per,
       eff_pur_rate,
       sale_rate,
       (((sale_rate - eff_pur_rate) - (sale_rate * n_disc_per / 100)) / sale_rate * 100) as margin_per
from sales_ecogreen
where n_srno = 1705
  and c_year = 23
  and c_br_code = '1';


select *
from vendor
where city in ('Bengaluru', 'Bangalore')
  and isdeleted is false
  and paymentemail = 'anirudh@dawaadost.com,mahima.agrawal@dawaadost.com';

select *
from sales_ecogreen
where origin_branchcd not in ('006')

Select Storecode,
       c_mobile                                                                     as "PhoneNumber",
       Patient_Name                                                                 as "name",
       FF."AssignTo"                                                                as "AssignEmail",
       string_agg(Distinct Concat(FF.Medicine_Name, ' (', FF.Pack_qty, ') '), ', ') AS "Last Purchased",
       Max(Cast(BC.Last_Called_Date as Date))                                       as Last_Called_Date
FROM (Select Left(A.inv_no, 3)                                                    as Storecode,
             Max(S.Storetype)                                                     as Storetype,
             Max(S.email)                                                         as "AssignTo",
             A.c_mobile,
             Max(A.c_patient)                                                     as Patient_Name,
             A.D_date                                                             as BillingDate,
             A.c_item_code,
             Max(IE.c_item_name)                                                  as Medicine_Name,
             Sum(Case when A.c_prefix = 'L' then (-1 * A.n_qty) else A.n_qty end) as Total_Qty,
             SUM(A.pk_qty + Cast(A.loose_qty as Float) / IE.n_qty_per_box)        as Pack_qty,
             sum(A.n_taxable_amt + A.vattax)                                      as Netsales_Total,
             Sum(Case
                     when c_item_catgory not in ('FMCG', 'OTC') Then n_taxable_amt + vattax
                     Else 0 End)                                                  as Netsales_Pharma,
             Sum(Case
                     when c_item_catgory in ('FMCG', 'OTC') Then n_taxable_amt + vattax
                     Else 0 End)                                                  as Netsales_NonPharma,
             Cast('2050-10-31' as Date)                                           as Last_Called_Date
      from sales_ecogreen A
               JOIN mobile_acquisition_date_store MADS
                    ON A.c_mobile = MADS.c_mobile AND Left(A.inv_no, 3) = MADS.storeid AND
                       Date(CURRENT_DATE - INTERVAL '7 day') = MADS.acq_date
               JOIN items_ecogreen IE ON IE.c_item_code = A.c_item_code
               JOIN stores S ON S.code = Left(A.inv_no, 3)
      where Cast(A.d_date as date) = Date(CURRENT_DATE - INTERVAL '7 day')
        and MADS.acq_date = MADS.max_date
        and A.c_mobile not in (Select phonenumber from blacklist_phonenumbers)
        and A.c_mobile not in (select phonenumber from analysisblocknumbers)
        and A.is_number_verified = '1'
        and Left(A.inv_no, 3) not in ('006', '002')
      Group by Left(A.inv_no, 3), A.c_mobile, A.D_date, A.c_item_code
      Order by Left(A.inv_no, 3), Netsales_Total desc, A.c_mobile) FF
         LEFT JOIN (Select buyernumber, max(datetime) as Last_Called_Date
                    from buyer_calls
                    where call_initiated_from = 'list_call'
                    Group by buyernumber) BC ON BC.buyernumber = FF.c_mobile
Group by Storecode, Storetype, c_mobile, Patient_Name, BillingDate, "AssignTo"
having Max(Cast(BC.Last_Called_Date as Date)) is null
    or current_date - Max(Cast(BC.Last_Called_Date as Date)) >= 15


select *
from mobile_acquisition_date_store
where acq_date ! = max_date

select *
from buyer_calls

select *
from sales_ecogreen
where c_mobile in ()
group by c_mobile

select buyernumber, datetime
from buyer_calls
where buyernumber in ()

select *
from medicines
where tags ilike '%sex%'
   or name ilike '%condom%'

update medicines
set isdeleted true
where pos_item_code in ()

select pos_item_code, item_category_lock
from medicines
where isdeleted is not true store_code mobile_no last call date, last inv date

-- code for sale and sale return diff days--
select distinct c_br_code
from (select inv_no,
             c_cust_code,
             c_br_code,
             c_year,
             c_patient,
             d_date,
             ref_inv_no,
             inv_date,
             d_date - inv_date as diff
      from sales_ecogreen
      where c_prefix ilike 'L') a
where diff is null
  and c_year = 23

-- 2. more than 4 hour inv genrated it should be  >7
--                             or more than 1 day it should be >=13


--  work for following dashboard http://ddhoredash.dawaadost.com/dashboard/mapped_item
--  filter query on supp name
--  than pur table m kitne item code ese hai jo pur huye hai but map nahi hai

select timezone('Asia/Kolkata', current_timestamp - interval '24 hours');

SELECT pr.c_item_code,
       pr.supp_code,
       vm.vendormedicinename,
       vm.medicineid,
       m.name,
       vm.vendorid,
       v.supp_code
--        v.name AS supp_name
FROM vendor_medicines vm
         INNER JOIN vendor v ON vm.vendorid = v.id
         INNER JOIN medicines m ON vm.medicineid = m.id
         left join purchase_register pr ON vm.vendormedicinecode = pr.c_item_code and v.supp_code = pr.supp_code
where pr.c_item_code is not null
   or vm.medicineid is null




select*from medicines

