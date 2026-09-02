# SCIKIT — Especificación de desarrollo

> Documento de referencia para la implementación de **SCIKIT** desde cero.
> Versión 1.0 — Flutter / Dart.

---

## 1. Objetivo

Construir **SCIKIT** completamente desde cero como una **aplicación móvil Flutter/Dart**.

**SCIKIT** es una **plataforma modular de herramientas científicas** para dispositivos móviles, orientada principalmente a **Android**. No es una aplicación dedicada a una sola herramienta.

La primera herramienta implementada será **Biblioteca de Medios**, pero la plataforma debe estar diseñada para incorporar muchas más herramientas científicas en el futuro (estudiantes, técnicos, investigadores y científicos) sin necesidad de rehacer la aplicación.

La arquitectura debe permitir añadir nuevas herramientas **sin reconstruir SCIKIT desde cero**.

---

## 2. Tecnología

Obligatoriamente:

- **Flutter**
- **Dart**
- **Material 3**
- Arquitectura modular y escalable.
- Separación clara entre UI, lógica, modelos y almacenamiento.
- Navegación estructurada.
- Persistencia local de datos.

**No** crear una aplicación web. El proyecto es una **aplicación móvil Flutter** orientada a Android.

---

## 3. Arquitectura conceptual

```
SCIKIT
→ Dashboard principal
→ Agregar herramienta
→ Herramientas disponibles
→ Biblioteca de Medios
→ Futuras herramientas
```

### Reglas arquitectónicas

- **Biblioteca de Medios NO es la aplicación completa.** Funciona como una herramienta independiente dentro de SCIKIT.
- **No** acoplar el dashboard directamente a Biblioteca de Medios.
- Crear un sistema que permita **registrar / agregar** herramientas posteriormente.

### Regla fundamental

> **SCIKIT** = plataforma de herramientas científicas
> **Dashboard** = lugar donde el usuario selecciona sus herramientas
> **Biblioteca de Medios** = primera herramienta

El usuario debe poder:

1. Abrir SCIKIT **sin ninguna herramienta agregada**.
2. Pulsar **“+ Agregar herramienta”**.
3. Seleccionar **Biblioteca de Medios**.
4. Utilizarla.

---

## 4. Dashboard principal

El dashboard es la pantalla principal de SCIKIT.

### Estado inicial (primera instalación / apertura)

**NO** debe aparecer ninguna herramienta agregada. Se muestra un estado vacío profesional:

```
SCIKIT

Tu espacio de herramientas científicas

Aún no has agregado ninguna herramienta.

+ Agregar herramienta
```

Al tocar **Agregar herramienta**, se muestran las herramientas disponibles.

Actualmente solo estará disponible **Biblioteca de Medios**.

### Acciones del usuario sobre el dashboard

El usuario debe poder:

- **Agregar** herramientas.
- **Quitar** herramientas del dashboard.
- **Abrir** una herramienta.
- Mantener los datos de una herramienta aunque la quite del dashboard.

> **Quitar una herramienta del dashboard NO debe eliminar sus datos.**

---

## 5. Diseño visual

**Material 3** como sistema de diseño.

Apariencia:

- Científica.
- Profesional.
- Moderna.
- Limpia.
- Minimalista.
- Fácil de utilizar.
- Adecuada para uso diario en laboratorio.

**No** utilizar estética de videojuego ni excesivamente tecnológica.

---

## 6. Tema claro y oscuro

Implementar completamente:

- Tema claro.
- Tema oscuro.
- Soporte para seguir el tema del sistema.

Los colores deben tener **contraste suficiente en ambos temas**. Nunca utilizar:

- Texto claro sobre fondo claro.
- Texto oscuro sobre fondo oscuro.
- Iconos con poco contraste.
- Botones cuyo texto no sea claramente visible.

Utilizar el sistema de colores de Material 3 y definir los colores **centralmente en el Theme** de Flutter.

---

## 7. Paleta de colores

Paleta científica basada en **azul y teal**.

### Tema claro

| Rol                  | Valor      |
| -------------------- | ---------- |
| Primary              | `#1565C0`  |
| Primary Container    | `#D6E4FF`  |
| Secondary            | `#00897B`  |
| Background           | `#F8FAFC`  |
| Surface              | `#FFFFFF`  |
| Surface Variant      | `#E8EEF5`  |
| Texto principal      | `#17202A`  |
| Texto secundario     | `#52606D`  |
| Error                | `#BA1A1A`  |

### Tema oscuro

| Rol                  | Valor      |
| -------------------- | ---------- |
| Primary              | `#90CAF9`  |
| Primary Container    | `#0D3B66`  |
| Secondary            | `#80CBC4`  |
| Background           | `#0F1419`  |
| Surface              | `#171D23`  |
| Surface Variant      | `#26313A`  |
| Texto principal      | `#F1F4F6`  |
| Texto secundario     | `#B8C2CC`  |
| Error                | `#FFB4AB`  |

**No** escribir estos colores directamente en cada widget. Centralizarlos dentro del sistema de Theme.

---

## 8. Tipografía

Tipografía estándar de Material 3 / Flutter.

Tamaños recomendados:

| Elemento            | Tamaño      |
| ------------------- | ----------- |
| Título principal    | 28–32 sp    |
| Título de pantalla  | 24–28 sp    |
| Títulos de sección  | 20–24 sp    |
| Título de tarjeta   | 16–18 sp    |
| Texto normal        | 14–16 sp    |
| Texto secundario    | 12–14 sp    |
| Botones             | 14–16 sp    |
| Campos numéricos    | 18–20 sp    |

Priorizar siempre la legibilidad.

---

## 9. Espaciado y tamaños

Escala consistente:

| Distancia | Uso                             |
| --------- | ------------------------------- |
| 4 dp      | separación mínima               |
| 8 dp      | separación pequeña              |
| 12 dp     | separación interna              |
| 16 dp     | espaciado estándar              |
| 24 dp     | separación entre secciones      |
| 32 dp     | separación grande               |

- **16 dp** de margen horizontal para el contenido principal.

**Cards:**
- Padding: 16 dp
- Radio: 12–16 dp
- Separación: 12 dp

**Botones:**
- Altura aproximada: 48 dp
- Área táctil mínima: 48 × 48 dp

**Campos:**
- Altura aproximada: 56 dp

Mantener estos tamaños consistentes en toda la aplicación.

---

## 10. Diseño adaptable (responsive)

La interfaz debe ser **adaptable en altura y ancho** para funcionar correctamente en distintos tamaños de pantalla (teléfonos pequeños, tablets, soportes de laboratorio, orientación vertical y horizontal).

> **Dirección de desplazamiento:** el contenido se desplaza **solo en vertical**. **Nunca** desplazar en horizontal. El ancho debe acomodarse por completo a la pantalla sin que sea necesario hacer scroll lateral.

**Reglas generales:**

- El **contenido debe ajustarse automáticamente** al ancho y alto disponibles. Nunca fijar dimensiones absolutas para contenedores principales si pueden romper el layout en pantallas más pequeñas o desperdiciar espacio en pantallas más grandes.
- Utilizar widgets de Flutter que se adapten al espacio disponible: `Column`, `Row`, `ListView`, `GridView`, `Expanded`, `Flexible`, `ConstrainedBox`, `LayoutBuilder`, entre otros.
- El **desplazamiento** debe ser únicamente **vertical** (`SingleChildScrollView` en vertical, `ListView`, `GridView` con scroll vertical, etc.). El contenido **horizontal** debe caber siempre dentro del ancho de la pantalla, ajustando tamaños y envolviendo texto para evitar overflow lateral.
- Aprovechar el espacio extra en pantallas grandes **sin deformar** la interfaz (p. ej., ajustar el ancho máximo del contenido o el número de columnas).
- Mantener un **ancho máximo de contenido** en pantallas muy anchas para conservar la legibilidad y la estética (p. ej., texto y tarjetas no deben estirarse en exceso).

**Buenas prácticas:**

- Usar `LayoutBuilder` / `MediaQuery` para tomar decisiones de maquetación según el tamaño disponible.
- En grids o listas, adaptar el número de columnas al ancho de la pantalla.
- Respeta las escalas de espaciado (sección 9) pero permítelas variar ligeramente según el tamaño de pantalla.
- Asegurar que los **campos numéricos**, botones y tarjetas conserven su usabilidad en pantallas pequeñas (sin cortarse ni solaparse).
- En orientación horizontal o pantallas grandes, reorganizar el layout si facilita su uso (p. ej., tabla de resultados más ancha).

**Prohibido:**

- Fijar tamaños (ancho/alto) en píxeles/dp duros en widgets de alto nivel que impidan la adaptación.
- Permitir desbordamientos visuales o texto cortado que rompan el diseño.
- **Desplazamiento horizontal** (`ScrollView`/`ListView` horizontales). Si el ancho no alcanza, adaptar el layout para que quepa en vertical.

---

## 11. Iconos

Utilizar principalmente **Material Symbols / Material Icons**.

Para iconos científicos que no existan en Material, se puede usar una librería compatible con Flutter, como **Phosphor Icons**.

- Mantener un único estilo visual consistente.
- **No** utilizar emojis como iconos principales de la interfaz.

Ejemplos:

| Acción           | Icono                 |
| ---------------- | --------------------- |
| Agregar          | Add                   |
| Eliminar         | Delete                |
| Editar           | Edit                  |
| Preparar         | Science / Biotech     |
| Biblioteca       | Library / Inventory   |
| Configuración    | Settings              |
| Buscar           | Search                |
| Atrás            | Arrow Back            |

---

## 12. Biblioteca de Medios

**Primera herramienta** disponible.

Función: guardar fórmulas de medios y calcular automáticamente las cantidades necesarias para preparar diferentes volúmenes.

---

## 13. Lista de medios

Pantalla de Biblioteca de Medios: lista limpia.

Cada medio muestra únicamente:

- **Nombre del medio**
- Acciones: **Preparar** | **Editar**

**NO** mostrar en esta pantalla:

- Componentes.
- Cantidades.
- Fórmulas.
- Resultados.
- Recomendaciones de preparación.

La información detallada solo aparece tras seleccionar **Preparar** o **Editar**.

---

## 14. Crear y editar medios

### Información general

- Nombre del medio.
- Volumen base.
- Unidad del volumen base.

Unidades de volumen disponibles (únicamente):

- **mL**
- **L**

### Componentes

Cada componente tendrá:

- Nombre.
- Cantidad.
- Unidad.

Unidades disponibles (únicamente):

- **mg**
- **g**
- **mL**
- **L**

Las unidades **NO deben ser campos de texto**; deben seleccionarse mediante un **selector / dropdown**.

**No** permitir unidades personalizadas por el momento.

El usuario debe poder agregar tantos componentes como necesite.

Ejemplo:

```
Medio X
Volumen base: 1 L
Componentes:
- Agar → 100 g
- NaCl → 5 g
- Componente líquido → 10 mL
```

---

## 15. Preparar un medio

**Preparar** y **Editar** son funciones **completamente separadas**.

Al tocar **Preparar**, abrir una pantalla específica para preparar el medio.

### Título

```
Preparar: [Nombre del medio]
```

### Campo de volumen

El campo comienza con **Volumen a preparar**, donde se introduce el valor y la unidad:

```
Volumen a preparar

[ 900 ] [ mL ▼ ]
```

- El usuario introduce manualmente el volumen.
- **No** mostrar recomendaciones ni volúmenes predeterminados.
- **No** sugerir: 100 mL, 200 mL, 300 mL, 500 mL ni ningún otro volumen.
- El usuario decide cuánto quiere preparar.

---

## 16. Cálculo de preparación

Cálculo automático de cuánto necesitar de **cada componente individualmente**.

Fórmula:

```
cantidad necesaria = cantidad base × (volumen deseado / volumen base)
```

### Ejemplo 1

Fórmula base **1 L**:

- Agar → 100 g
- NaCl → 5 g

Usuario: **100 mL**

Conversión: `100 mL / 1000 mL = 0.1`

Resultado:

- Agar → **10 g**
- NaCl → **0.5 g**

### Ejemplo 2

Fórmula base **1 L**:

- Agar → 100 g

Usuario: **900 mL**

Resultado: **90 g**

Si el medio tiene 10 componentes, se realiza el cálculo individual para los 10 componentes.

---

## 17. Conversión de unidades

El motor de cálculo debe manejar correctamente las unidades.

Unidades disponibles:

- **Masa:** mg, g
- **Volumen:** mL, L

El sistema convierte internamente las unidades cuando sea necesario.

### Ejemplo

Fórmula base **1 L**, usuario **500 mL**:

```
500 mL = 0.5 L
```

Después se realiza el cálculo proporcional.

**No** permitir unidades personalizadas.

---

## 18. Precisión

- **No** redondear durante el cálculo interno.
- Mantener suficiente precisión; redondear únicamente el resultado mostrado.
- **No** mostrar decimales innecesarios.

Ejemplos:

- `10.000000 g` → se muestra como `10 g`
- `0.25 g` → se mantiene como `0.25 g`

Presentación limpia y fácil de leer.

---

## 19. Pantalla de resultados

Tras introducir el volumen, mostrar una lista clara de resultados.

### Encabezado

En lugar de un encabezado genérico, mostrar:

```
Para preparar 200 mL de [nombre del medio]:
```

### Tabla de resultados

| Componente   | Cantidad |
| ------------ | -------: |
| Agar         |     90 g |
| NaCl         |    4.5 g |
| Componente X |     9 mL |

- La pantalla debe priorizar las cantidades calculadas.
- **No** añadir recomendaciones que el usuario no solicitó.

---

## 20. Editar medio

Al tocar **Editar**, mostrar los componentes del medio y permitir modificar:

- Nombre.
- Volumen base.
- Unidad del volumen base.
- Nombre de cada componente.
- Cantidad.
- Unidad.
- Agregar componentes.
- Eliminar componentes.

Al guardar los cambios, la nueva fórmula se utiliza automáticamente para futuros cálculos.

---

## 21. Validaciones

Validar correctamente:

- Nombre vacío.
- Volumen vacío.
- Volumen menor o igual a cero.
- Cantidad menor o igual a cero.
- Componentes incompletos.
- Medio sin componentes.

- **No** permitir guardar datos inválidos.
- Mostrar mensajes de error claros y fáciles de entender.
- Antes de eliminar información importante, solicitar confirmación.

---

## 22. Persistencia

- Los medios creados deben permanecer guardados tras cerrar y volver a abrir SCIKIT.
- La arquitectura de almacenamiento debe estar preparada para que cada futura herramienta tenga sus propios datos.
- **Eliminar una herramienta del dashboard NO debe eliminar sus datos.**

---

## 23. Código y organización

**No** crear toda la aplicación en un único archivo.

Organizar el proyecto por funcionalidades y responsabilidades. Separar como mínimo:

- Modelos.
- Lógica de negocio.
- Cálculos.
- Persistencia.
- Navegación.
- Theme.
- Widgets reutilizables.
- Dashboard.
- Sistema de herramientas.
- Biblioteca de Medios.

La **lógica matemática** de Biblioteca de Medios debe estar separada de la UI para poder probarla y reutilizarla. Crear **funciones de cálculo fáciles de probar**.

---

## 24. Preparación para futuras herramientas

Diseñar un sistemas de herramientas donde cada herramienta tenga conceptualmente:

- ID único.
- Nombre.
- Icono.
- Descripción.
- Ruta / pantalla.
- Estado de si está agregada al dashboard.

Por ahora solo implementar **Biblioteca de Medios**, pero **no** diseñar la arquitectura de manera que todo dependa exclusivamente de ella. En el futuro se agregarán otras herramientas científicas.

---

## 25. Migración de trabajos anteriores

Si existe una versión anterior del proyecto (web, móvil o funcionalidades previamente implementadas):

- **No** asumir que la versión web es el producto final.
- Analizar lo existente y **conservar / migrar** cualquier funcionalidad útil ya implementada.
- La funcionalidad final debe quedar integrada correctamente en el nuevo proyecto Flutter.
- Una vez migrado y verificado todo lo necesario, **eliminar la carpeta / proyecto web** (no se mantiene una versión web innecesaria).

---

## 26. APK y compilaciones

**NO** generar ni exportar APK de debug automáticamente.

Durante el desarrollo se puede ejecutar y probar la aplicación mediante Flutter, emulador o dispositivo conectado cuando sea necesario. Pero:

- **NO** ejecutar `flutter build apk`.
- **NO** generar APK de debug.
- **NO** generar APK release.
- **NO** generar archivos de distribución.
- **NO** instalar APK automáticamente.

**Solo** generar un APK cuando se solicite explícitamente.

---

## 27. Orden de construcción

1. Construir **primero** la base completa de SCIKIT (dashboard, sistema de herramientas, tema, navegación, persistencia).
2. Después integrar **Biblioteca de Medios** dentro de esa arquitectura.

---

## 28. Modificaciones de la interfaz

Aplicar sobre la construcción:

### 27.1 Menú principal (Dashboard)

- **Eliminar** la barra inferior de navegación.
- **Eliminar** los botones **Inicio** y **Herramientas**.

> El dashboard se compone únicamente de la barra superior (título) y el contenido (estado vacío o lista de herramientas), sin barra de navegación inferior ni pestañas Inicio/Herramientas.

### 27.2 Pantalla de preparación de medio

- **Eliminar** el campo de **Volumen base del medio** de esta pantalla.
- El campo de entrada comienza con **Volumen a preparar**, donde se introduce el valor y la unidad.
- Sustituir el encabezado **Resultado para...** por:

  ```
  Para preparar 200 mL de [nombre del medio]:
  ```

- Debajo, mantener los resultados actuales (el listado de cantidades calculadas por componente).

> Nota: el **volumen base** sigue siendo necesario para el cálculo, pero **no se muestra** en la pantalla de preparación; la proporción se calcula respecto al valor almacenado en el medio.
