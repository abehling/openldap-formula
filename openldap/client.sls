{% from 'openldap/map.jinja' import openldap with context %}

include:
  - openldap.packages

file-client-config:
  file.managed:
    - name: {{ openldap.general.configdir }}/ldap.conf
    - source: salt://openldap/templates/ldap.conf.j2
    - template: jinja
    - user: {{ openldap.general.user }}
    - group: {{ openldap.general.group }}
    - mode: 664
    - require:
      - sls: openldap.packages
