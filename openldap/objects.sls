{% from 'openldap/map.jinja' import openldap with context %}
{% for object in openldap.objects %}
ldif-{{ object }}:
  file.managed:
    - name: {{ openldap.general.ldifdir }}/{{ object }}.ldif
    - source: salt://openldap/templates/generic_object.ldif.j2
    - template: jinja
    - context:
      object: {{ openldap.objects[object] }}

ldapadd-{{ object }}:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f {{ openldap.general.ldifdir }}/{{ object }}.ldif
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -b {{ openldap.objects[object].dn }} dn 2>/dev/null | grep -q "{{ openldap.objects[object].dn }}"
    - require:
      - file: ldif-{{ object }}
{% endfor %}
