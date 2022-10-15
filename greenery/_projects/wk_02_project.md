## Week 02 Homework

<br>

# Part 1. Models

We were approached by the marketing team to answer some questions about Greenery’s users! 
- Use your staging models you created in Week 1 to answer their questions:

<br>

### SECTION 01

What is our user repeat rate? **79.8% of users are repeat customers**
- Repeat Rate = Users who purchased 2 or more times / users who purchased

    ```sql
    -- cte
    with repeat_customers_flagged as (
        
        -- flag repeat customers
        select distinct
            user_guid
            , case when count(order_guid) over(partition by user_guid) > 1 then 1
                else 0
            end as repeat_customer
        from stg_postgres__orders
    )

    -- calculate metric
    select sum(repeat_customer) / count(user_guid) as repeat_rate
    from repeat_customers_flagged
    ```

<br>

### SECTION 02

What are good indicators of a user who will likely purchase again? 
- repeat customers are probably more likely to purchase again
- big spenders, big baskets, email-subscribers, promo-shoppers

What about indicators of users who are likely NOT to purchase again? 
- days since last purchase is high
- did not sign up for emails, purchased as guest
- low spend, small baskets, promo-shoppers

If you had more data, what features would you want to look into to answer this question?
- email-subscriber list, guest-purchase flag
- platform they signed up on, gift-purchase flag, NPS scores

<br>

### SECTION 03

More stakeholders are coming to us for data, which is great! But we need to get some more models created before we can help. 

**Create a marts folder,** so we can organize our models, with the following subfolders for business units (DONE):
1. Core
2. Marketing
3. Product

<br>

### SECTION 04

Within each marts folder, create intermediate models and dimension/fact models.

**NOTE:** think about what metrics might be particularly useful for these business units, and build dbt models using greenery’s data
- For example, some “core” datasets could include fact_orders, dim_products, and dim_users

- The marketing mart could contain a model like user_order_facts which contains order information at the user level

- The product mart could contain a model like fact_page_views which contains all page view events from greenery’s events data

Explain the marts models you added. Why did you organize the models in the way you did?
- **answer:** ...


<br>

### SECTION 05

Use the dbt docs to visualize your model DAGs to ensure the model layers make sense

Paste in an image of your DAG from the docs. These commands will help you see the full DAG
- dbt docs generate 
- dbt docs serve --no-browser