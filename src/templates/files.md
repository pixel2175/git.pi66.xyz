{% set title = "Pixel - " ~ repo.name ~ " files" %}
{% set page_content %}

{% include "repo-nav.md" %}

| File | Size |
|---|---|
{% for f in repo.files -%}
| [**{{ f.path }}**]({{ f.url }}) | {{ f.size }} |
{% endfor %}

{% endset %}

{% include "layout.md" %}
