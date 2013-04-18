#!/bin/bash

filename="$1"

for name in $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var/struct/var[@name='NAME']/string" ${filename}); do
  echo "  - name: $name"
  echo "    user: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='username']/string" ${filename})"
  cryptpass=$(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='password']/string" ${filename})
  echo "    cryptedpassword: $cryptpass"
  driver=$(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='DRIVER']/string" ${filename})
  if echo $driver | grep -qi "MSSQL"; then
    echo "    driver: mssql"
    echo "    host: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='host']/string" ${filename})"
    echo "    port: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='port']/string" ${filename})"
    echo "    database: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='database']/string" ${filename})"
  elif [ "$driver" == "Oracle JDBC Driver" ]; then
    echo "    driver: oracle"
    echo "    uri: !str \"$(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='url']/string" ${filename} | sed 's/ //g')\""
  elif [ "$driver" == "Oracle" ]; then
    echo "    driver: oracle-cf"
    echo "    host: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='host']/string" ${filename})"
    echo "    port: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='port']/string" ${filename})"
    echo "    database: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='SID']/string" ${filename})"
  else
    echo "    driver: $driver"
    echo "    host: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='host']/string" ${filename})"
    echo "    port: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='port']/string" ${filename})"
    echo "    database: $(xmlstarlet sel -t -v "//wddxPacket/data/array/struct/var[@name='${name}']/struct/var[@name='urlmap']/struct/var[@name='database']/string" ${filename})"
  fi
done

