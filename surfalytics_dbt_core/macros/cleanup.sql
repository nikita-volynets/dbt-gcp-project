{% macro cleanup(schema=target.schema, database=target.database, dry_run=True) %}
  {#-
    Drops relations inside the specified schema. Use to tidy up developer sandboxes.
    Args:
      schema (str): dataset/schema name to clean (defaults to target schema)
      database (str): database/project (defaults to target database)
      dry_run (bool): if true, only prints objects; false deletes them
  -#}
  {% set relations = adapter.list_relations_without_caching(schema=schema, database=database) %}

  {% if relations | length == 0 %}
    {{ log("No relations found in " ~ database ~ "." ~ schema, info=True) }}
    {% do return(none) %}
  {% endif %}

  {% for relation in relations %}
    {{ log("Found relation " ~ relation, info=True) }}
    {% if not dry_run %}
      {{ log("Dropping " ~ relation.identifier, info=True) }}
      {% do adapter.drop_relation(relation) %}
    {% else %}
      {{ log("Dry run: skipping drop for " ~ relation.identifier, info=True) }}
    {% endif %}
  {% endfor %}
{% endmacro %}
