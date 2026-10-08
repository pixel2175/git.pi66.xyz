{% set title = "Pixel - " ~ repo.name ~ " " ~ commit.short %}

{% set before_main %}

{% include "repo-nav.md" %}

{% endset  %}

{% set page_content %}


<center> 

# **{{ commit.subject }}** {class="text-xl"} 

</center>

> **Author:** {{ commit.author }}  <br>
> **Date:** {{ commit.date }}  <br>
> **commit:** {{ commit.short }}<br>
> {% for p in commit.parents %}  **parent:** [{{ p }}](/{{ repo.slug }}/commit/{{ p }}/){% endfor %} <br>

{% if commit.body %}
<pre class="whitespace-pre-wrap">{{ commit.body }}</pre>
{% endif %}

> # **Stat**

<table class="border-collapse border-spacing-2 bg-black text-xl lg:!mx-5 !border-0 [&_tr]:!border-0 [&_td]:!border-0 [&_th]:!border-0 [&_td]:!p-0 [&_td]:!leading-none">
{% for file in commit.stats.files -%}
<tr class="!border-0">
<td class="!border-0"><strong>{{ file.status }}</strong></td>
<td class="!border-0">{{ file.name }}</td>
<td class="!border-0">{{ file.total |int }}</td>
<td class="!border-0"><span class="text-green-400">+{{ file.added |int }}</span></td>
<td class="!border-0"><span class="text-red-400">-{{ file.removed|int }}</span></td>
</tr>
{% endfor %}
</table>

> # **Diff**

{% if commit.patch_rest != "" %}
<details class="group">
<summary class="cursor-pointer list-none">
<pre class="group-open:hidden overflow-x-auto text-xs m-0">{{ commit.patch_head|safe }}
...
</pre>
<span class="group-open:hidden text-lg">Show all</span>
<span class="hidden group-open:inline text-lg">Show less</span>
</summary>
<pre class="overflow-x-auto text-xs m-0">{{ commit.patch|safe }}
</pre>
</details>
{% else %}
<pre class="overflow-x-auto text-xs m-0">{{ commit.patch|safe }}</pre>
{% endif %}
{% endset %}

{% include "layout.md" %}
