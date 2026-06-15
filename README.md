# galery_app

App de galería multiplataforma desarrollada con Flutter. Permite visualizar fotos y videos locales, subirlos a un servidor en la nube y gestionar contenido multimedia desde el dispositivo.

## Características

- Visualización de fotos y videos locales usando `photo_manager`
- Carga de archivos a servidor remoto (Raspberry Pi)
- Visor a pantalla completa con navegación entre archivos
- Soporte para video local y en streaming
- Gestión de contenido en nube (subir, eliminar, compartir)
- Compartir archivos mediante `share_plus`

## Stack técnico

- **Framework:** Flutter (Dart)
- **Dependencias principales:** `photo_manager`, `video_player`, `http`, `share_plus`, `photo_view`, `path_provider`, `permission_handler`

## Requisitos

- Flutter SDK >=3.0.0
- Dispositivo Android/iOS con API 21+
- Servidor backend corriendo en `http://raspberry.local:5000`

## Instalación

```bash
git clone <repo-url>
cd galery_app
flutter pub get
flutter run
```

## Uso

- **LOCAL:** Explora fotos y videos del dispositivo. Pulsación larga para subir a la nube.
- **NUBE:** Visualiza archivos remotos. Pulsación larga para eliminar.
- Toca cualquier archivo para abrir el visor a pantalla completa con navegación.
