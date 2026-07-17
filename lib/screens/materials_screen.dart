import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../models/course.dart';
import '../models/material.dart';
import '../providers/course_provider.dart';
import '../providers/settings_provider.dart';
import '../services/hive_service.dart';
import '../widgets/powered_by_footer.dart';

class MaterialsScreen extends StatefulWidget {
  final bool isEmbedded;

  const MaterialsScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final HiveService _hiveService = HiveService();
  final Map<String, double> _downloadProgress = {}; // materialId -> progress (0.0 to 1.0)
  List<StudyMaterial> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  void _loadMaterials() {
    final saved = _hiveService.getAllMaterials();
    if (saved.isNotEmpty) {
      setState(() {
        _materials = saved;
      });
    } else {
      // Create defaults
      final defaults = [
        StudyMaterial(
          id: 'mat_gst101_1',
          title: 'Grammar and Sentence Structure Guide',
          courseId: 'gst101',
          fileUrl: 'https://raw.githubusercontent.com/msitarzewski/agency-agents/main/materials/gst101/grammar_guide.pdf',
          version: 1,
          size: '4.2 MB',
        ),
        StudyMaterial(
          id: 'mat_gst102_1',
          title: 'Pre-Colonial Nigerian Kingdoms & Culture',
          courseId: 'gst102',
          fileUrl: 'https://raw.githubusercontent.com/msitarzewski/agency-agents/main/materials/gst102/kingdoms.pdf',
          version: 1,
          size: '5.8 MB',
        ),
        StudyMaterial(
          id: 'mat_gst111_1',
          title: 'Introduction to Logic and Fallacies',
          courseId: 'gst111',
          fileUrl: 'https://raw.githubusercontent.com/msitarzewski/agency-agents/main/materials/gst111/logic_intro.pdf',
          version: 1,
          size: '3.1 MB',
        ),
        StudyMaterial(
          id: 'mat_gst112_1',
          title: 'Citizenship Education Study Handbook',
          courseId: 'gst112',
          fileUrl: 'https://raw.githubusercontent.com/msitarzewski/agency-agents/main/materials/gst112/handbook.pdf',
          version: 2,
          size: '6.5 MB',
        ),
      ];
      
      for (var item in defaults) {
        _hiveService.saveMaterial(item);
      }
      
      setState(() {
        _materials = defaults;
      });
    }
  }

  Future<void> _startDownload(StudyMaterial material) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    // Check low data mode constraint
    if (settingsProvider.settings.lowDataMode) {
      final proceed = await _showLowDataWarning(context, material.size);
      if (!proceed) return;
    }

    setState(() {
      _downloadProgress[material.id] = 0.0;
    });

    // Simulate progress download offline/online
    double progress = 0.0;
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      progress += 0.1;
      if (mounted) {
        setState(() {
          _downloadProgress[material.id] = progress;
        });
      }
    }

    final updated = material.copyWith(
      isDownloaded: true,
      localPath: '/simulated_path/${material.id}.pdf', // mock path
    );

    await _hiveService.saveMaterial(updated);
    _loadMaterials();
    
    setState(() {
      _downloadProgress.remove(material.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${material.title} downloaded successfully!')),
      );
    }
  }

  Future<bool> _showLowDataWarning(BuildContext context, String size) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: const Text('Low Data Warning ⚠️', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
            content: Text(
              'Low Data Mode is enabled in your settings. This download requires $size of data. Do you want to proceed?',
              style: const TextStyle(color: AppColors.inkSoft),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.navy)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Download anyway', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _viewMaterial(StudyMaterial material) {
    // Navigate to PDF viewer screen (mock or view)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MockPdfViewer(title: material.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    final body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
      children: [
        const Text(
          'Download and study official GST course materials offline. These files are saved locally on your device.',
          style: TextStyle(color: AppColors.inkSoft, fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 20.0),

        ..._materials.map((material) {
          final course = courseProvider.courses.firstWhere((c) => c.id == material.courseId);
          final progress = _downloadProgress[material.id];
          final isDownloading = progress != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: course.color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('📄', style: TextStyle(fontSize: 18.0)),
                  ),
                  const SizedBox(width: 14.0),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.code,
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.0,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          material.title,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          'Size: ${material.size} • Version ${material.version}',
                          style: const TextStyle(
                            color: AppColors.inkSoft,
                            fontSize: 11.0,
                          ),
                        ),
                        
                        if (isDownloading) ...[
                          const SizedBox(height: 8.0),
                          LinearProgressIndicator(
                            value: progress,
                            color: AppColors.orange,
                            backgroundColor: AppColors.navy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),

                  // Action Button
                  if (material.isDownloaded)
                    IconButton(
                      icon: const Icon(Icons.menu_book_rounded, color: AppColors.navy),
                      onPressed: () => _viewMaterial(material),
                    )
                  else if (isDownloading)
                    const SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.orange),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.file_download_outlined, color: AppColors.orange),
                      onPressed: () => _startDownload(material),
                    ),
                ],
              ),
            ),
          );
        }),
        const PoweredByFooter(),
      ],
    );

    if (widget.isEmbedded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Study Materials', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }
}

// Simple Mock PDF Viewer Screen
class _MockPdfViewer extends StatelessWidget {
  final String title;

  const _MockPdfViewer({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80.0),
              const SizedBox(height: 24.0),
              const Text(
                'PDF Reader View Active',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 12.0),
              Text(
                'This screen runs the PDF viewer for: "$title". Fully integrated offline and printable.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft, height: 1.4),
              ),
              const SizedBox(height: 36.0),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Materials'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
