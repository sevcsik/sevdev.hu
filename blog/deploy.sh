#!/usr/bin/env bash

SSH_USERNAME="www-deploy"
DEPLOY_HOSTNAME="rn2.sevdev.hu"
PUBLIC_DOMAIN_PARENT="sandbox.sevdev.hu"
COMMIT_INFO=`git show -s --oneline`
SSH_ARGS=( "$SSH_USERNAME@$DEPLOY_HOSTNAME" )

if [ -z "$GIT_BRANCH" ]; then
	CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/[-_\\/]/-/g"`
else
	CURRENT_BRANCH=`echo $GIT_BRANCH | sed -e "s/[-_\\/]/-/g"`
fi

TARGET_HOSTNAME=$CURRENT_BRANCH.$PUBLIC_DOMAIN_PARENT

echo Deploying VirtualHost for $TARGET_HOSTNAME on $SSH_USERNAME@$DEPLOY_HOSTNAME
ssh "${SSH_ARGS[@]}" "mkdir -p /var/www/vhosts"
ssh "${SSH_ARGS[@]}" "cat > /var/www/vhosts/$TARGET_HOSTNAME.conf" <<-EOF
	<VirtualHost *>
		DocumentRoot "/var/www/$TARGET_HOSTNAME/public"
		ServerName $TARGET_HOSTNAME
		ErrorLog "/var/www/$TARGET_HOSTNAME/logs/error.log"
		TransferLog "/var/www/$TARGET_HOSTNAME/logs/access.log"
		Header set X-Commit-Info "$COMMIT_INFO"
		<Directory /var/www/$TARGET_HOSTNAME/public>
			Require all granted
		</Directory>
	</VirtualHost>
EOF

echo Deleting existing deployment
ssh "${SSH_ARGS[@]}" "rm -rv /var/www/$TARGET_HOSTNAME"

echo Deploying files to $TARGET_HOSTNAME
ssh "${SSH_ARGS[@]}" "mkdir -p /var/www/$TARGET_HOSTNAME/logs"
scp -rp result $SSH_USERNAME@$DEPLOY_HOSTNAME:/var/www/$TARGET_HOSTNAME/public
ssh "${SSH_ARGS[@]}" "chmod -R u+w /var/www/$TARGET_HOSTNAME"

echo Restarting httpd
ssh "${SSH_ARGS[@]}" "sudo systemctl reload httpd.service"

echo Deployed to http://$TARGET_HOSTNAME

