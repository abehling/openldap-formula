{% from 'openldap/map.jinja' import openldap with context %}

include:
  - openldap.client
{% if openldap.server.enabled %}
  - openldap.server
{% endif %}



