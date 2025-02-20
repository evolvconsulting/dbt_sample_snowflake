## Sample dbt project: `dbt_sample_snowflake`

`dbt_sample_snowflake` is a sample data project based on a set of fictional data as provided by Snowflake_sample_data data share. This dbt project transforms raw data from a the data share database into a data mart with customers and orders model ready for analytics.

### What is this repo?
- A self-contained sample dbt project, useful for demostrating key operations with dbt, as well as, a few customized operations to embelish your Snowflake environment.
- A demonstration of using dbt for your project, using basic features:
    - materializations (tables, incremental, and views)
    - schemas
    - docs 
    - seeds
- A demonstration of using dbt for your project, using advanced/custom features:
    - macros
    - custom materializations (stages)
    - extended utilities (dbt tags)
    - hooks

### Running this project
To get up and running with this project:
1. Install dbt using [these instructions](https://docs.getdbt.com/docs/installation).

2. Clone this repository.

3. Change into the `dbt_sample_snowflake` directory from the command line:
```bash
$ cd dbt_sample_snowflake
```

4. Set up a profile called `dbt_sample_snowflake` to connect to a data warehouse by following [these instructions](https://docs.getdbt.com/docs/configure-your-profile) or copy the file `profiles_copy_only.yml` into your local `~users/` folder, rename to `profiles.yml`, and establish the ENV_VARs or specify your settings.  A `Dev` target and a `UAT` target is already setup in this sample profile. 

If you have access to a data warehouse, you can use those credentials – we recommend setting your [target schema](https://docs.getdbt.com/docs/configure-your-profile#section-populating-your-profile) to be a new schema (dbt will create the schema for you, as long as you have the right privileges). If you don't have access to an existing data warehouse, you can also setup a local postgres database and connect to it in your profile.

5. Ensure your profile is setup correctly from the command line:
```bash
$ dbt debug
```
> **NOTE:** If this steps fails, it might mean that you need to make small changes to the `profiles.yml` file or folder to adjust for the flavor of SQL of your target database. Definitely consider this if you are using a community-contributed adapter.

6. Load the CSVs with the demo data set. This materializes the CSVs as tables in your target schema. Note that a typical dbt project **does not require this step** since dbt assumes your raw data is already in your warehouse.
```bash
$ dbt seed
```

7. Run the models:
```bash
$ dbt run
```
- This project is configured with many tags to simplifying multiple pipelines
  - By Layer/Type:
    - `source_load` - The models in the raw schema.
    - `data_cleansing` - The models in the cleansed schema.
    - `dimensions` - The dim_customer, dim_part, and dim_supplier models in the curated schema.  Prefix with a plus (+) in dbt run tag selection to run all dependecies.
    - `facts` - The fact_order_line_item model in the curated schema.  Prefix with a plus (+) in dbt run tag selection to run all dependecies.
    - `stages` - The Snowflake internal stages using the custom materialization.
  - By Domain:
    - `customer` - The dim_customer model in the curated schema.  Prefix with a plus (+) in dbt run tag selection to run all dependecies. 
    - `supply_chain` - The dim_part and dim_supplier models in the curated schema.  Prefix with a plus (+) in dbt run tag selection to run all dependecies.
    - `orders` - The fact_order_line_item model in the curated schema.  Prefix with a plus (+) in dbt run tag selection to run all dependecies.

> **NOTE:** If this steps fails, it might mean that you need to make small changes to the SQL in the models folder to adjust for the flavor of SQL of your target database. Since this project is setup with Snowflake tags, it may be required to establish the tags and policies before running the models, see below.  Definitely consider this if you are using a community-contributed adapter.

> **NOTE:** The `dbt_project.yml` file is setup with a generic post-hook for all models to setup column tags if any are configured for a model. Since this project is setup with Snowflake tags, this can be disabled if necessary or it may be required to establish the tags and policies before running the models, see below.

8. Test the output of the models:
```bash
$ dbt test
```
- This project is configured with many tags to test uniqueness in all models:
  - `raw_uniqueness` - runs uniqueness tests on all table/view models in the raw schema
  - `cleansed_uniqueness` - runs uniqueness tests on all table/view models in the cleansed schema
  - `curated_uniqueness` - runs uniqueness tests on all table/view models in the curated schema
  - `uniqueness` - runs uniqueness tests on all table/view models in the project

9. Generate documentation for the project:
```bash
$ dbt docs generate
```

10. View the documentation for the project:
```bash
$ dbt docs serve
```

11. Create Snowflake internal stages in your database using the custom materialization:
```bash
$ dbt run -s "tag:stages"
```
> **NOTE:** all that is required is the initial settings for the internal stage (encryption, directory, etc.).  The name of the stage is derived from the file name as will other models, or from the `alias` outlined in the config for the model.

12. Create tags in your governance database database, see `dbt_tags__database` and `dbt_tags__schema` in the `dbt_project.yml` file:
```bash
$ dbt run-operation create_tags
```
> **NOTE:** the dbt variable `dbt_tags__allowed_tags` contains a list of approved tags supported within this project
For more information on dbt-tags:
- Read the [dbt-tags Getting Started](https://dbt-tags.iflambda.com/latest/getting-started.html).

13. Create masking policies in your governance database database, see `dbt_tags__database` and `dbt_tags__schema` in the `dbt_project.yml` file:
```bash
$ dbt run-operation create_masking_policies
```
For more information on dbt-tags:
- Read the [dbt-tags Getting Started](https://dbt-tags.iflambda.com/latest/getting-started.html).

14. Associate masking policies to tags in your governance database database, see `dbt_tags__database` and `dbt_tags__schema` in the `dbt_project.yml` file:
```bash
$ dbt run-operation apply_mps_to_tags
```
For more information on dbt-tags:
- Read the [dbt-tags Getting Started](https://dbt-tags.iflambda.com/latest/getting-started.html).

14. Post the dbt logs file to your internal stage to ingest into Snowflake for analysis:
```bash
$ dbt run-operation post_run_end_dbt_logs
```
    or by running:
```bash
$ dbt run-operation store_files --args '{filepath: ./logs/dbt.log, stage: log_stage/logs, schema: raw}'
```
15. Post the dbt docs files to your internal stage to enable hosting on other webserver:
```bash
$ dbt run-operation post_run_dbt_docs_content
```

---
For more information on dbt:
- Read the [introduction to dbt](https://docs.getdbt.com/docs/introduction).
- Read the [dbt viewpoint](https://docs.getdbt.com/docs/about/viewpoint).
- Join the [dbt community](http://community.getdbt.com/).
---


# About the Author - Chris Schneider
Chris specializes in helping organizations derive insights from their data ecosystems. Having spent spent many years honing his craft in Data Architecture, focusing on Microsoft and Snowflake products, Chris has transformed businesses with scalable data architectures, approachable processes, and a keen eye on data quality. Using expertise in Data Management and industry experience in Finance, Lending, and Healthcare, he has built metadata-driven frameworks and data warehouses, and ensured that users leverage the appropriate tools to drive success.