# Setting up Hosts: https://stackoverflow.com/questions/41094864/is-it-possible-to-write-ansible-hosts-inventory-files-in-yaml
webservers:
    hosts:
        ${public_ip_of_private_server}
dbservers:
    hosts:
        ${public_ip_of_private_server}:
            db_username: ${database_username}
            db_password: ${database_password}
            db_endpoint: ${database_endpoint}