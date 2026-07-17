import 'package:flutter/material.dart';
import '../../data/shapes_data.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shape_3d_widget.dart';

class IntroActivity extends StatefulWidget {
  final String shapeId;
  final VoidCallback onDone;
  const IntroActivity({super.key, required this.shapeId, required this.onDone});

  @override
  State<IntroActivity> createState() => _IntroActivityState();
}

class _IntroActivityState extends State<IntroActivity> {
  @override
  void initState() {
    super.initState();
    final meta = shapeById(widget.shapeId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speak(meta.nameArabic);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = shapeById(widget.shapeId);
    final color = AppColors.shapeColors[meta.id] ?? AppColors.teal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shape3DWidget(type: meta.renderType, color: color, size: 220),
        const SizedBox(height: 24),
        Text(meta.nameArabic, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        IconButton(
          icon: const Icon(Icons.volume_up, size: 32),
          onPressed: () => AudioService.instance.speak(meta.nameArabic),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            AudioService.instance.playTap();
            widget.onDone();
          },
          child: const Text('التالي'),
        ),
      ],
    );
  }
}
