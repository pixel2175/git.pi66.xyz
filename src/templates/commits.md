{% set title = "Pixel - " ~ repo.name ~ " commits" %}

{% set before_main %}

{% include "repo-nav.md" %}

{% endset  %}

{% set page_content %}


| Date | Message | Author | Files | + | - |
|---|---|---|---|---|---|
{% for c in repo.commits -%}
| {{c.date}} | <a class="!text-green-400 hover:underline" href="/{{ repo.slug }}/commit/{{ c.short }}/">{{ c.subject }}</a> | {{c.author}} | {{c.stats.files | length}} | [+{{c.stats.added | int}}]{class="!text-green-500"} | [-{{c.stats.removed | int}}]{class="!text-red-500"}
{% endfor %}

{% endset %}

{% include "layout.md" %}
