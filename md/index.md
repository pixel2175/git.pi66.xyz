{% set page_content %}

#  **Repositories** [.!text-center .!text-2xl]

<table markdown=1 class="!mb-1">
<thead>
<tr>
<th>Name</th>
<th>Description</th>
<th>Owner</th>
<th>Last commit</th>
</tr>
</thead>
<tbody>

{% for repo in repos %}
<tr>
    <td> <a href="/{{repo.name|lower}}/log.html"><strong>{{ repo.name }}</strong></a> </td>
    <td class="!text-gray-400"> {{ repo.desc }}</td>
    <td class="!text-gray-400"> {{ repo.author }}</td>
    <td class="!text-gray-400"> {{ repo.last_commit_date }}</td>
</tr>

{% endfor%}

</tbody>
</table>

{% endset %}

{% include "base.html" %}
