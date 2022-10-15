## Utilities Folder

***Note***: *idea for the utilities folder was taken from dbt-labs and the text below is theirs.*

While this is not in the staging folder, it’s useful to consider as part of our fundamental building blocks. 

The models/utilities directory is where we can keep any general purpose models that we generate from macros or based on seeds that provide tools to help us do our modeling, rather than data to model itself. 

The most common use case is a date spine generated with the dbt utils package.

