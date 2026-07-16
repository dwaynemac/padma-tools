# Contribuir a PADMA Tools

Buscamos integraciones pequeñas, claras y útiles para usuarios reales de PADMA.

## Agregar un plugin

1. Creá el plugin en `plugins/<nombre>/`.
2. Incluí un manifiesto válido en `.codex-plugin/plugin.json`.
3. Agregá únicamente los componentes necesarios: skills, MCP, apps, scripts o assets.
4. Registrá el plugin en `.agents/plugins/marketplace.json`.
5. Documentá autenticación, casos de uso, límites y efectos de escritura.
6. Verificá que no haya tokens, credenciales, datos personales ni IDs internos hardcodeados.

Preferimos plugins delgados: el servidor o la aplicación PADMA conserva permisos, validaciones e invariantes; el plugin aporta descubrimiento, contexto y workflows.

## Agregar una skill independiente

Usá `skills/<nombre>/SKILL.md` cuando el workflow no necesite MCP, apps, hooks ni otros componentes de un plugin. La descripción debe indicar con claridad cuándo debe activarse y las instrucciones deben enlazar solo las referencias necesarias.

## Checklist

- Los nombres usan minúsculas y guiones.
- No quedan placeholders ni instrucciones de desarrollo local.
- Los ejemplos representan capacidades disponibles hoy.
- Las escrituras sensibles requieren una propuesta clara y autorización del usuario.
- La documentación explica cómo verificar el resultado.
- El plugin y sus skills pasan sus validadores antes de publicarse.
