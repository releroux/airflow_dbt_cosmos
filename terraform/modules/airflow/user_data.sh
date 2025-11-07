#!/bin/bash
set -e

echo "----------------------------------# Update system"
sudo apt-get update -y

echo "----------------------------------# Install AWS CLI"
sudo apt-get install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

echo "----------------------------------# Install Docker"
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

echo "----------------------------------# Install Docker Compose"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "----------------------------------# Create Airflow directory structure"
sudo mkdir -p /opt/airflow/{dags,logs,plugins,config,dbt}
cd /opt/airflow

echo "----------------------------------# Create .env file"
cat > /opt/airflow/.env <<'EOF'
AIRFLOW_UID=50000
S3_DAGS_PATH=${s3_dags_path}
S3_DBT_PATH=${s3_dbt_path}
EOF

echo "----------------------------------# Copy Dockerfile for custom image with dbt"
cat > /opt/airflow/Dockerfile <<'DOCKERFILE_EOF'
${dockerfile_content}
DOCKERFILE_EOF

echo "----------------------------------# Build custom Airflow image with dbt"
cd /opt/airflow
sudo docker build -t airflow-dbt:latest .

echo "----------------------------------# Copy docker-compose.yaml"
cat > /opt/airflow/docker-compose.yaml <<'COMPOSE_EOF'
${docker_compose_content}
COMPOSE_EOF

echo "----------------------------------# Set proper permissions"
sudo chown -R 50000:50000 /opt/airflow

echo "----------------------------------# Create S3 sync script for DAGs"
sudo tee /opt/airflow/sync-dags.sh > /dev/null <<'SYNC_EOF'
#!/bin/bash
aws s3 sync ${s3_dags_path} /opt/airflow/dags/ --delete
chown -R 50000:50000 /opt/airflow/dags/
SYNC_EOF

sudo chmod +x /opt/airflow/sync-dags.sh

echo "----------------------------------# Create S3 sync script for dbt"
sudo tee /opt/airflow/sync-dbt.sh > /dev/null <<'DBT_SYNC_EOF'
#!/bin/bash
aws s3 sync ${s3_dbt_path} /opt/airflow/dbt/ --delete
chown -R 50000:50000 /opt/airflow/dbt/
DBT_SYNC_EOF

sudo chmod +x /opt/airflow/sync-dbt.sh

echo "----------------------------------# Setup cron job for DAG sync (every 30 seconds)"
# (sudo crontab -l 2>/dev/null; echo "* * * * * /opt/airflow/sync-dags.sh >> /var/log/airflow-dag-sync.log 2>&1") | sudo crontab -
(sudo crontab -l 2>/dev/null; echo "* * * * * sleep 30; /opt/airflow/sync-dags.sh >> /var/log/airflow-dag-sync.log 2>&1") | sudo crontab -

# echo "----------------------------------# Setup cron job for dbt sync (every 5 minutes)"
(sudo crontab -l 2>/dev/null; echo "* * * * * sleep 30; /opt/airflow/sync-dbt.sh >> /var/log/airflow-dbt-sync.log 2>&1") | sudo crontab -

echo "----------------------------------# Initial DAG sync from S3"
sudo /opt/airflow/sync-dags.sh

echo "----------------------------------# Initial dbt sync from S3 (if exists)"
sudo /opt/airflow/sync-dbt.sh || true

echo "----------------------------------# Initialize Airflow"
sudo docker-compose up airflow-init

echo "----------------------------------# Start Airflow services"
sudo docker-compose up -d

echo "----------------------------------# Create a systemd service for auto-restart"
sudo tee /etc/systemd/system/airflow.service > /dev/null <<'SERVICE_EOF'
[Unit]
Description=Airflow Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/airflow
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "----------------------------------# Enable and start the Airflow service"
sudo systemctl daemon-reload
sudo systemctl enable airflow.service

echo "Airflow installation complete. UI available at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Default credentials: airflow/airflow"