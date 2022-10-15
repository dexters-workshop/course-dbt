

{% test bad_zipcodes(model, column_name) %}


   select *
   from {{ model }}
   where {{ length(column_name) }} != 5


{% endtest %}