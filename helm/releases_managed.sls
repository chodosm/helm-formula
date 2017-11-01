{%- from slspath + "/map.jinja" import config, constants with context %}
{%- set releases = config.get("releases", {}) %}

include:
  - .client_installed
  - .tiller_installed
  - .kubectl_configured
  - .repos_managed

{%- for release_name, release in releases.items() %}
{%- set release_enabled = release.get('enabled', True) %}
{%- set namespace = release.get('namespace', 'default') %}
{%- set values_file = config.values_dir + "/" + release_name + ".yaml" %}

{%- if config['only'] and release_name not in config['only'] %}
{%- continue %}
{%- endif %}

{%- if release_enabled and release.get("values") %}
{{ values_file }}:
  file.managed:
    - makedirs: True
    - contents: |
        {{ release['values'] | yaml(false) | indent(8) }}
{%- else %}
{{ values_file }}:
  file.absent
{%- endif %}

{%- if release_enabled %}
{{ release_name }}_release_present:
  helm_release.present:
{%- else %}
{{ release_name }}_release_absent:
  helm_release.absent:
{%- endif %}

    - name: {{ release_name }}
    - chart_name: {{ release['chart'] }}
    - namespace: {{ namespace }}
    - kube_config: {{ config.kubectl.config_file }}
    - helm_home: {{ config.helm_home }}
    {{ constants.helm.tiller_arg }}
    {%- if release.get('version') %}
    - version: {{ release['version'] }}
    {%- endif %}
    {%- if release.get("values") %}
    - values_file: {{ values_file }}
    {%- endif %}
    - require:
      {%- if config.tiller.install %}
      - sls: {{ slspath }}.tiller_installed
      {%- endif %}
      - sls: {{ slspath }}.client_installed
      - sls: {{ slspath }}.kubectl_configured
      # 
      # note: intentionally don't fail if one or more repos fail to synchronize,
      # since there should be a local repo cache anyways.
      # 

{%- endfor %}