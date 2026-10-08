{% set title = "Pixel - Home" %}
{% set page_content %}

# **Repositoriess** {class="!text-center !text-3xl"}

| Repository | Description | Author | Date |
|---|---|---|---|
{% for repo in repos -%}
| [**{{ repo.name }}**](/{{ repo.name|lower }}/) | {{ repo.description }} | {{ repo.commits[0].author }} | [{{ repo.commits[0].date }}]{class="time-ago"} |
{% endfor %}

{% endset %}

{% include "layout.md" %}
