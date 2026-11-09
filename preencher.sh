#!/usr/bin/env bash
# Troca os dados de contato e o domínio em todos os arquivos do site, e recusa se sobrar algum PREENCHER.
# Uso: ./preencher.sh 5562XXXXXXXXX voce@exemplo.com seu-dominio.com.br
set -euo pipefail
whats="${1:?WhatsApp com DDI e DDD, só números, ex.: 5562999990001}"
email="${2:?e-mail de contato}"
dominio="${3:?domínio sem https://, ex.: paulorodrigues.dev}"
[[ "$whats" =~ ^55[1-9][0-9]9?[0-9]{8}$ ]] || { echo "WhatsApp inválido: $whats" >&2; exit 1; }
sed -i "s/PREENCHER_WHATSAPP/$whats/g; s/PREENCHER_EMAIL/$email/g; s/PREENCHER_DOMINIO/$dominio/g" index.html robots.txt sitemap.xml
if grep -n PREENCHER index.html robots.txt sitemap.xml; then echo "ainda falta preencher" >&2; exit 1; fi
echo ok
