# TODO - Escalar proyecto

## Refactor estructura de `lib/`

- [ ] Dividir `main.dart` en módulos:
  - `lib/screens/home_screen.dart`
  - `lib/screens/fullscreen_viewer.dart`
  - `lib/widgets/local_media_viewer.dart`
  - `lib/widgets/cloud_media_viewer.dart`
  - `lib/services/api_service.dart`
  - `lib/services/media_service.dart`
  - `lib/config.dart` (server URL, constantes)

## Mejoras

- [ ] Agregar loading states y manejo de errores robusto
- [ ] Soporte para eliminación masiva
- [ ] Pull-to-refresh en ambas pestañas
- [ ] Búsqueda y filtros por tipo de archivo
- [ ] Modo offline / caché local de metadatos
- [ ] Autenticación en el servidor
- [ ] Configuración dinámica del servidor (input del usuario)

## Testing

- [ ] Tests unitarios para `ApiService`
- [ ] Tests de widget para HomeScreen
- [ ] Pruebas de integración

## Escalabilidad

- [ ] Migrar a estado global (Riverpod / Bloc)
- [ ] Paginación en grillas (carga lazy)
- [ ] Background upload/download
- [ ] Soporte multi-servidor
- [ ] CI/CD con GitHub Actions
