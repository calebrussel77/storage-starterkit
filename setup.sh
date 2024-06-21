#!/bin/bash

# Charger les variables d'environnement
echo "Chargement des variables d'environnement..."
source ./conf/db.env

# Mettre à jour les paquets
echo "Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

# Installer les dépendances nécessaires
echo "Désinstallation des paquets conflictuels..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Ajouter la GPG Key officielle de Docker:
echo "Ajouter la GPG Key officielle de Docker..."
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Ajouter le repertoire à APT source:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Installer Docker
echo "Installation de Docker..."
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verifier l'installation
echo "Vérification de l'installation de Docker..."
sudo docker run --rm hello-world

# Installer Docker Compose Plugin
echo "Installation de Docker Compose..."
sudo apt-get install docker-compose-plugin

# Verifier l'installation
echo "Vérification de l'installation de Docker Compose..."
docker compose version

# Configuration du pare-feu
echo "Configuration du pare-feu..."
sudo ufw allow OpenSSH
sudo ufw allow 6379/tcp    # Redis
sudo ufw allow 5432/tcp    # PostgreSQL
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 9000/tcp    # Portainer
sudo ufw allow 8000/tcp    # Portainer Agent
sudo ufw allow 9090/tcp    # Prometheus
sudo ufw allow 3000/tcp    # Grafana
sudo ufw enable

# Création du dossier de sauvegarde
echo "Création du dossier de sauvegarde..."
sudo mkdir -p $BACKUP_PATH
sudo chown ${USER}:${USER} $BACKUP_PATH

# Création des scripts de sauvegarde pour PostgreSQL
echo "Création des scripts de sauvegarde pour PostgreSQL..."
cat << 'EOF' > /usr/local/bin/backup_postgres.sh
#!/bin/bash
source ./conf/db.env
docker exec $POSTGRES_CONTAINER pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_PATH/backup_$(date +%F).sql
EOF
chmod +x /usr/local/bin/backup_postgres.sh

# Planification des sauvegardes régulières avec cron
echo "Planification des sauvegardes régulières..."
(crontab -l ; echo "0 2 * * * /usr/local/bin/backup_postgres.sh") | crontab -

# Installation de Portainer
echo "Installation de Portainer..."
docker volume create portainer_data
docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.20.3-alpine


# # Installation de Prometheus et Grafana pour la surveillance (optionnel)
# echo "Installation de Prometheus et Grafana..."
# docker network create monitoring

# # Prometheus
# docker run -d --name prometheus --network=monitoring -p 9090:9090 prom/prometheus

# # Grafana
# docker run -d --name grafana --network=monitoring -p 3000:3000 grafana/grafana

echo "Installation terminée !"

# Start Docker
echo "Lancement des services Docker..."
docker compose up -d