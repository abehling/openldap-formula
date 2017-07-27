{% from 'openldap/map.jinja' import openldap with context %}

include:
  - openldap.client
{% if openldap.server.enabled %}
  - openldap.server
{% if 'objects' in openldap %}
  - openldap.objects
{% endif %}
{% endif %}



