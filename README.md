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
claude plugin install money@padma-tools
```

Iniciá o reiniciá Claude Code para cargar las skills y herramientas del plugin.

Para actualizar el catálogo:

```bash
claude plugin marketplace update padma-tools
```

## Plugins disponibles

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

## Ejemplos

- “¿Cuánto gastamos el mes pasado, separado por categoría?”
- “Buscá movimientos sin categoría y proponé cómo clasificarlos.”
- “Registrá este gasto después de mostrarme exactamente qué vas a crear.”
- “Compará este mes con el anterior y explicá las variaciones relevantes.”
- “Revisá esta cuenta contra el extracto y listá las diferencias sin modificar nada.”

## Estructura

```text
.agents/plugins/marketplace.json  catálogo que descubre Codex
plugins/                          plugins instalables
  money/                          integración MCP con PADMA Money
```

Las skills específicas de un producto viajan dentro de su plugin. Las skills independientes podrán publicarse bajo `skills/` cuando no necesiten MCP ni otro componente adicional.

## Seguridad y alcance

- Cada integración debe respetar la lista de organizaciones autorizadas por sus credenciales y usar cualquier selector de organización solo dentro de esa lista.
- Los secretos deben permanecer fuera del repositorio.
- El agente debe mostrar y confirmar cambios financieros cuando el usuario todavía no haya autorizado la operación exacta.
- Las reglas de negocio, permisos e invariantes siguen viviendo en las aplicaciones PADMA; las skills orientan al agente, no reemplazan esas protecciones.

## Contribuir

Consultá [CONTRIBUTING.md](CONTRIBUTING.md) para agregar o actualizar un plugin o una skill.

## Documentación relacionada

- [Plugins de Codex](https://developers.openai.com/codex/plugins)
- [Crear y distribuir plugins](https://developers.openai.com/codex/plugins/build)
