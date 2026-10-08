{% set title = "Pixel - " ~ repo.name ~ " files" %}
{% set before_main %}

{% include "repo-nav.md" %}

{% endset  %}

{% set page_content %}


| File | Size |
|---|---|
{% for f in repo.files -%}
| [**{{ f.path }}**]({{ f.url }}) | {{ f.size }} |
{% endfor %}

{% endset %}

{% include "layout.md" %}
