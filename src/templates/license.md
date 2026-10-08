{% set title = "Pixel - " ~ repo.name ~ " license" %}
{% set page_content %}

{% include "repo-nav.md" %}

{% if repo.license %}
{{ repo.license }}
{% else %}
No license.
{% endif %}

{% endset %}

{% include "layout.md" %}
