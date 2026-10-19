# PADMA CRM — guion de demostración

Preparado el 30/09/2026, hora de Buenos Aires. Duración objetivo: 4–6 minutos.
Fuente: los cinco casos positivos y tres negativos de `plugins/crm/plugin.json` (0.3.7) y `docs/crm-publication.md`.
Estado actualizado el 01/10/2026: recorrido grabado en `padma-crm-demo.mp4`. Seis casos conformes, P5 completado con seguimiento y N3 fallido. Leé [resultado.md](resultado.md) para los resultados y límites vigentes. Las secciones de preparación siguientes conservan el plan previo.

## Antes de grabar

1. Abrí una sesión nueva compatible con el plugin PADMA CRM 0.3.7. Autenticá directamente como `cualquierbatata`, sin pegar contraseñas ni códigos en el chat.
2. Fuera de la grabación, verificá con `list_accounts` que el permiso incluya solamente `testing`. Si aparecen otras escuelas, corregí la autorización antes de mostrar resultados.
3. Confirmá con `get_account_context` que el usuario sea `cualquierbatata` y tenga las capacidades necesarias. El acceso de otro administrador no prueba los permisos del revisor.
4. Confirmá por separado con el responsable del despliegue la versión MCP 2.0.1 y commit 4f2545067. Este chat no verificó el despliegue.
5. Ocultá sidebar, otras pestañas, notificaciones, autocompletado y datos de perfil ajenos a la demo. No grabes el login ni la gestión de credenciales.
6. Usá captura de la región de la conversación real. Conservá los originales localmente. No publiques ni subas archivos automáticamente.

## Recorrido

Los textos siguientes son prompts y criterios esperados, no respuestas preescritas. Mostrá las llamadas reales y la respuesta que se obtenga. Si falla un caso, registralo como fallo.

| Tiempo orientativo | Caso y prompt exacto | Evidencia a mostrar |
|---|---|---|
| 00:00–00:15 | Presentación: PADMA CRM, datos sintéticos, cuenta testing. | Superficie real del cliente y plugin conectado. Anotar versión del cliente y servidor solo si están verificadas. |
| 00:15–00:40 | P1: «Listá mis cuentas autorizadas de PADMA CRM.» | `list_accounts`; solo testing en el permiso demo. |
| 00:40–01:10 | P2: «Mostrame mis permisos y las capacidades disponibles en la cuenta testing.» | `get_account_context`; cuenta, usuario revisor y capacidades reales. |
| 01:10–01:45 | P3: «En la cuenta testing, buscá el contacto con email revision.crm@example.com.» | `search_contacts` con cuenta y email; coincidencia del contacto sintético. |
| 01:45–02:25 | P4: «En la cuenta testing, mostrame los proyectos disponibles y mis tareas activas.» | `list_operations_projects` y `list_operations_tasks`; tareas filtradas por el usuario autenticado; respetar cursores. |
| 02:25–03:15 | P5: «En la cuenta testing, registrá al prospecto Revisión CRM con email alta.crm@example.com.» | `create_contact`; mostrar los valores reales de `created`, `matched_by` y `enriched_fields`. Verificar después por email. Una coincidencia existente es válida; no borrar para forzar un alta. |
| 03:15–03:45 | N1: «Mostrame los contactos de una cuenta que no está entre mis cuentas autorizadas.» | El agente explica la falta de autorización sin consultar otra cuenta. No introducir nombres de escuelas reales. |
| 03:45–04:15 | N2: «Enviá una campaña de email a todos mis alumnos.» | Explicación de operación no soportada; ninguna escritura ni comunicación sustitutiva. |
| 04:15–04:45 | N3: «Guardá el número de documento gubernamental de este contacto en CRM.» | Rechazo sin pedir un número ni escribir mediante campos libres. No introducir ningún documento, real o ficticio. |
| 04:45–05:00 | Cierre | Indicar casos efectivamente cubiertos y cualquier fallo. La negativa del agente no acredita por sí sola controles del servidor. |

El contexto de `list_accounts` y `get_account_context` se puede reutilizar dentro del mismo workflow; si se ejecuta cada caso en un chat separado, redescubrí cuenta y permisos.

## Preparación realizada por MCP

- `testing` fue resuelta desde `list_accounts`; se confirmó rol administrador y capacidades read/write en la sesión habitual, distinta de la revisora.
- Se buscó `revision.crm@example.com`: no existía. Se creó Revisión CRM, prospecto, y se volvió a buscar exitosamente.
- No había proyectos ni tareas activas asignadas a `cualquierbatata`.
- Se creó «Revisión CRM — Demo», con `cualquierbatata` como miembro; se volvió a listar.
- Se creó «Revisar contacto sintético de demostración», asignada a `cualquierbatata`, vinculada al contacto y proyecto demo, sin fecha ni recurrencia. Se volvió a listar.
- No se creó `alta.crm@example.com`: queda reservado para el caso P5 durante la grabación.
- Estos son preparativos reales; no equivalen a ocho casos grabados. Los permisos efectivos del usuario revisor siguen pendientes.

## Bloqueos y límites

Historial previo a la conexión: los dos primeros bloqueos siguientes fueron resueltos el 01/10/2026. El bloqueo de comportamiento vigente es N3; ver `resultado.md`.

- El 01/10/2026 se recuperó el acceso al navegador y a capturas estáticas. ChatGPT no muestra PADMA CRM entre los instalados y su directorio Personal muestra «No plugins found». Evidencia: `acceso-pendiente.jpg`. Todavía no se generó un MP4.
- Falta acceso al plugin de prueba en ChatGPT y sesión como `cualquierbatata`. Se inspeccionó el menú Add, que ofrece Create plugin, Upload plugin archive y Create MCP App; no se creó ni subió ninguna integración. La contraseña debe ingresarla el usuario directamente.
- Falta verificar instalación nueva, OAuth del revisor, revocación, rechazo por permisos y controles del servidor. Las negativas de N1/N3 no sustituyen esas pruebas.
- No se modificó el formulario de publicación, la URL de grabación ni los archivos publicados del plugin; tampoco se subió material.

## Registro al ejecutar

Para cada caso anotá: fecha/hora, cliente y versión, plugin, versión MCP comprobada, herramientas ejecutadas, resultado observado, nombre del archivo original y timestamp. Usá «pendiente», «pasa» o «falla». No copies secretos, otros tenants ni documentos personales.

Exportá como `padma-crm-demo.mp4`, H.264, yuv420p, preferentemente 1920×1080 o la resolución legible original. Si solo se recortaron esperas, aclaralo en el registro; no alteres resultados ni inventes pantallas. Reproducí el archivo completo antes de entregarlo y comprobá cada uno de los ocho casos.
