
# Greenery Style Guide

At Greenery, we adhere to dbt recommendations for how to structure our dbt-project (most text in this style guide is directly from dbt-docs from the dbt-labs website - minor tweaks as needed)

As we grow at Greenery, we will evolve our best-practices and our overall style-guide. For now we will follow dbt recommendations VERY closely and they can be found here:
- [dbt Best practice guides for structuring dbt-projects](https://docs.getdbt.com/guides/best-practices)

<br>

## Sections
- [How do I structure YAML files in Model Directories](#how-do-i-structure-yaml-files-in-model-directories)
- [How do I structure Files and Folders for Staging Models](#how-do-i-structure-files-and-folders-for-staging-models)

---

<br>

### How do I structure YAML files in Model Directories?

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