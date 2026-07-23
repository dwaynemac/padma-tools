# PADMA Tools

Plugins y skills para que los usuarios de [PADMA](https://derose.app/) puedan trabajar con sus datos desde agentes compatibles con Codex.

Este repositorio funciona como un marketplace de Codex. Cada plugin puede combinar instrucciones especializadas, documentación y conexiones MCP con las aplicaciones de PADMA.

## Instalar el marketplace en Codex

Necesitás una versión reciente de Codex con soporte para plugins.

```bash
codex plugin marketplace add dwaynemac/padma-tools
```

Después:

1. Abrí el catálogo con `/plugins` en Codex CLI o desde **Plugins** en la app de ChatGPT/Codex.
2. Elegí **PADMA Tools**.
3. Instalá el plugin que quieras usar.
4. Iniciá una tarea nueva para que el agente cargue sus skills y herramientas.

Para actualizar el catálogo y los plugins instalados:

```bash
codex plugin marketplace upgrade padma-tools
```

## Instalar el marketplace en Claude Code

Necesitás una versión reciente de Claude Code con soporte para plugins.

```bash
claude plugin marketplace add dwaynemac/padma-tools
claude plugin install crm@padma-tools
claude plugin install money@padma-tools
claude plugin install padma@padma-tools
```

El plugin `padma` sólo coordina los otros dos: no declara servidores MCP. Para
usar un solo producto, instalá únicamente su plugin:

```bash
claude plugin install money@padma-tools
# o
claude plugin install crm@padma-tools
```

Iniciá o reiniciá Claude Code para cargar las skills y herramientas del plugin.

Para actualizar el catálogo:

```bash
claude plugin marketplace update padma-tools
```

## Plugins disponibles

### PADMA

Coordina los plugins CRM y Money para trabajar con la situación comercial y
financiera de una escuela sin perder los límites entre productos. No declara
servidores MCP propios: las herramientas son provistas exclusivamente por los
plugins `crm` y `money`.

Permite:

- ubicar cada pregunta en su fuente de verdad dentro de PADMA;
- buscar contactos y analizar métricas comerciales mediante CRM;
- consultar y administrar las operaciones financieras disponibles en Money;
- preparar panoramas combinados con períodos, organizaciones y fuentes claras;
- reconocer cuándo una solicitud pertenece a Learn u otra app que
  todavía no está conectada por este plugin.

El plugin incluye la skill `padma-assistant`, una versión orientada al usuario
final del mapa de ecosistema que usan los developers. Evita detalles de
repositorios, modelos y rutas internas; enseña al agente a elegir el MCP
correcto y a no mezclar tenants, identificadores, monedas ni fechas.

#### Elegir el modo de instalación

- Instalá `crm` y `money` para disponer de sus herramientas MCP.
- Instalá también `padma` cuando quieras que el agente coordine ambos productos.
- Instalá sólo `crm` o `money` cuando necesites un único producto.

#### Configurar el acceso

1. Instalá `crm`, `money` y `padma`, e iniciá una tarea nueva.
2. Conectá CRM y Money cuando el cliente lo solicite. Cada servidor tiene su
   propio recurso y grant OAuth; ambos usan DCR y PKCE sin Client Secret.
3. Autorizá las organizaciones necesarias en cada producto.
4. Verificá CRM con `Listá las cuentas de CRM que tengo autorizadas.`
5. Verificá Money con `Listá los negocios de Money que tengo autorizados.`
6. Para un análisis combinado, seleccioná la organización de cada producto de
   forma independiente; nombres parecidos no prueban que sean el mismo tenant.

### Money

Conecta el agente con [PADMA Money](https://money.derose.app/) mediante su servidor MCP oficial.

Permite:

- descubrir y seleccionar entre los negocios autorizados por OAuth;
- consultar cuentas, categorías, contactos y movimientos;
- analizar gastos, ingresos, períodos y posibles anomalías;
- crear y corregir movimientos financieros;
- administrar cuentas, categorías, movimientos recurrentes, planes y automatizaciones;
- aplicar confirmación, idempotencia y verificación en operaciones de escritura.

El plugin incluye la skill `padma-money`, que enseña al agente el modelo financiero de Money, sus workflows seguros y las limitaciones reales de las herramientas disponibles.

#### Configurar el acceso

1. Instalá el plugin e iniciá una tarea nueva.
2. Cuando el cliente lo solicite, conectá Money e iniciá sesión mediante OAuth.
   Codex o Claude Code registrarán automáticamente un cliente público mediante
   DCR; no configures un Client ID ni un Client Secret compartidos.
3. Autorizá el acceso a una o más cuentas. Money limitará cada operación a los negocios habilitados que también puedas usar localmente.
4. Probá la conexión con: `Listá los negocios de Money que tengo autorizados.`

El plugin no requiere una API key ni una variable de entorno. El cliente administra la sesión OAuth; no pegues códigos de autorización ni tokens en prompts, archivos del repositorio, logs o URLs.

Si una instalación anterior tenía un Client ID OAuth estático, actualizá el
plugin, eliminá esa configuración y desconectá/reconectá Money para que el
cliente use DCR.

### CRM

Conecta el agente con [PADMA CRM](https://crm.derose.app/) mediante su servidor
MCP oficial.

Permite:

- descubrir y seleccionar cuentas autorizadas por OAuth;
- buscar contactos por identidad, estado, vínculo con la cuenta, actividad y fechas;
- descubrir etiquetas, métodos de marketing y listas guardadas antes de usarlos como filtros;
- consultar datos operativos del contacto dentro de la cuenta seleccionada;
- recorrer el historial de actividad del contacto con paginación segura;
- agregar comentarios visibles para la cuenta al contacto seleccionado;
- leer series mensuales persistidas y su fecha de actualización;
- comparar métricas con el mes anterior y el promedio de los tres meses previos;
- analizar el funnel comercial de procura, visitas, visitas perfil y matrículas.

El plugin incluye la skill `padma-crm`, que enseña al agente a preservar el
aislamiento entre cuentas, paginar búsquedas, minimizar la exposición de datos
personales y distinguir estadísticas faltantes de valores cero.

#### Configurar el acceso

1. Instalá el plugin e iniciá una tarea nueva.
2. Cuando el cliente lo solicite, conectá CRM e iniciá sesión mediante OAuth.
   El cliente registrará automáticamente un cliente público mediante DCR; no
   configures un Client ID ni un Client Secret compartidos.
3. Autorizá una o más cuentas habilitadas. El hostname del MCP selecciona el
   recurso OAuth, pero no restringe la marca de las cuentas autorizadas.
4. Probá la conexión con: `Listá las cuentas de CRM que tengo autorizadas.`
5. Elegí una cuenta devuelta y verificá una llamada real, por ejemplo:
   `Mostrame las definiciones de estadísticas mensuales de esta cuenta.`

El plugin no requiere una API key ni una variable de entorno. El cliente
administra la sesión OAuth. La única escritura disponible en esta versión es
agregar comentarios a contactos.

## Ejemplos

### PADMA

- “Dame un panorama comercial y financiero de mi escuela este trimestre.”
- “¿La mejora del funnel coincide con mayores ingresos? Separá hechos de interpretación.”
- “Buscá este contacto en CRM y revisá si tiene movimientos relacionados en Money.”
- “¿Qué parte de esta consulta corresponde a CRM, Money o Learn?”

### Money

- “¿Cuánto gastamos el mes pasado, separado por categoría?”
- “Buscá movimientos sin categoría y proponé cómo clasificarlos.”
- “Registrá este gasto después de mostrarme exactamente qué vas a crear.”
- “Compará este mes con el anterior y explicá las variaciones relevantes.”
- “Revisá esta cuenta contra el extracto y listá las diferencias sin modificar nada.”

### CRM

- “Buscá a Ana por email en la cuenta de Cerviño.”
- “Mostrame la actividad reciente de este contacto.”
- “Agregá este comentario al contacto que acabo de seleccionar.”
- “Mostrame alumnos y bajas mes a mes durante el último año.”
- “Compará la efectividad de este mes con el mes anterior.”
- “Analizá el funnel comercial de los últimos seis meses.”

## Estructura

```text
.agents/plugins/marketplace.json  catálogo que descubre Codex
plugins/                          plugins instalables
  padma/                          skill coordinadora, sin servidores MCP
  money/                          integración MCP con PADMA Money
  crm/                            integración MCP con PADMA CRM
```

Las skills específicas de un producto viajan dentro de su plugin. Las skills independientes podrán publicarse bajo `skills/` cuando no necesiten MCP ni otro componente adicional.

## Seguridad y alcance

- Cada integración debe respetar la lista de organizaciones autorizadas por sus credenciales y usar cualquier selector de organización solo dentro de esa lista.
- Los secretos deben permanecer fuera del repositorio.
- El agente debe mostrar y confirmar cambios financieros cuando el usuario todavía no haya autorizado la operación exacta.
- Los datos personales de CRM deben limitarse a lo necesario para responder la solicitud y nunca mezclarse entre cuentas.
- Las reglas de negocio, permisos e invariantes siguen viviendo en las aplicaciones PADMA; las skills orientan al agente, no reemplazan esas protecciones.

## Contribuir

Consultá [CONTRIBUTING.md](CONTRIBUTING.md) para agregar o actualizar un plugin o una skill.

## Documentación relacionada

- [Plugins de Codex](https://developers.openai.com/codex/plugins)
- [Crear y distribuir plugins](https://developers.openai.com/codex/plugins/build)
