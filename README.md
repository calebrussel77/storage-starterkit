# Installation and Configuration of Docker, Redis, PostgreSQL, pgAdmin, and Monitoring Tools on Ubuntu

This guide explains how to set up Docker, Redis, PostgreSQL, pgAdmin, and monitoring tools on an Ubuntu server using an automated `setup.sh` script.

## Prerequisites

1. Ubuntu server with SSH access.
2. User account with sudo privileges.

## Installation Steps

### 1. Clone the Repository

Start by cloning this repository on your Ubuntu server:

```bash
git clone https://github.com/calebrussel77/storage-starterkit.git
cd your-repo
```

### 2. Create and Modify the .env File

Modify the environment variables located in the **conf** folder:

```env
POSTGRES_PASSWORD=your_password
POSTGRES_USER=your_user
POSTGRES_DB=your_db
PGADMIN_DEFAULT_EMAIL=user@domain.com
PGADMIN_DEFAULT_PASSWORD=your_password
```

### 3. Modify the setup.sh Script

If necessary, modify the `setup.sh` script to adjust specific configurations:

```bash
nano setup.sh
```

### 4. Make the Script Executable

Make the script executable:

```bash
chmod +x setup.sh
```

### 5. Run the Script

Run the script to install and configure all services:

```bash
./setup.sh
```

### 6. Access the Services

```bash
Portainer: Access Portainer at http://your_server_ip:9000
pgAdmin: Access pgAdmin at http://your_server_ip:80
Prometheus: Access Prometheus at http://your_server_ip:9090
Grafana: Access Grafana at http://your_server_ip:3000
```

## Useful Resources

- [Docker Documentation](https://docs.docker.com/)
- [Portainer Documentation](https://documentation.portainer.io/)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/getting-started/)

## Support

For any questions or issues, please create an issue on the GitHub repository.

Thank you for using this script! We hope it simplifies the setup of your server.