{% from 'openldap/map.jinja' import openldap with context %}

service-slapd:
  service.running:
    - name: slapd
    - enable: true
    - require:
      - sls: openldap.packages
