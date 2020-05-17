#!/bin/bash

cat > dist/conf.toml << EOL
"DbUser" = "${database_username}"
"DbPassword" = "${database_password}"
"DbName" = "${database_name}"
"DbPort" = "5432"
"DbHost" = "${database_address}"
"ListenHost" = "0.0.0.0"
"ListenPort" = "80"
EOL

# Restart to Register Changes to Service/DB
sudo systemctl restart servian # 'servian' is the name of the service (ie. servian.service)