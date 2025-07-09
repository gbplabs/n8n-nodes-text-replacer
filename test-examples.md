# Text Replacer - Ejemplos de Uso

## Ejemplo Básico
**Input Text:**
```
Hola $$nombre$$, tu edad es $$edad$$ años y vives en $$ciudad$$.
```

**Replacements:**
- Placeholder: `$$nombre$$` → Replacer: `Pablo`
- Placeholder: `$$edad$$` → Replacer: `30`
- Placeholder: `$$ciudad$$` → Replacer: `Madrid`

**Output:**
```json
{
  "processedText": "Hola Pablo, tu edad es 30 años y vives en Madrid."
}
```

## Ejemplo con Expresiones n8n
**Input Text:**
```
Bienvenido $$usuario$$, tu último login fue $$fecha$$.
```

**Replacements:**
- Placeholder: `$$usuario$$` → Replacer: `{{ $json.userName }}`
- Placeholder: `$$fecha$$` → Replacer: `{{ $json.lastLogin }}`

**Input Data:**
```json
{
  "userName": "Pablo",
  "lastLogin": "2024-01-15"
}
```

**Output:**
```json
{
  "userName": "Pablo",
  "lastLogin": "2024-01-15",
  "processedText": "Bienvenido Pablo, tu último login fue 2024-01-15."
}
```

## Ejemplo con Output Key Personalizada
**Output Key Name:** `mensaje`

**Input Text:**
```
El producto $$producto$$ cuesta $$precio$$.
```

**Replacements:**
- Placeholder: `$$producto$$` → Replacer: `Laptop`
- Placeholder: `$$precio$$` → Replacer: `$999`

**Output:**
```json
{
  "mensaje": "El producto Laptop cuesta $999."
}
```

## Ejemplo con Múltiples Instancias
**Input Text:**
```
$$saludo$$ $$nombre$$, esperamos que $$nombre$$ tenga un buen día. $$saludo$$!
```

**Replacements:**
- Placeholder: `$$saludo$$` → Replacer: `Hola`
- Placeholder: `$$nombre$$` → Replacer: `María`

**Output:**
```json
{
  "processedText": "Hola María, esperamos que María tenga un buen día. Hola!"
}
```

## Características del Nodo

✅ **Múltiples Replacements**: Botón "+" para agregar tantos como necesites
✅ **Expresiones n8n**: Soporte completo para `{{ $json.field }}`
✅ **Output Key Personalizable**: Define el nombre de la propiedad de salida
✅ **Reemplazo Global**: Reemplaza TODAS las instancias del placeholder
✅ **Logging Detallado**: Logs extensivos para debugging
✅ **Manejo de Errores**: Continúa en caso de error si está configurado
✅ **Validaciones**: Maneja casos edge como placeholders vacíos o no encontrados 