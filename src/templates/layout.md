{% set metas = {"viewport": "width=device-width, initial-scale=1.0", "description": "A web interface for the pi66.xyz Git server", "author": "Pi66", "theme-color": "#000000"} %}
{% set styles = ["/static/css/style.css"] %}
{% set scripts = ["https://cdn.jsdelivr.net/npm/@tailwindcss/browser", "/static/js/script.js"] %}

{% document title=title|default("Pixel - Git") lang="en" %}
{% for name in metas %}
{% meta name=name content=metas[name] %}
{% endfor %}
{% for href in styles %}
{% style href %}
{% endfor %}
{% for src in scripts %}
{% script src %}
{% endfor %}

<header class="py-2.5 justify-between h-12 px-3 border-[#333] border flex items-center">

[![](/static/icons/lain.gif)](/)

# Pi66 {.pi66-title}

[Home](/) | [Repos](https://git.pi66.xyz) | [About](/about) | [Blog](https://blog.pi66.xyz) | [Gaza](/gaza)

</header>

<div class="main-parent flex flex-col flex-1 min-h-0 p-3 my-2 border border-[#333] overflow-hidden">
{{ before_main }}

<main class="flex-1 min-h-0 overflow-y-auto">
{{ page_content }}
</main>
</div>

<nav>

[Home](/) | [Repos](https://git.pi66.xyz) | [About](/about) | [Blog](https://blog.pi66.xyz) | [Gaza](/gaza)

</nav>

<center>

// Created by **Pi66**

// Copyright ©Pi66 2026
</center>
