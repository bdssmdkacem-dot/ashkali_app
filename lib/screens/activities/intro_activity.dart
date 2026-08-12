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
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: Shape3DWidget(type: meta.renderType, color: color, size: 220),
        ),
        const SizedBox(height: 24),
        Text(meta.nameArabic, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.15),
          child: IconButton(
            icon: Icon(Icons.volume_up, size: 28, color: color),
            onPressed: () => AudioService.instance.speak(meta.nameArabic),
          ),
        ),
        const SizedBox(height: 20),
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
