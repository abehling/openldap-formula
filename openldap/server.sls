{% from 'openldap/map.jinja' import openldap with context %}

include:
  - openldap.packages
  - openldap.service
  - openldap.configuration
