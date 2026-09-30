# Publicación de PADMA CRM

Estado: preparación local. No enviado ni aprobado. Los casos incluidos son especificaciones de prueba, no resultados ejecutados.

## Plan y criterios de avance

1. Preparar paquete: `plugins/crm/plugin.json`, `mcp.json` y `skills/`. Nombre público PADMA CRM; conservar el identificador `crm` para compatibilidad. Versión de preparación 0.3.6. Preservar los cambios previos del checkout.
2. Completar ficha: confirmar URLs públicas de privacidad y soporte, términos si corresponden, identidad del editor, recursos gráficos requeridos por el portal y países de distribución. No inventar URLs ni políticas. Los campos ausentes siguen pendientes.
3. Revisar servidor: datos restringidos (en particular documentos gubernamentales), permisos por cuenta, esquemas, errores y las tres anotaciones explícitas de cada herramienta. Una instrucción en la skill no reemplaza controles del servidor. Resolver hallazgos antes de presentar el paquete.
4. Preparar cuenta demo dedicada con datos sintéticos y acceso inmediato para revisores, sin MFA, códigos por email/SMS ni redes privadas. Mantener las credenciales fuera del repositorio y del ZIP; cargarlas solo en Review details.
5. Ejecutar los cinco casos positivos y tres negativos declarados en el manifiesto desde una instalación nueva de Work. Registrar fecha, versión desplegada, resultado y evidencia. Probar OAuth, aislamiento de cuentas, rechazo por permisos y revocación. No usar datos de clientes reales.
6. Grabar el recorrido de prueba y agregar su URL accesible a `extensions.com.openai.review.demo_recording_url`. Confirmar que no se muestran secretos ni datos reales.
7. Generar el ZIP portable, validar su contenido y subirlo en https://platform.openai.com/plugins bajo la identidad verificada. Se necesita propietario de organización o Apps Management Write. Confirmar que no existe ya un plugin del mismo MCP antes de crear uno nuevo.
8. Conectar https://crm.derose.app/mcp y servir el token exacto que provea el portal en `/.well-known/openai-apps-challenge` del origen permitido. No inventar el token ni reemplazar el de otra publicación. Resolver hallazgos automáticos y completar los datos privados de revisión.
9. Solicitar revisión con el paquete final y las declaraciones verificadas. Tras la aprobación, publicar y comprobar instalación y una llamada real desde una cuenta distinta.

## Datos para los casos de revisión

- La cuenta demo debe incluir un contacto sintético con email `revision.crm@example.com`, proyectos y tareas accesibles al usuario revisor.
- `alta.crm@example.com` se reserva para el caso de alta/reutilización; ambos emails son datos sintéticos bajo el dominio reservado example.com.
- Obtener los IDs y el nombre técnico de la cuenta por herramientas; no fijar IDs ficticios en prompts.
- Anotar si el caso de alta devuelve creación o coincidencia existente. No borrar registros para repetir pruebas sin autorización.
- Los casos de acceso no autorizado y datos restringidos deben complementarse con verificación de servidor; una negativa del modelo sola no prueba aislamiento ni filtrado.

## Validación local

Ejecutar `rbenv exec ruby test/marketplace_compatibility_test.rb`, validar JSON/YAML y enlaces, y `git diff --check`.

Paquete portable: incluir únicamente `plugin.json`, `mcp.json` y `skills/` desde `plugins/crm/`, sin carpeta contenedora, credenciales, `.git`, archivos locales o plugins Money/PADMA. El ZIP de preparación no es todavía un paquete listo para enviar: faltan datos de ficha, prueba real, video y resolución de hallazgos.

## Fuentes

- https://developers.openai.com/plugins/deploy/submission
- https://developers.openai.com/plugins/plugin-guidelines
- https://developers.openai.com/plugins/build/plugins

## Avance verificado el 30 de septiembre de 2026

- Manifiestos CRM portable/Codex/Claude sincronizados en 0.3.5; ficha pública y casos de revisión preparados. Los cambios preexistentes permanecen en el checkout.
- Compatibilidad local: 1 prueba, 119 assertions, sin fallos. JSON y YAML válidos; `git diff --check` sin errores.
- Escuela demo elegida por el usuario: `testing`. `list_accounts` confirma acceso y `get_account_context` devuelve rol admin y capacidades read/write con la sesión existente. No se crearon datos ni se verificó una cuenta revisora nueva.
- Bloqueo confirmado por inspección de código: `create_contact_property` acepta documentos; `search_contacts` permite filtros por identificación; `contact_properties_support` y `get_contact_list` pueden devolver sus valores. El usuario autorizó retirarlo del MCP completo, conservando la interfaz habitual de CRM. Implementación local completada y verificada en MCP 2.0.0; no desplegado. No se modificó producción.
- Los 40 archivos de herramientas declaran estáticamente los tres hints; esto no acredita que cada clasificación sea correcta ni que sea la versión desplegada.
- Pendientes externos: URLs oficiales de privacidad y soporte, usuario revisor dedicado para testing, video, países, identidad/permisos del portal, token de dominio y revisión.

## Retiro de documentos del MCP: implementación local

- Autorizado por el usuario para todo el MCP; la interfaz habitual y los documentos guardados se conservan.
- MCP 2.0.0 retira entradas y salidas de identificación; rechaza listas con esos filtros, incluidas dependencias anidadas; excluye sus valores de búsquedas por texto y filtros de propiedades como dirección.
- Plugin 0.3.6: contrato documentado y prohibición de usar campos libres como alternativa. El borrador ZIP actualizado es `padma-crm-0.3.6-DRAFT.zip` y sustituye al borrador 0.3.5.
- Reproducciones fallidas previas a cada corrección: alta/listas, texto libre y filtro de dirección.
- Verificación: `rbenv exec ruby bin/rails test test/mcp test/requests/mcp_test.rb test/searchs/contact_search/local_contact_test.rb test/searchs/contact_search_test.rb test/models/persistent_contact_search_test.rb` — 339 tests, 2517 assertions, cero fallos/errores, un skip preexistente. Búsqueda habitual de CRM conservada y verificada.
- Compatibilidad del plugin: 119 assertions, JSON/YAML y enlaces relativos válidos. No hay commit, push ni despliegue.
- Antes del envío: desplegar y verificar la misma versión en Work; revisar por separado datos restringidos que puedan existir en campos libres y el alcance de otros campos sensibles. Este cambio no constituye redacción automática de contenido arbitrario ni aprobación del directorio.

## Páginas públicas: preparación local

- Responsable confirmado: HARAPPA srl. Soporte y privacidad: support@derose.app.
- Rutas implementadas en CRM: `/privacy` y `/support`, sin sesión, en español, inglés y portugués de Brasil/Portugal. El layout no carga analítica ni widgets externos.
- Plugin 0.3.7 apunta a https://crm.derose.app/privacy y https://crm.derose.app/support. Son destinos previstos: no se verificaron desplegados y no se debe enviar el paquete suponiendo que ya son públicos.
- Plazos confirmados posteriormente por el usuario: datos de una escuela durante 10 años después de la baja, backups con vigencia de 1 año y atención de solicitudes de eliminación en 10 días. La política en cuatro idiomas refleja estos plazos. Atención no equivale a borrado completado en 10 días. Falta verificar los mecanismos operativos y de backups; no se implementó un proceso de eliminación automática en este cambio.
- Contenido de destinatarios contrastado con código: AWS para archivos, AppSignal y, según funciones habilitadas, Brevo, PostHog, Google Gemini e integraciones conectadas. La ejecución/configuración productiva de cada proveedor no se auditó en esta preparación.
- Verificación local: 2 tests, 94 assertions, sin fallos; acceso sin sesión y traducciones en cuatro locales. Diseño inspeccionado en escritorio y móvil de 390 px.
- Commits anteriores ya creados: CRM 38ea72a39 y plugin e184548. Estas páginas y sus metadatos son cambios posteriores sin commit; no hubo push, despliegue ni envío.
