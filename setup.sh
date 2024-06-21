#!/bin/bash

set -e

# Mettre à jour les paquets
echo "Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

# Installer les dépendances nécessaires
echo "Installation des dépendances nécessaires..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common ufw -y

# Ajouter la clé GPG de Docker
echo "Ajout de la clé GPG de Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Ajouter le dépôt Docker
echo "Ajout du dépôt Docker..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Installer Docker
echo "Installation de Docker..."
sudo apt update
sudo apt install docker-ce docker-compose -y

# Démarrer et activer Docker
echo "Démarrage et activation de Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Ajouter l'utilisateur au groupe Docker
echo "Ajout de l'utilisateur au groupe Docker..."
sudo usermod -aG docker ${USER}
newgrp docker

# Configuration du pare-feu
echo "Configuration du pare-feu..."
sudo ufw allow OpenSSH
sudo ufw allow 6379/tcp
sudo ufw allow 5432/tcp
sudo ufw allow 80/tcp
sudo ufw allow 9000/tcp
sudo ufw enable

# Création des scripts de sauvegarde pour PostgreSQL
echo "Création des scripts de sauvegarde pour PostgreSQL..."
cat << 'EOF' > /usr/local/bin/backup_postgres.sh
#!/bin/bash
docker exec postgres pg_dump -U your_user your_db > /path/to/backup_$(date +%F).sql
EOF
chmod +x /usr/local/bin/backup_postgres.sh

# Planification des sauvegardes régulières avec cron
echo "Planification des sauvegardes régulières..."
(crontab -l ; echo "0 2 * * * /usr/local/bin/backup_postgres.sh") | crontab -

# Installation de Portainer
echo "Installation de Portainer..."
docker volume create portainer_data
docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Installation de Prometheus et Grafana pour la surveillance (optionnel)
# echo "Installation de Prometheus et Grafana..."
# docker network create monitoring

# # Prometheus
# docker run -d --name prometheus --network=monitoring -p 9090:9090 prom/prometheus

# # Grafana
# docker run -d --name grafana --network=monitoring -p 3000:3000 grafana/grafana

echo "Installation terminée !"

# Start Docker
echo "Lancement des services Docker..."
docker-compose up -d