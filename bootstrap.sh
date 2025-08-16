#!/bin/bash
set -e

### CONFIGURACICN PERSONALIZABLE ###
APP_NAME="n8n-autodeploy"
REGION="iad"
AUTH_TOKEN="${FLY_API_TOKEN:-}"
FLOWS_DIR="./flows"
ENTRYPOINT="./entrypoint.sh"
DOCKERFILE="./Dockerfile"

### 1. Instalar flyctl si no existe ###
if ! command -v flyctl &> /dev/null; then
  echo "p
 Instalando flyctl..."
  curl -L https://fly.io/install.sh | sh
  export PATH="$HOME/.fly/bin:$PATH"
fi

### 2. AutenticaciC3n ###
if [ -z "$AUTH_TOKEN" ]; then
  echo "p  flyctl auth login
else
  echo "p  flyctl auth token "$AUTH_TOKEN"
fi

### 3. Crear app si no existe ###
if ! flyctl apps list | grep "$APP_NAME" &> /dev/null; then
  echo "p  flyctl apps create "$APP_NAME"
fi

### 4. Generar fly.toml si no existe ###
if [ ! -f fly.toml ]; then
  echo "p  flyctl launch --no-deploy --name "$APP_NAME" --region "$REGION"
fi

### 5. Configurar secretos ###
echo "pflyctl secrets set \
  N8N_BASIC_AUTH_USER=admin \
  N8N_BASIC_AUTH_PASSWORD=securepass \
  N8N_HOST=0.0.0.0 \
  N8N_PORT=5678 \
  N8N_PROTOCOL=http

### 6. Crear Dockerfile si no existe ###
if [ ! -f "$DOCKERFILE" ]; then
  echo "p  cat <<EOF > "$DOCKERFILE"
FROM n8nio/n8n:latest
COPY flows/ /app/flows/
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
EOF
fi

### 7. Crear entrypoint.sh si no existe ###
if [ ! -f "$ENTRYPOINT" ]; then
  echo "p  cat <<'EOF' > "$ENTRYPOINT"
#!/bin/bash
until curl -s http://localhost:5678/healthz | grep "ok"; do
  echo "Esperando n8n..."
  sleep 2
done
for file in /app/flows/*.json; do
  echo "Importando $file..."
  curl -s -X POST http://localhost:5678/api/workflows/import \
    -H "Content-Type: application/json" \
    --data-binary "@$file"
done
echo "Flujos importados. n8n listo."
exec n8n
EOF
chmod +x "$ENTRYPOINT"
fi

### 8. Crear carpeta de flujos si no existe ###
if [ ! -d "$FLOWS_DIR" ]; then
  echo "Creando carpeta de flujos..."
  mkdir "$FLOWS_DIR"
  echo "{}" > "$FLOWS_DIR/example.json"
fi

### 9. Desplegar app ###
echo "Desplegando app en Fly.io..."
flyctl deploy --remote-only

echo "Todo listo. Tu app $APP_NAME estC! viva y sincronizada con Git."
