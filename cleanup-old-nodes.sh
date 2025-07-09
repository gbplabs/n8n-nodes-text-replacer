#!/bin/bash

# Script para limpiar nodos antiguos que causan conflictos

echo "🧹 Limpiando nodos antiguos..."

# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker no está ejecutándose"
    exit 1
fi

# Nombre del contenedor (puedes cambiarlo si es diferente)
CONTAINER_NAME="n8n"

# Verificar que el contenedor existe
if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Contenedor '$CONTAINER_NAME' no encontrado o no está ejecutándose"
    echo "Contenedores disponibles:"
    docker ps --format "{{.Names}}"
    exit 1
fi

echo "📦 Desinstalando nodos antiguos..."

# Desinstalar nodos antiguos que pueden causar conflictos
docker exec "$CONTAINER_NAME" sh -c "cd /home/node/.n8n/nodes && npm uninstall n8n-nodes-chatbuffer" 2>/dev/null || echo "n8n-nodes-chatbuffer no estaba instalado"
docker exec "$CONTAINER_NAME" sh -c "cd /home/node/.n8n/nodes && npm uninstall n8n-nodes-gbplabs-chat-buffer" 2>/dev/null || echo "n8n-nodes-gbplabs-chat-buffer no estaba instalado"
docker exec "$CONTAINER_NAME" sh -c "cd /home/node/.n8n/nodes && npm uninstall n8n-nodes-gbplabs-text-replacer" 2>/dev/null || echo "n8n-nodes-gbplabs-text-replacer no estaba instalado"

echo "🔄 Reiniciando n8n para limpiar cache..."
docker restart "$CONTAINER_NAME"

echo "⏳ Esperando que n8n se reinicie (15 segundos)..."
sleep 15

echo "✅ Limpieza completada. Ahora puedes instalar el nodo nuevo con:"
echo "   bash install.sh" 