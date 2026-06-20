import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'core/theme/app_theme.dart';
import 'presentation/widgets/glassmorphism_widget.dart';
import 'presentation/widgets/liquid_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(GaleryApp(prefs: prefs));
}

String serverHost = "raspberry.local";
String serverPort = "5000";
double uiOpacity = 0.5;
String get server => "http://$serverHost:$serverPort";

class GaleryApp extends StatefulWidget {
  final SharedPreferences prefs;
  const GaleryApp({super.key, required this.prefs});

  @override
  State<GaleryApp> createState() => _GaleryAppState();
}

class _GaleryAppState extends State<GaleryApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final saved = widget.prefs.getString('theme_mode');
    _themeMode = saved == 'dark' ? ThemeMode.dark : saved == 'light' ? ThemeMode.light : ThemeMode.system;
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      widget.prefs.setString('theme_mode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(
      title: 'Galería PRO',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Home(onToggleTheme: _toggleTheme, isDark: _themeMode == ThemeMode.dark),
    );
  }
}

class Home extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const Home({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<AssetEntity> localAssets = [];
  List<dynamic> cloudAssets = [];
  bool isLoadingLocal = true;
  bool isUploading = false;
  double uploadProgress = 0;
  Set<String> cloudFileNames = {};
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadLocalAssets();
    _loadCloudAssets();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.isLimited) {
      setState(() => isLoadingLocal = false);
      return;
    }
    final albums = await PhotoManager.getAssetPathList(type: RequestType.common);
    List<AssetEntity> allAssets = [];
    for (final album in albums) {
      final assets = await album.getAssetListPaged(page: 0, size: 100);
      allAssets.addAll(assets);
    }
    allAssets.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    setState(() { localAssets = allAssets; isLoadingLocal = false; });
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
    setState(() { isUploading = true; uploadProgress = 0; });
    try {
      final request = http.MultipartRequest('POST', Uri.parse("$server/upload"));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      await request.send();
      for (var i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => uploadProgress = i / 10);
      }
      await _loadCloudAssets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Archivo subido correctamente")),
        );
      }
    } catch (e) {
      debugPrint("Error al subir: $e");
    } finally {
      if (mounted) setState(() { isUploading = false; uploadProgress = 0; });
    }
  }

  Future<void> _deleteCloudAsset(String fileName) async {
    try {
      await http.delete(Uri.parse("$server/delete/$fileName"));
      await _loadCloudAssets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eliminado de la nube")));
      }
    } catch (e) {
      debugPrint("Error al borrar de nube: $e");
    }
  }

  Future<void> _deleteLocalAsset(AssetEntity asset) async {
    final deletedIds = await PhotoManager.editor.deleteWithIds([asset.id]);
    if (deletedIds.isNotEmpty) {
      setState(() => localAssets.remove(asset));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eliminado del dispositivo")));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo eliminar")));
      }
    }
  }

  void _showSettingsDialog() {
    final hostController = TextEditingController(text: serverHost);
    final portController = TextEditingController(text: serverPort);
    double tempOpacity = uiOpacity;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface(context),
          title: Text("Configuración", style: TextStyle(color: AppTheme.textPrimary(context))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hostController,
                style: TextStyle(color: AppTheme.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: "Hostname / IP",
                  hintText: "ej. raspberry.local",
                  labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                style: TextStyle(color: AppTheme.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: "Puerto",
                  hintText: "ej. 5000",
                  labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text("Opacidad:", style: TextStyle(color: AppTheme.textPrimary(context))),
                  Expanded(
                    child: Slider(
                      value: tempOpacity, min: 0.1, max: 1.0, divisions: 9,
                      label: "${(tempOpacity * 100).round()}%",
                      onChanged: (v) => setDialogState(() => tempOpacity = v),
                    ),
                  ),
                  Text("${(tempOpacity * 100).round()}%", style: TextStyle(color: AppTheme.textPrimary(context))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
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

  void _showFullScreenWithNavigation({
    required bool isLocal, required int initialIndex,
    required List<dynamic> cloudList, required List<AssetEntity> localList,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullScreenViewerWithNavigation(
          isLocal: isLocal, initialIndex: initialIndex,
          localAssets: localList, cloudAssets: cloudList,
          onDeleteLocal: _deleteLocalAsset,
          onDeleteCloud: _deleteCloudAsset,
          onShareLocal: (asset) async {
            final file = await asset.file;
            if (file != null) {
              await Share.shareXFiles([XFile(file.path)], text: "Compartido desde Galería PRO");
            }
          },
          onShareCloud: (item) async {
            final url = "$server${item['url']}";
            await Share.share(url, subject: "Compartir imagen/vídeo");
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Widget _buildLocalGrid() {
    if (isLoadingLocal) {
      return const Center(child: CircularProgressIndicator());
    }
    if (localAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: AppTheme.textSecondary(context)),
            const SizedBox(height: 12),
            Text("No hay fotos o vídeos locales", style: TextStyle(color: AppTheme.textSecondary(context))),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
      ),
      itemCount: localAssets.length,
      itemBuilder: (context, index) {
        final asset = localAssets[index];
        final isVideo = asset.type == AssetType.video;
        final fileName = asset.title ?? asset.id;
        final isAlreadyInCloud = cloudFileNames.contains(fileName);
        return GestureDetector(
          onTap: () => _showFullScreenWithNavigation(
            isLocal: true, initialIndex: index,
            localList: localAssets, cloudList: cloudAssets,
          ),
          onLongPress: () async {
            final file = await asset.file;
            if (file != null && !isAlreadyInCloud) _uploadFile(file, fileName);
          },
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 12,
            blur: 8,
            borderWidth: 0.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FutureBuilder(
                  future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                if (isVideo)
                  Positioned(bottom: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                    ),
                  ),
                Positioned(top: 4, left: 4,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                    child: IconButton(
                      icon: Icon(isAlreadyInCloud ? Icons.cloud : Icons.cloud_upload,
                        color: isAlreadyInCloud ? Colors.green : Colors.white, size: 16),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (!isAlreadyInCloud) {
                          final file = await asset.file;
                          if (file != null) _uploadFile(file, fileName);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildCloudGrid() {
    if (cloudAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: AppTheme.textSecondary(context)),
            const SizedBox(height: 12),
            Text("No hay archivos en la nube", style: TextStyle(color: AppTheme.textSecondary(context))),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
      ),
      itemCount: cloudAssets.length,
      itemBuilder: (context, index) {
        final item = cloudAssets[index];
        final url = "$server${item['url']}";
        return GestureDetector(
          onTap: () => _showFullScreenWithNavigation(
            isLocal: false, initialIndex: index,
            localList: localAssets, cloudList: cloudAssets,
          ),
          onLongPress: () => _deleteCloudAsset(item['name']),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 12,
            blur: 8,
            borderWidth: 0.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(url, fit: BoxFit.cover, cacheWidth: 300),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 30).ms).slideY(begin: 0.2);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Galería PRO").animate().shakeX(duration: 600.ms),
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6, color: AppTheme.textPrimary(context)),
              onPressed: widget.onToggleTheme,
            ),
            IconButton(
              icon: Icon(Icons.settings, color: AppTheme.textPrimary(context)),
              onPressed: _showSettingsDialog,
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary(context),
            tabs: const [
              Tab(text: "LOCAL", icon: Icon(Icons.photo_library)),
              Tab(text: "NUBE", icon: Icon(Icons.cloud_queue)),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [AppTheme.darkBackground, AppTheme.darkSurface, AppTheme.darkBackground]
                  : [AppTheme.lightBackground, const Color(0xFFE8E8FF), AppTheme.lightBackground],
            ),
          ),
          child: Column(
            children: [
              if (isUploading) Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 12, blur: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_upload, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LiquidBar(progress: uploadProgress, height: 8,
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                      ),
                      const SizedBox(width: 8),
                      Text("${(uploadProgress * 100).round()}%",
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLocalGrid().animate().fadeIn(duration: 500.ms),
                    _buildCloudGrid().animate().fadeIn(duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    super.key, required this.isLocal, required this.initialIndex,
    required this.localAssets, required this.cloudAssets,
    required this.onDeleteLocal, required this.onDeleteCloud,
    required this.onShareLocal, required this.onShareCloud,
  });

  @override
  State<FullScreenViewerWithNavigation> createState() => _FullScreenViewerWithNavigationState();
}

class _FullScreenViewerWithNavigationState extends State<FullScreenViewerWithNavigation> {
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
      final newLength = widget.isLocal ? widget.localAssets.length : widget.cloudAssets.length;
      if (newLength == 0) { Navigator.of(context).pop(); }
      else { setState(() {}); }
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
    final total = widget.isLocal ? widget.localAssets.length : widget.cloudAssets.length;
    return Scaffold(
      backgroundColor: _viewerBg(context),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed ? const NeverScrollableScrollPhysics() : null,
            itemCount: total,
            onPageChanged: (index) { setState(() { _isZoomed = false; _currentIndex = index; }); },
            itemBuilder: (context, index) {
              if (widget.isLocal) {
                return _LocalMediaViewer(
                  asset: widget.localAssets[index],
                  onZoomChanged: (zoomed) { if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed); },
                  bgColor: _viewerBg(context),
                );
              } else {
                return _CloudMediaViewer(
                  item: widget.cloudAssets[index],
                  onZoomChanged: (zoomed) { if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed); },
                  bgColor: _viewerBg(context),
                );
              }
            },
          ),
          if (total > 1) ...[
            Positioned(left: 10, top: MediaQuery.of(context).size.height / 2 - 20,
              child:               IconButton(
                icon: Icon(Icons.chevron_left, color: _viewerIcon(context).withValues(alpha: uiOpacity), size: 40),
                onPressed: () { if (_currentIndex > 0) _pageController.previousPage(duration: 300.ms, curve: Curves.ease); },
              ),
            ),
            Positioned(right: 10, top: MediaQuery.of(context).size.height / 2 - 20,
              child: IconButton(
                icon: Icon(Icons.chevron_right, color: _viewerIcon(context).withValues(alpha: uiOpacity), size: 40),
                onPressed: () { if (_currentIndex < total - 1) _pageController.nextPage(duration: 300.ms, curve: Curves.ease); },
              ),
            ),
          ],
          Positioned(top: 48, right: 16,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              borderRadius: 24, blur: 12, borderWidth: 0.5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconButton(Icons.share, _onShare),
                  const SizedBox(width: 4),
                  _IconButton(Icons.delete, _onDelete),
                  const SizedBox(width: 4),
                  _IconButton(Icons.close, () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
          Positioned(bottom: 32, left: 0, right: 0,
            child: Center(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: 20, blur: 12, borderWidth: 0.5,
                child: Text("${_currentIndex + 1} / $total",
                  style: TextStyle(color: _viewerIcon(context).withValues(alpha: uiOpacity), fontSize: 14)),
              ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
            ),
          ),
        ],
      ),
    );
  }
}

Color _viewerBg(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFFF5F5FF);

Color _viewerIcon(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;

Widget _IconButton(IconData icon, VoidCallback onPressed) {
  return Builder(
    builder: (context) => IconButton(
      icon: Icon(icon, color: _viewerIcon(context).withValues(alpha: uiOpacity), size: 22),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    ),
  );
}

class _LocalMediaViewer extends StatefulWidget {
  final AssetEntity asset;
  final ValueChanged<bool> onZoomChanged;
  final Color bgColor;
  const _LocalMediaViewer({required this.asset, required this.onZoomChanged, required this.bgColor});

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
        _videoController = VideoPlayerController.file(file)..initialize().then((_) {
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
          child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<File?>(
      future: _fileFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return PhotoView(
            imageProvider: FileImage(snapshot.data!),
            backgroundDecoration: BoxDecoration(color: widget.bgColor),
            scaleStateChangedCallback: (state) {
              widget.onZoomChanged(state == PhotoViewScaleState.zoomedIn);
            },
          );
        }
        if (snapshot.hasError) return const Center(child: Text("Error al cargar"));
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _CloudMediaViewer extends StatefulWidget {
  final Map<String, dynamic> item;
  final ValueChanged<bool> onZoomChanged;
  final Color bgColor;
  const _CloudMediaViewer({required this.item, required this.onZoomChanged, required this.bgColor});

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
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))..initialize().then((_) {
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
          child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    return PhotoView(
      imageProvider: NetworkImage(url),
      backgroundDecoration: BoxDecoration(color: widget.bgColor),
      scaleStateChangedCallback: (state) {
        widget.onZoomChanged(state == PhotoViewScaleState.zoomedIn);
      },
    );
  }
}
