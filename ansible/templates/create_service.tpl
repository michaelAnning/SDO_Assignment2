[Unit]
Description=Servian Service
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/dist
ExecStart=/etc/dist/TechTestApp serve
Restart=on-failure
# Other restart options: always, on-abort, etc

# The install section is needed to use
# `systemctl enable` to start on boot
# For a user service that you want to enable
# and start automatically, use `default.target`
# For system level services, use `multi-user.target`
[Install]
WantedBy=multi-user.target
