# Reorganización del Proyecto - Text Replacer

## Cambios Realizados

### 🗂️ Estructura de Carpetas
- **ANTES**: `nodes/ChatBuffer/` (estructura confusa con nodos mixtos)
- **DESPUÉS**: `nodes/n8n-nodes-text-replacer/` (estructura limpia y coherente)

### 🧹 Limpieza Realizada
- ✅ Eliminada carpeta anidada `nodes/ChatBuffer/nodes/ChatBuffer/`
- ✅ Eliminado nodo ChatBuffer (solo mantenemos TextReplacer)
- ✅ Eliminadas credenciales innecesarias (`ChatBufferCredentials`)
- ✅ Renombrada carpeta principal a nombre coherente

### 📝 Archivos Actualizados
- ✅ `package.json` - Referencias de rutas y nodos
- ✅ `index.ts` - Solo exporta TextReplacer
- ✅ `install.sh` - Rutas actualizadas
- ✅ `README.md` - Reescrito con enfoque en TextReplacer manteniendo el tono rebelde

### 🎯 Resultado Final
```
nodes/n8n-nodes-text-replacer/
├── nodes/
│   └── TextReplacer/
│       ├── TextReplacer.node.ts
│       ├── TextReplacer.node.json
│       └── textReplace.svg
├── dist/
│   ├── index.js
│   └── nodes/
│       └── TextReplacer/
│           ├── TextReplacer.node.js
│           └── textReplace.svg
├── package.json
├── index.ts
├── README.md
└── install.sh
```

## Funcionalidades del Text Replacer

### ✨ Características Principales
- **Collection Dinámica**: Botón "+" para múltiples reemplazos
- **Expresiones n8n**: Soporte completo para `{{ $json.field }}`
- **Output Key Personalizable**: Define el nombre de la propiedad de salida
- **Reemplazo Global**: Reemplaza TODAS las instancias del placeholder
- **Logging Detallado**: Logs extensivos para debugging
- **Manejo de Errores**: Validaciones completas para casos edge

### 🔧 Parámetros
- **Input Text**: Texto con placeholders (multilinea)
- **Output Key Name**: Nombre de la key de salida (default: `processedText`)
- **Replacements**: Collection de grupos placeholder/replacer
  - **Placeholder**: Texto a buscar (ej: `$$nombre$$`)
  - **Replacer**: Valor de reemplazo (soporta expresiones n8n)

## Instalación y Uso

### Instalación
```bash
./install.sh
```

### Uso en n8n
1. Buscar "Text Replacer" en la categoría Transform
2. Configurar Input Text con placeholders
3. Agregar replacements con el botón "+"
4. Ejecutar y obtener texto procesado

## Estado del Proyecto
- ✅ **Código**: Completamente funcional
- ✅ **Estructura**: Limpia y coherente
- ✅ **Documentación**: Actualizada
- ✅ **Scripts**: Funcionales con nuevas rutas
- ✅ **Compilación**: Sin errores

El proyecto está listo para producción y uso. 