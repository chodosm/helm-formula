{%- from slspath + "/map.jinja" import config, constants with context %}

{%- if config.kubectl.manage_config %}
{{ config.kubectl.config_file }}:
  file.managed:
    - source: salt://helm/files/kubeconfig.yaml.j2
    - mode: 400
    - user: root
    - group: root
    - makedirs: true
    - template: jinja
{%- endif %}