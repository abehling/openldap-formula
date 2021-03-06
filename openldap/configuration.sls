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
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.configdir }}/schema/{{ schema }}.ldif
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b "cn=schema,cn=config" dn 2>/dev/null | grep -q {{ schema }}
{% endfor %}

file-modify-default-db:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/modify_default_db.ldif
    - source: salt://openldap/templates/modify_default_db.ldif.j2
    - template: jinja

modify-default-db:
  cmd.wait:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/modify_default_db.ldif
    - watch:
      - file: file-modify-default-db
    - require:
      - file: file-modify-default-db

file-delete-access-default-db:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/delete_access_default_db.ldif
    - source: salt://openldap/templates/delete_access_default_db.ldif.j2
    - template: jinja
    - require:
      - file: ldif-config-dir
   
file-add-access-default-db:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/add_access_default_db.ldif
    - source: salt://openldap/templates/add_access_default_db.ldif.j2
    - template: jinja
    - require:
      - file: ldif-config-dir

delete-access-default-db:
  cmd.wait:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/delete_access_default_db.ldif
    - require:
      - file: file-delete-access-default-db
    - watch:
      - file: file-add-access-default-db
    - onlyif: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b "{{ openldap.server.db.configdn }}" 2>/dev/null | grep -q olcAccess

add-access-default-db:
  cmd.run:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/add_access_default_db.ldif
    - require:
      - file: file-add-access-default-db
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b "{{ openldap.server.db.configdn }}" 2>/dev/null | grep -q olcAccess

file-add-basedn-object:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/add_basedn_object.ldif
    - source: salt://openldap/templates/add_basedn_object.ldif.j2
    - template: jinja
    - require:
      - file: ldif-config-dir

file-add-manager-object:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/add_manager_object.ldif
    - source: salt://openldap/templates/add_manager_object.ldif.j2
    - template: jinja
    - require:
      - file: ldif-config-dir

add-basedn-object:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/add_basedn_object.ldif
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b "{{ openldap.server.domain.suffix }}" dn 2>/dev/null | grep -q "{{ openldap.server.domain.suffix }}"
    - require:
      - file: file-add-basedn-object

add-manager-object:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/add_manager_object.ldif
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b "{{ openldap.server.domain.rootdn }}" dn 2>/dev/null | grep -q "{{ openldap.server.domain.rootdn }}"
    - require:
      - file: file-add-manager-object

{% if openldap.server.protocols.ldaps %}

osconfig-enable-ldaps:
  file.replace:
    - name: {{ openldap.server.slapdosconfig }}
    - pattern: ^SLAPD_URLS.*$
    - repl: SLAPD_URLS="ldapi:/// ldap:/// ldaps:///"

service-slapd-restart:
  cmd.wait:
    - name: systemctl restart slapd
    - watch:
      - file: osconfig-enable-ldaps

file-modify-certs:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/modify_config_cert.ldif
    - source: salt://openldap/templates/modify_config_cert.ldif.j2
    - template: jinja

modify-certs:
  cmd.wait:
    - name: ldapmodify -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/modify_config_cert.ldif
    - watch:
      - file: file-modify-certs
    - require:
      - file: file-modify-certs

{% endif %}
