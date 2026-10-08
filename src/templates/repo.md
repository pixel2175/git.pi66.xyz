{% set title = "Pixel - " ~ repo.name %}
{% set before_main %}

{% include "repo-nav.md" %}

{% endset  %}

{% set page_content %}


{% if repo.readme %}
{{ repo.readme }}
{% else %}
No README.
{% endif %}

{% endset %}

{% include "layout.md" %}
