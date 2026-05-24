import 'package:flutter/material.dart';

class DiscoveryOverlay extends StatelessWidget {
  final GlobalKey targetKey;
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLastStep;

  const DiscoveryOverlay({
    super.key,
    required this.targetKey,
    required this.title,
    required this.body,
    required this.icon,
    required this.onNext,
    required this.onSkip,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Stack(
      children: [
        // The Dark Mask with Hole
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: GestureDetector(
              onTap: onSkip,
              child: CustomPaint(
                painter: SpotlightPainter(
                  offset: position,
                  size: size,
                ),
              ),
            ),
          ),
        ),
        
        // Tooltip
        _buildTooltip(position, size),
      ],
    );
  }

  Widget _buildTooltip(Offset targetPos, Size targetSize) {
    // Basic positioning logic
    double top = targetPos.dy + targetSize.height + 20;
    double left = targetPos.dx;

    // Adjust if too low
    if (top > 500) { // arbitrary threshold for now
      top = targetPos.dy - 200; // rough tooltip height fallback
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: top,
      left: left.clamp(20, 300), // clamp to screen width
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2D),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF6366F1), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(body, 
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onSkip,
                    child: const Text('Skip', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isLastStep ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpotlightPainter extends CustomPainter {
  final Offset offset;
  final Size size;
  final double padding;

  SpotlightPainter({
    required this.offset,
    required this.size,
    this.padding = 8.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.8);
    
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - padding,
        offset.dy - padding,
        size.width + (padding * 2),
        size.height + (padding * 2),
      ),
      const Radius.circular(12),
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height)),
        Path()..addRRect(rrect),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.size != size;
  }
}
