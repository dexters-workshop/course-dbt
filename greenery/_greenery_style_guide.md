
# Greenery Style Guide

At Greenery, we adhere to dbt recommendations and best-practices for how to structure our dbt-project (most text in this style guide is directly from dbt-docs from the dbt-labs website - minor tweaks as needed)

As we grow at Greenery, we will evolve our best-practices and our overall style-guide. For now we will follow dbt recommendations VERY closely and they can be found here:
- [dbt Best practice guides for structuring dbt-projects](https://docs.getdbt.com/guides/best-practices)


### Someday/Maybe
- update style-guide with our own directory tree and our own sql examples.

<br>

## Section Links
[How do I structure YAML files in Model Directories](#how-do-i-structure-yaml-files-in-model-directories)

[How do I structure Files and Folders for Staging Models](#how-do-i-structure-files-and-folders-for-staging-models)

[How do I structure Staging Models for Source Data](#how-do-i-structure-staging-models-for-source-data)


---

<br>

## How do I structure YAML files in Model Directories?

**Config per folder.** As in the example above, create a `_[directory]__models.yml` per directory in your models folder that configures all the models in that directory. for staging folders, also include a `_[directory]__sources.yml` per directory.
  - The leading underscore ensure your YAML files will be sorted to the top of every folder to make them easy to separate from your models.
  
  - YAML files don’t need unique names in the way that SQL model files do, but including the directory (instead of simply `_sources.yml` in each folder), means you can fuzzy find for the right file more quickly.

  - If you utilize [doc blocks](https://docs.getdbt.com/docs/building-a-dbt-project/documentation#using-docs-blocks) in your project, we recommend following the same pattern, and creating a `_[directory]__docs.md` markdown file per directory containing all your doc blocks for that folder of models.

<br>

## How do I structure Files and Folders for Staging Models?

Here at Greenery we will follow the dbt example for how to structure our staging directory (example from dbt-project example, Jaffle Shop)


```markdown
models/staging
├── jaffle_shop
│   ├── _jaffle_shop__docs.md
│   ├── _jaffle_shop__models.yml
│   ├── _jaffle_shop__sources.yml
│   ├── base
│   │   ├── base_jaffle_shop__customers.sql
│   │   └── base_jaffle_shop__deleted_customers.sql
│   ├── stg_jaffle_shop__customers.sql
│   └── stg_jaffle_shop__orders.sql
└── stripe
    ├── _stripe__models.yml
    ├── _stripe__sources.yml
    └── stg_stripe__payments.sql
```

- **Folders (direct from dbt):** Folder structure is extremely important in dbt. Not only do we need a consistent structure to find our way around the codebase, as with any software project, but our folder structure is also one of the key interfaces into understanding the knowledge graph encoded in our project (alongside the DAG and the data output into our warehouse). It should reflect how the data flows, step-by-step, from a wide variety of source-conformed models into fewer, richer business-conformed models. Moreover, we can use our folder structure as a means of selection in dbt [selector syntax](https://docs.getdbt.com/reference/node-selection/syntax). For example, with the above structure, if we got fresh Stripe data loaded and wanted to run all the models that build on our Stripe data, we can easily run `dbt build --select staging.stripe+` and we’re all set building more up-to-date reports on payments.

  - ✅ **Subdirectories based on the source system**. Our internal transactional database (jaffle_shop) is one system, the data we get from Stripe's API is another. We've found this to be the best grouping for most companies, as source systems tend to share similar loading methods and properties between tables, and this allows us to operate on those similar sets easily.
  
  - ❌ **Subdirectories based on loader.** Some people attempt to group by how the data is loaded (Fivetran, Stitch, custom syncs), but this is too broad to be useful on a project of any real size.
  
  - ❌ **Subdirectories based on business grouping.** Another approach we recommend against is splitting up by business groupings in the staging layer, and creating subdirectories like 'marketing', 'finance', etc. A key goal of any great dbt project should be establishing a single source of truth. By breaking things up too early, we open ourselves up to create overlap and conflicting definitions (think marketing and financing having different fundamental tables for orders). We want everybody to be building with the same set of atoms, so in our experience, starting our transformations with our staging structure reflecting the source system structures is the best level of grouping for this step.

<br>

- **File names.** Creating a consistent pattern of file naming is [crucial in dbt](https://docs.getdbt.com/blog/on-the-importance-of-naming). File names must be unique and correspond the name of the model when selected and created in the warehouse. We recommend putting as much clear information into the file name as possible, including a prefix for the layer the model exists in, important grouping information, and specific information about the entity or transformation in the model.

  - ✅ `stg_[source]__[entity]s.sql` -  the double underscore between source system and entity helps visually distinguish the separate parts in the case of a source name having multiple words. For instance, `google_analytics__campaigns` is always understandable, whereas to somebody unfamiliar `google_analytics_campaigns` could be `analytics_campaigns` from the `google` source system as easily as `campaigns` from the `google_analytics` source system. Think of it like an [oxford comma](https://www.youtube.com/watch?v=P_i1xk07o4g), the extra clarity is very much worth the extra punctuation.
  
  - ❌ `stg_[entity].sql` - might be specific enough at first, but will break down in time. Adding the source system into the file name aids in discoverability, and allows understanding where a component model came from even if you aren't looking at the file tree.
  
  - ✅ **Plural.** SQL, and particularly SQL in dbt, should read as much like prose as we can achieve. We want to lean into the broad clarity and declarative nature of SQL when possible. As such, unless there’s a single order in your `orders` table, plural is the correct way to describe what is in a table with multiple rows.

  <br>

## How do I structure Staging Models for Source Data?

Now that we’ve got a feel for how the files and folders fit together, let’s look inside one of these files and dig into what makes for a **well-structured staging model.**

Below, is an example of a standard staging model (from our `stg_stripe__payments` model) that illustrates the common patterns within the staging layer. We’ve organized our model into two <Term id='cte'>CTEs</Term>: one pulling in a source table via the [source macro](https://docs.getdbt.com/docs/building-a-dbt-project/using-sources#selecting-from-a-source) and the other applying our transformations.

While our later layers of transformation will vary greatly from model to model, every one of our staging models will follow this exact same pattern. As such, we need to make sure the pattern we’ve established is rock solid and consistent.

```sql
-- stg_stripe__payments.sql

with

source as (

    select * from {{ source('stripe','payment') }}

),

renamed as (

    select
        -- ids
        id as payment_id,
        orderid as order_id,

        -- strings
        paymentmethod as payment_method,
        case
            when payment_method in ('stripe', 'paypal', 'credit_card', 'gift_card') then 'credit'
            else 'cash'
        end as payment_type,
        status,

        -- numerics
        amount as amount_cents,
        amount / 100.0 as amount,
        
        -- booleans
        case
            when status = 'successful' then true
            else false
        end as is_completed_payment,

        -- dates
        date_trunc('day', created) as created_date,

        -- timestamps
        created::timestamp_ltz as created_at

    from source

)

select * from renamed
```

- Based on the above, the most standard types of staging model transformations are:
  - ✅ **Renaming**
  - ✅ **Type casting**
  - ✅ **Basic computations** (e.g. cents to dollars)
  - ✅ **Categorizing** (using conditional logic to group values into buckets or booleans, such as in the `case when` statements above)
  - ❌ **Joins** — the goal of staging models is to clean and prepare individual source conformed concepts for downstream usage. We're creating the most useful version of a source system table, which we can use as a new modular component for our project. In our experience, joins are almost always a bad idea here — they create immediate duplicated computation and confusing relationships that ripple downstream — there are occasionally exceptions though (see [base models](guides/best-practices/how-we-structure/2-staging#staging-other-considerations) below).
  - ❌ **Aggregations** — aggregations entail grouping, and we're not doing that at this stage. Remember - staging models are your place to create the building blocks you’ll use all throughout the rest of your project — if we start changing the grain of our tables by grouping in this layer, we’ll lose access to source data that we’ll likely need at some point. We just want to get our individual concepts cleaned and ready for use, and will handle aggregating values downstream.
- ✅ **Materialized as views.** Looking at a partial view of our `dbt_project.yml` below, we can see that we’ve configured the entire staging directory to be materialized as <Term id='view'>views</Term>.  As they’re not intended to be final artifacts themselves, but rather building blocks for later models, staging models should typically be materialized as views for two key reasons:
  - Any downstream model (discussed more in [marts](/guides/best-practices/how-we-structure/4-marts)) referencing our staging models will always get the freshest data possible from all of the component views it’s pulling together and materializing
  - It avoids wasting space in the warehouse on models that are not intended to be queried by data consumers, and thus do not need to perform as quickly or efficiently



    ```yaml
    # dbt_project.yml
    
    models:
      jaffle_shop:
        staging:
          +materialized: view
    ```

- Staging models are the only place we'll use the [`source` macro](/docs/building-a-dbt-project/using-sources), and our **staging models should have a 1-to-1 relationship to our source tables.** That means for each source system table we’ll have a single staging model referencing it, acting as its entry point — *staging* it — for use downstream.

> **ProTip:** Don’t Repeat Yourself.
Staging models help us keep our code DRY. dbt's modular, reusable structure means we can, and should, push any transformations that we’ll always want to use for a given component model as far upstream as possible. This saves us from potentially wasting code, complexity, and compute doing the same transformation more than once. For instance, if we know we always want our monetary values as floats in dollars, but the source system is integers and cents, we want to do the division and type casting as early as possible so that we can reference it rather than redo it repeatedly downstream.

<br>

**for other considerations,** see section 'Staging: Other Considerations' at this [LINK](https://docs.getdbt.com/guides/best-practices/how-we-structure/2-staging)
