{% set title = "Pixel - " ~ repo.name ~ " refs" %}
{% set page_content %}

{% include "repo-nav.md" %}

### Branches

| Name | Commit | Date | Message |
|---|---|---|---|
{% for r in repo.refs.branches -%}
| {{ r.name }}{% if r.current %} (HEAD){% endif %} | [{{ r.hash }}](/{{ repo.slug }}/commit/{{ r.hash }}/) | {{ r.date }} | {{ r.subject }} |
{% endfor %}

{% if repo.refs.tags %}
### Tags

| Name | Commit | Date | Message |
|---|---|---|---|
{% for r in repo.refs.tags -%}
| {{ r.name }} | [{{ r.hash }}](/{{ repo.slug }}/commit/{{ r.hash }}/) | {{ r.date }} | {{ r.subject }} |
{% endfor %}
{% endif %}

{% endset %}

{% include "layout.md" %}
