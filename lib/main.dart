import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const App());
}

String serverHost = "raspberry.local";
String serverPort = "5000";
double uiOpacity = 0.5;
String get server => "http://$serverHost:$serverPort";

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galería PRO',
      theme: ThemeData.dark(),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<AssetEntity> localAssets = [];
  List<dynamic> cloudAssets = [];
  bool isLoadingLocal = true;
  Set<String> cloudFileNames = {};

  @override
  void initState() {
    super.initState();
    _loadLocalAssets();
    _loadCloudAssets();
  }

  Future<void> _loadLocalAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.isLimited) {
      setState(() => isLoadingLocal = false);
      return;
    }

    final albums =
        await PhotoManager.getAssetPathList(type: RequestType.common);
    List<AssetEntity> allAssets = [];

    for (final album in albums) {
      final assets = await album.getAssetListPaged(page: 0, size: 100);
      allAssets.addAll(assets);
    }

    allAssets.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    setState(() {
      localAssets = allAssets;
      isLoadingLocal = false;
    });
    _updateCloudStatus();
  }

  Future<void> _loadCloudAssets() async {
    try {
      final response = await http.get(Uri.parse("$server/list"));
      if (response.statusCode == 200) {
        final List<dynamic> newCloud = jsonDecode(response.body);
        setState(() {
          cloudAssets = newCloud;
          cloudFileNames = newCloud.map((e) => e['name'] as String).toSet();
        });
        _updateCloudStatus();
      }
    } catch (e) {
      debugPrint("Error cargando nube: $e");
    }
  }

  void _updateCloudStatus() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _uploadFile(File file, String fileName) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse("$server/upload"));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      await request.send();
      await _loadCloudAssets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Archivo subido correctamente")),
        );
      }
    } catch (e) {
      debugPrint("Error al subir: $e");
    }
  }

  Future<void> _deleteCloudAsset(String fileName) async {
    try {
      await http.delete(Uri.parse("$server/delete/$fileName"));
      await _loadCloudAssets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eliminado de la nube")),
        );
      }
    } catch (e) {
      debugPrint("Error al borrar de nube: $e");
    }
  }

  Future<void> _deleteLocalAsset(AssetEntity asset) async {
    final deletedIds = await PhotoManager.editor.deleteWithIds([asset.id]);
    if (deletedIds.isNotEmpty) {
      setState(() {
        localAssets.remove(asset);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eliminado del dispositivo")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo eliminar")),
        );
      }
    }
  }

  void _showFullScreenWithNavigation({
    required bool isLocal,
    required int initialIndex,
    required List<dynamic> cloudList,
    required List<AssetEntity> localList,
  }) {
    showDialog(
      context: context,
      builder: (_) => FullScreenViewerWithNavigation(
        isLocal: isLocal,
        initialIndex: initialIndex,
        localAssets: localList,
        cloudAssets: cloudList,
        onDeleteLocal: _deleteLocalAsset,
        onDeleteCloud: _deleteCloudAsset,
        onShareLocal: (asset) async {
          final file = await asset.file;
          if (file != null) {
            await Share.shareXFiles([XFile(file.path)],
                text: "Compartido desde Galería PRO");
          }
        },
        onShareCloud: (item) async {
          final url = "$server${item['url']}";
          await Share.share(url, subject: "Compartir imagen/vídeo");
        },
      ),
    );
  }

  Widget _buildLocalGrid() {
    if (isLoadingLocal) {
      return const Center(child: CircularProgressIndicator());
    }
    if (localAssets.isEmpty) {
      return const Center(child: Text("No hay fotos o vídeos locales"));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: localAssets.length,
      itemBuilder: (context, index) {
        final asset = localAssets[index];
        final isVideo = asset.type == AssetType.video;
        final fileName = asset.title ?? asset.id; // nombre seguro (no nulo)
        final isAlreadyInCloud = cloudFileNames.contains(fileName);

        return GestureDetector(
          onTap: () => _showFullScreenWithNavigation(
            isLocal: true,
            initialIndex: index,
            localList: localAssets,
            cloudList: cloudAssets,
          ),
          onLongPress: () async {
            final file = await asset.file;
            if (file != null && !isAlreadyInCloud) {
              _uploadFile(file, fileName);
            } else if (isAlreadyInCloud) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Esta foto ya está en la nube")),
              );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder(
                future:
                    asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              if (isVideo)
                const Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 28),
                ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isAlreadyInCloud ? Icons.cloud : Icons.cloud_upload,
                      color: isAlreadyInCloud ? Colors.green : Colors.white,
                      size: 18,
                    ),
                    onPressed: () async {
                      if (!isAlreadyInCloud) {
                        final file = await asset.file;
                        if (file != null) _uploadFile(file, fileName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ya está en la nube")),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloudGrid() {
    if (cloudAssets.isEmpty) {
      return const Center(child: Text("No hay archivos en la nube"));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: cloudAssets.length,
      itemBuilder: (context, index) {
        final item = cloudAssets[index];
        final url = "$server${item['url']}";

        return GestureDetector(
          onTap: () => _showFullScreenWithNavigation(
            isLocal: false,
            initialIndex: index,
            localList: localAssets,
            cloudList: cloudAssets,
          ),
          onLongPress: () => _deleteCloudAsset(item['name']),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            cacheWidth: 300, // solo ancho, mantiene relación de aspecto
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    final hostController = TextEditingController(text: serverHost);
    final portController = TextEditingController(text: serverPort);
    double tempOpacity = uiOpacity;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Configuración"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: "Hostname / IP",
                  hintText: "ej. raspberry.local",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                decoration: const InputDecoration(
                  labelText: "Puerto",
                  hintText: "ej. 5000",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Opacidad símbolos:"),
                  Expanded(
                    child: Slider(
                      value: tempOpacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: "${(tempOpacity * 100).round()}%",
                      onChanged: (v) => setDialogState(() => tempOpacity = v),
                    ),
                  ),
                  Text("${(tempOpacity * 100).round()}%"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  serverHost = hostController.text.trim();
                  serverPort = portController.text.trim();
                  uiOpacity = tempOpacity;
                });
                _loadCloudAssets();
                Navigator.pop(ctx);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Galería PRO", style: TextStyle(fontSize: 11)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "LOCAL", icon: Icon(Icons.photo_library)),
              Tab(text: "NUBE", icon: Icon(Icons.cloud_queue)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLocalGrid(),
            _buildCloudGrid(),
          ],
        ),
      ),
    );
  }
}

// Visor con navegación
class FullScreenViewerWithNavigation extends StatefulWidget {
  final bool isLocal;
  final int initialIndex;
  final List<AssetEntity> localAssets;
  final List<dynamic> cloudAssets;
  final Future<void> Function(AssetEntity) onDeleteLocal;
  final Future<void> Function(String) onDeleteCloud;
  final Future<void> Function(AssetEntity) onShareLocal;
  final Future<void> Function(Map<String, dynamic>) onShareCloud;

  const FullScreenViewerWithNavigation({
    super.key,
    required this.isLocal,
    required this.initialIndex,
    required this.localAssets,
    required this.cloudAssets,
    required this.onDeleteLocal,
    required this.onDeleteCloud,
    required this.onShareLocal,
    required this.onShareCloud,
  });

  @override
  State<FullScreenViewerWithNavigation> createState() =>
      _FullScreenViewerWithNavigationState();
}

class _FullScreenViewerWithNavigationState
    extends State<FullScreenViewerWithNavigation> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDelete() async {
    if (widget.isLocal) {
      await widget.onDeleteLocal(widget.localAssets[_currentIndex]);
    } else {
      await widget.onDeleteCloud(widget.cloudAssets[_currentIndex]['name']);
    }
    if (mounted) {
      final newLength = widget.isLocal
          ? widget.localAssets.length
          : widget.cloudAssets.length;
      if (newLength == 0) {
        Navigator.of(context).pop();
      } else {
        setState(() {});
      }
    }
  }

  void _onShare() async {
    if (widget.isLocal) {
      await widget.onShareLocal(widget.localAssets[_currentIndex]);
    } else {
      await widget.onShareCloud(widget.cloudAssets[_currentIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total =
        widget.isLocal ? widget.localAssets.length : widget.cloudAssets.length;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed ? const NeverScrollableScrollPhysics() : null,
            itemCount: total,
            onPageChanged: (index) {
              setState(() {
                _isZoomed = false;
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (widget.isLocal) {
                return _LocalMediaViewer(
                  asset: widget.localAssets[index],
                  onZoomChanged: (zoomed) {
                    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
                  },
                );
              } else {
                return _CloudMediaViewer(
                  item: widget.cloudAssets[index],
                  onZoomChanged: (zoomed) {
                    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
                  },
                );
              }
            },
          ),
          if (total > 1) ...[
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height / 2 - 20,
              child: IconButton(
                icon: Icon(Icons.chevron_left,
                    color: Colors.white.withValues(alpha: uiOpacity), size: 40),
                onPressed: () {
                  if (_currentIndex > 0) {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease);
                  }
                },
              ),
            ),
            Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height / 2 - 20,
              child: IconButton(
                icon: Icon(Icons.chevron_right,
                    color: Colors.white.withValues(alpha: uiOpacity), size: 40),
                onPressed: () {
                  if (_currentIndex < total - 1) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease);
                  }
                },
              ),
            ),
          ],
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.share,
                      color: Colors.white.withValues(alpha: uiOpacity)),
                  onPressed: _onShare,
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Colors.white.withValues(alpha: uiOpacity)),
                  onPressed: _onDelete,
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.white.withValues(alpha: uiOpacity)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: uiOpacity),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentIndex + 1} / $total",
                  style: TextStyle(color: Colors.white.withValues(alpha: uiOpacity)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalMediaViewer extends StatefulWidget {
  final AssetEntity asset;
  final ValueChanged<bool> onZoomChanged;
  const _LocalMediaViewer({required this.asset, required this.onZoomChanged});

  @override
  State<_LocalMediaViewer> createState() => _LocalMediaViewerState();
}

class _LocalMediaViewerState extends State<_LocalMediaViewer> {
  VideoPlayerController? _videoController;
  Future<File?>? _fileFuture;

  @override
  void initState() {
    super.initState();
    _fileFuture = widget.asset.file;
    _fileFuture?.then((file) {
      if (file != null && widget.asset.type == AssetType.video) {
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            if (mounted) setState(() {});
            _videoController?.play();
          });
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asset.type == AssetType.video) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    } else {
      return FutureBuilder<File?>(
        future: _fileFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return PhotoView(
              imageProvider: FileImage(snapshot.data!),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              scaleStateChangedCallback: (state) {
                widget.onZoomChanged(state == PhotoViewScaleState.zoomedIn);
              },
            );
          }
          if (snapshot.hasError)
            return const Center(child: Text("Error al cargar"));
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
  }
}

class _CloudMediaViewer extends StatefulWidget {
  final Map<String, dynamic> item;
  final ValueChanged<bool> onZoomChanged;
  const _CloudMediaViewer({required this.item, required this.onZoomChanged});

  @override
  State<_CloudMediaViewer> createState() => _CloudMediaViewerState();
}

class _CloudMediaViewerState extends State<_CloudMediaViewer> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    final url = "$server${widget.item['url']}";
    final isVideo = widget.item['url'].toString().endsWith('.mp4');
    if (isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _videoController?.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = "$server${widget.item['url']}";
    final isVideo = widget.item['url'].toString().endsWith('.mp4');

    if (isVideo) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    } else {
      return PhotoView(
        imageProvider: NetworkImage(url),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        scaleStateChangedCallback: (state) {
          widget.onZoomChanged(state == PhotoViewScaleState.zoomedIn);
        },
      );
    }
  }
}
