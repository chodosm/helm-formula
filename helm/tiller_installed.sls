{%- from slspath + "/map.jinja" import config, constants with context %}

include:
  - .client_installed

{%- if config.tiller.install %}
install_tiller:
  cmd.run:
    - name: {{ constants.helm.cmd }} init --upgrade
    - env:
      - KUBECONFIG: {{ config.kubectl.config_file }}
    - unless: "{{ constants.helm.cmd }} version --server --short | grep -E 'Server: v{{ config.version }}(\\+|$)'"
    - require:
      - sls: {{ slspath }}.client_installed
      {%- if config.kubectl.manage_config %}
      - sls: {{ slspath }}.kubectl_configured
      {%- endif %}

wait_for_tiller:
  cmd.run:
    - name: while ! {{ constants.helm.cmd }} list; do sleep 3; done
    - timeout: 30
    - env:
      - KUBECONFIG: {{ config.kubectl.config_file }}
    - require:
      {%- if config.kubectl.manage_config %}
      - sls: {{ slspath }}.kubectl_configured
      {%- endif %}
    - onchanges:
      - cmd: install_tiller
{%- endif %}