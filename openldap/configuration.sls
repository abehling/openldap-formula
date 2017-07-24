{% from 'openldap/map.jinja' import openldap with context %}

ldif-config-dir:
  file.directory:
    - name: {{ openldap.general.ldifdir }}
    - user: {{ openldap.general.user }}
    - group: {{ openldap.general.group }}
    - mode: 770

{% for schema in openldap.server.schema %}
schema-{{ schema }}:
  cmd.run:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.configdir }}/schema/{{ schema }}.ldif
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b "cn=schema,cn=config" dn 2>/dev/null | grep -q {{ schema }}
{% endfor %}

file-modify-default-db:
  file.managed:
    - name: {{ openldap.server.ldifdir }}/modify_default_db.ldif
    - source: salt://openldap/templates/modify_default_db.ldif.j2
    - template: jinja

modify-default-db:
  cmd.wait:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.server.ldifdir }}/modify_default_db.ldif
    - watch:
      - file: file-modify-default-db
    - require:
      - file: file-modify-default-db

{% if openldap.server.protocols.ldaps %}

file-modify-certs:
  file.managed:
    - name: {{ openldap.server.ldifdir }}/modify_config_cert.ldif
    - source: salt://openldap/templates/modify_config_cert.ldif.j2
    - template: jinja

modify-certs:
  cmd.wait:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.server.ldifdir }}/modify_config_cert.ldif
    - watch:
      - file: file-modify-certs
    - require:
      - file: file-modify-certs

{% endif %}
