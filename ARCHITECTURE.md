# Arquitectura

```
galery_app/
├── android/            # Configuración nativa Android
├── ios/                # Configuración nativa iOS
├── lib/
│   └── main.dart       # Punto de entrada única (todo en one-file)
├── linux/              # Configuración nativa Linux
├── macos/              # Configuración nativa macOS
├── test/
│   └── widget_test.dart
├── web/                # Configuración nativa web
├── windows/            # Configuración nativa Windows
├── pubspec.yaml
└── ...
```

## Estructura de `lib/`

Actualmente la app es **single-file** (`lib/main.dart`) con tres secciones principales:

### 1. Home (`_HomeState`)
- Carga assets locales vía `photo_manager`
- Carga assets remotos vía HTTP GET a `raspberry.local:5000`
- Grilla con dos pestañas: LOCAL y NUBE
- Upload de archivos con `http.MultipartRequest`
- Delete local con `PhotoManager.editor.deleteWithIds`
- Delete remoto con HTTP DELETE

### 2. FullScreenViewerWithNavigation
- Dialog a pantalla completa con `PageView` para navegar entre archivos
- Botones: compartir, eliminar, cerrar
- Contador de posición (ej. 3/15)

### 3. Media viewers
- `_LocalMediaViewer`: foto con `PhotoView` + video con `VideoPlayerController.file`
- `_CloudMediaViewer`: foto con `NetworkImage` + video con `VideoPlayerController.networkUrl`

## Flujo de datos

```
[Dispositivo] --photo_manager--> [Home] --HTTP--> [Servidor Raspberry Pi]
                                    |
                          [FullScreenViewer]
```

## Dependencias clave

| Paquete | Uso |
|---------|-----|
| `photo_manager` | Acceso a galería del dispositivo |
| `video_player` | Reproducción de video local/streaming |
| `http` | Comunicación con servidor REST |
| `share_plus` | Compartir archivos entre apps |
| `photo_view` | Visor de imágenes con zoom |
| `permission_handler` | Permisos de almacenamiento |
