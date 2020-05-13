#!/bin/bash

cat > dist/conf.toml << EOL
"DbUser" = "${database_username}"
"DbPassword" = "${database_password}"
"DbName" = "${database_name}"
"DbPort" = "5432"
"DbHost" = "${database_endpoint}"
"ListenHost" = "0.0.0.0"
"ListenPort" = "80"
EOL

# sudo systemctl restart todo # Currently doesn't work because: 'Failed to restart todo.service: Unit not found.'