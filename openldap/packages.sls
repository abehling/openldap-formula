{% from 'openldap/map.jinja' import openldap with context %}

pkgs-client:
  pkg.installed:
    - pkgs: {{ openldap.general.clientpkgs }}

{% if openldap.server.enabled %}
pkgs-server:
  pkg.installed:
    - pkgs: {{ openldap.general.serverpkgs }}
{% endif %}
