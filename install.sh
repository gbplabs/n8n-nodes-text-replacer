#!/bin/bash

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Función para leer input con valor por defecto
read_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    
    echo -ne "${CYAN}${prompt}${NC} [${YELLOW}${default}${NC}]: "
    read -r result
    
    if [ -z "$result" ]; then
        result="$default"
    fi
    
    echo "$result"
}

# Función para verificar si un contenedor existe y está corriendo
check_container() {
    local container_name="$1"
    
    if ! docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        return 1
    fi
    
    return 0
}

# Función para listar contenedores disponibles
list_containers() {
    echo ""
    info "Contenedores Docker disponibles:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | head -10
    echo ""
}

# Función principal de instalación
install_text_replacer_node() {
    log "=== Instalador Interactivo del nodo Text Replacer ==="
    echo ""
    
    # Verificar que Docker esté ejecutándose
    if ! docker info > /dev/null 2>&1; then
        error "Docker no está ejecutándose"
        exit 1
    fi
    
    # Mostrar contenedores disponibles
    list_containers
    
    # Preguntar por el nombre del contenedor
    local container_name
    while true; do
        printf "${CYAN}¿Cuál es el nombre del contenedor de n8n?${NC} [${YELLOW}n8n${NC}]: "
        read container_name
        
        if [ -z "$container_name" ]; then
            container_name="n8n"
        fi
        
        if check_container "$container_name"; then
            success "Contenedor '$container_name' encontrado y ejecutándose"
            break
        else
            error "El contenedor '$container_name' no existe o no está ejecutándose"
            echo ""
            warning "Contenedores disponibles:"
            docker ps --format "{{.Names}}" | head -5
            echo ""
        fi
    done
    
    echo ""
    log "Usando contenedor: $container_name"
    
    # Verificar que el directorio del nodo existe
    if [ ! -d "nodes/n8n-nodes-text-replacer" ]; then
        error "Directorio nodes/n8n-nodes-text-replacer no encontrado"
        error "Asegúrate de ejecutar este script desde el directorio raíz del proyecto"
        exit 1
    fi
    
    log "Preparando el nodo Text Replacer para instalación..."
    
    # Cambiar al directorio del nodo
    cd nodes/n8n-nodes-text-replacer
    
    # Verificar archivos necesarios
    local required_files=("package.json" "tsconfig.json" "nodes/TextReplacer/TextReplacer.node.ts")
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            error "Archivo requerido no encontrado: $file"
            exit 1
        fi
    done
    
    # Instalar dependencias localmente para compilar
    log "Instalando dependencias para compilación..."
    npm install --only=dev > /dev/null 2>&1
    
    # Compilar TypeScript a JavaScript
    log "Compilando TypeScript..."
    npm run build > /dev/null 2>&1
    
    if [ ! -d "dist" ]; then
        error "Error en la compilación - directorio dist no creado"
        exit 1
    fi
    
    # Crear paquete npm
    log "Creando paquete npm..."
    npm pack > /dev/null 2>&1
    
    local package_file=$(ls n8n-nodes-gbplabs-text-replacer-*.tgz | head -1)
    
    if [ ! -f "$package_file" ]; then
        error "No se pudo crear el paquete npm"
        exit 1
    fi
    
    success "Paquete creado: $package_file"
    
    # Copiar paquete al contenedor
    log "Copiando paquete al contenedor $container_name..."
    docker cp "$package_file" "$container_name:/tmp/"
    
    # Instalar el nodo en el contenedor usando el método correcto
    log "Instalando nodo en el contenedor..."
    docker exec -it "$container_name" sh -c "cd /home/node/.n8n/nodes && npm install /tmp/$package_file" > /dev/null 2>&1
    
    # Verificar instalación
    log "Verificando instalación..."
    if docker exec "$container_name" sh -c "cd /home/node/.n8n/nodes && npm list n8n-nodes-gbplabs-text-replacer" > /dev/null 2>&1; then
        success "Nodo Text Replacer instalado correctamente"
    else
        error "Error en la verificación de la instalación"
        exit 1
    fi
    
    # Limpiar archivos temporales
    log "Limpiando archivos temporales..."
    rm -f "$package_file"
    docker exec "$container_name" rm -f "/tmp/$package_file" 2>/dev/null || true
    
    # Informar al usuario que debe reiniciar n8n
    echo ""
    warning "IMPORTANTE: Para que el nuevo nodo aparezca en n8n, debes reiniciar el contenedor:"
    echo ""
    info "Ejecuta el siguiente comando:"
    echo -e "${YELLOW}docker restart $container_name${NC}"
    echo ""
    info "Después del reinicio, espera unos 15 segundos para que n8n esté completamente listo."
    
    echo ""
    success "=== Instalación completada ==="
    success "El nodo Text Replacer está ahora disponible en n8n"
    echo ""
    info "Funcionalidades del nodo Text Replacer:"
    info "• Reemplaza múltiples placeholders en texto"
    info "• Soporte para expresiones n8n dinámicas"
    info "• Collection dinámica con grupos placeholder/replacer"
    info "• Output key personalizable"
    info "• Validación completa de parámetros"
    echo ""
    info "Parámetros de entrada Text Replacer:"
    info "• inputText: Texto con placeholders a reemplazar"
    info "• outputKey: Nombre de la key de salida (default: 'processedText')"
    info "• replacements: Collection de grupos placeholder/replacer"
    echo ""
    info "Funcionalidades del nodo ChatBuffer:"
    info "• Buffer temporal automático de mensajes"
    info "• Concatenación automática después del timeout"
    info "• Timeout configurable (default: 3000ms)"
    info "• Separador configurable (default: '. ')"
    echo ""
    info "Parámetros de entrada ChatBuffer:"
    info "• sessionId: ID de la sesión"
    info "• message: Mensaje a agregar al buffer"
    info "• timeout: Tiempo de espera en ms"
    info "• separator: Separador para concatenar mensajes"
    echo ""
    success "¡Puedes encontrar ambos nodos en la categoría 'Transform'!"
    echo ""
}

# Función de desinstalación
uninstall_text_replacer_node() {
    log "=== Desinstalación de los nodos Text Replacer y ChatBuffer ==="
    echo ""
    
    # Mostrar contenedores disponibles
    list_containers
    
    # Preguntar por el nombre del contenedor
    local container_name
    while true; do
        printf "${CYAN}¿Cuál es el nombre del contenedor de n8n?${NC} [${YELLOW}n8n${NC}]: "
        read container_name
        
        if [ -z "$container_name" ]; then
            container_name="n8n"
        fi
        
        if check_container "$container_name"; then
            success "Contenedor '$container_name' encontrado"
            break
        else
            error "El contenedor '$container_name' no existe o no está ejecutándose"
            echo ""
        fi
    done
    
    # Desinstalar el nodo
    log "Desinstalando nodo del contenedor..."
    if docker exec "$container_name" sh -c "cd /home/node/.n8n/nodes && npm uninstall n8n-nodes-gbplabs-text-replacer" > /dev/null 2>&1; then
        success "Nodos Text Replacer y ChatBuffer desinstalados"
    else
        warning "El nodo no estaba instalado o ya fue desinstalado"
    fi
    
    echo ""
    warning "IMPORTANTE: Para que los cambios tengan efecto, debes reiniciar el contenedor:"
    echo ""
    info "Ejecuta el siguiente comando:"
    echo -e "${YELLOW}docker restart $container_name${NC}"
    echo ""
    success "=== Desinstalación completada ==="
}

# Función de ayuda
show_help() {
    echo -e "${CYAN}Instalador Interactivo de los nodos Text Replacer y ChatBuffer para n8n${NC}"
    echo ""
    echo "Uso: $0 [OPCIÓN]"
    echo ""
    echo "Opciones:"
    echo "  install     Instalar los nodos Text Replacer y ChatBuffer (por defecto)"
    echo "  uninstall   Desinstalar los nodos Text Replacer y ChatBuffer"
    echo "  help        Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0              # Instalar los nodos (modo interactivo)"
    echo "  $0 install      # Instalar los nodos (modo interactivo)"
    echo "  $0 uninstall    # Desinstalar los nodos (modo interactivo)"
    echo ""
    echo "Nodos incluidos:"
    echo "• Text Replacer - Reemplaza múltiples placeholders en texto"
    echo "• ChatBuffer - Buffer temporal automático de mensajes"
    echo ""
    echo "Características:"
    echo "• Detección automática de contenedores Docker"
    echo "• Instalación interactiva con valores por defecto"
    echo "• Verificación de dependencias y archivos"
    echo "• Compilación automática de TypeScript"
    echo "• Verificación de salud de n8n"
    echo ""
}

# Función principal
main() {
    case "${1:-install}" in
        "install")
            install_text_replacer_node
            ;;
        "uninstall")
            uninstall_text_replacer_node
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal con todos los argumentos
main "$@" 