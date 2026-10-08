{% set title = "Pixel - " ~ repo.name ~ " license" %}
{% set before_main %}

{% include "repo-nav.md" %}

{% endset  %}

{% set page_content %}

{% if repo.license %}
{{ repo.license }}
{% else %}
No license.
{% endif %}

{% endset %}

{% include "layout.md" %}
