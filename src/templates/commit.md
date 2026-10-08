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

{% if commit.body %}
<pre class="whitespace-pre-wrap">{{ commit.body }}</pre>
{% endif %}

> # **Stat**

<table class="w-full border-collapse bg-black text-base lg:text-xl !border-0">
{% for file in commit.stats.files -%}
<tr class="!border-0">
<td class="!border-0 !px-2 !py-1 whitespace-nowrap"><strong>{{ file.status }}</strong></td>
<td class="!border-0 !px-2 !py-1 w-full break-all">{{ file.name }}</td>
<td class="!border-0 !px-2 !py-1 whitespace-nowrap text-right">{{ file.total |int }}</td>
<td class="!border-0 !px-2 !py-1 whitespace-nowrap text-right"><span class="text-green-400">+{{ file.added |int }}</span></td>
<td class="!border-0 !px-2 !py-1 whitespace-nowrap text-right"><span class="text-red-400">-{{ file.removed|int }}</span></td>
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
