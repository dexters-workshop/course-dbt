## Week 03 Project

<br>


## Part 1: Create new models + answer conversion rate questions

1. What is our overall conversion rate?
    - conversion rate is defined as the # of unique sessions with a purchase event / total number of unique sessions

2. What is our conversion rate by product?
    - Conversion rate by product is defined as the # of unique sessions with a purchase event of that product / total number of unique sessions that viewed that product

**bonus question:**

Why might certain products be converting at higher/lower rates than others? 
- Note: we don't actually have data to properly dig into this, but we can make some hypotheses. 

<br>

## Part 2: Create macro to simplify part of a model(s) + improve dbt-project

Think about what would improve the usability or modularity of your code by applying a macro. Large case statements, or blocks of SQL that are often repeated make great candidates. 
- Document the macro(s) using a .yml file in the macros directory.
- Note: One potential macro in our data set is aggregating event types per session. Start here as your first macro and add other macros if you want to go further.

<br>

## Part 3: Add post hook to project to apply grants to role “reporting”. 

You can use the grant macro example from this week!

To check if your grants worked you can check in the query history in the snowflake UI after your dbt run, and find the grant that ran

<br>


## Part 4: Install a package + apply one or more of the macros to your project

can be a macro or a test...

<br>

## Part 5: Show improved DAG

<br>

## Part 6: dbt Snapshots

Let's update our orders snapshot again to see how our data is changing:

1. Run the orders snapshot model using dbt snapshot and query it in snowflake to see how the data has changed since last week. 

2. Which orders changed from week 2 to week 3? 