#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False
source ../shared/bash_functions.sh

Ask "Lab Domain: "
read lab_domain

Ask "Email address for Cloudflare: "
read cf_email

export CLOUDFLARE_EMAIL=$cf_email
export CLOUDFLARE_API_KEY=$(cat $HOME/.cloudflare/api_key)

export AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep aws_access_key_id | cut -d '=' -f2)
export AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep aws_secret_access_key | cut -d '=' -f2)


Warn "Configuring Cloudflare Access application..."
ansible-playbook --extra-vars "cf_domain=$lab_domain lab_domain=$lab_domain" ansible/cf_access.yml

Success "Created Cloudflare Access application..."
Warn "Cleaning bin directory..."
if [ -d './bin' ]; then
    rm -rf bin
fi
mkdir -p bin

Warn "Downloading Cloudflared..."
cloudflared_path=$(curl -Ls https://api.github.com/repos/cloudflare/cloudflared/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep -i 'amd64$')
curl -Lo bin/cloudflared $cloudflared_path
if [ $? -ne 0 ]; then
    Error "Failed to download cloudflared"
    exit 1
fi

if [ -f './bin/cloudflared' ]; then
    Success "Downloaded Cloudflared"
    chmod +x bin/cloudflared
else
    Error "Failed to download Cloudflared"
    exit 1
fi


Warn "Create Cloudflare tunnel certificate"
CF_CERT_PATH=/home/$USER/.cloudflared/cert.pem
OUTPUT_PATH="$(pwd)/../shared/argo.pem"
echo "Final path: $OUTPUT_PATH"
if [ ! -f "$OUTPUT_PATH" ]; then
    bin/cloudflared tunnel login
    if [ ! -f "$CF_CERT_PATH" ]; then
      Error "Failed to download certificate"
      exit 1
    fi
    mv $CF_CERT_PATH ../shared/argo.pem
fi
Success "Got Cloudflare certificate!"

Warn "Creating Argo Tunnel..."
ansible-playbook -i ansible/inventory --ask-pass -K --extra-vars "lab_domain=$lab_domain" ansible/cf_tunnel.yml
if [ $? -ne 0 ]; then
    Error "Failed to create tunnel"
    exit 1
fi
