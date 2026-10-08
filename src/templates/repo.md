{% set title = "Pixel - " ~ repo.name %}
{% set page_content %}

{% include "repo-nav.md" %}

{% if repo.readme %}
{{ repo.readme }}
{% else %}
No README.
{% endif %}

{% endset %}

{% include "layout.md" %}
