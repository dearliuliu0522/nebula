import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nebula/core/theme/app_theme.dart';
import 'package:nebula/features/player/presentation/logic/player_controller.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap outside to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            // The Slider Container
            Positioned(
              width: 48,
              height: 160,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, -170), // Move up above the button
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cmfDarkGrey,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.volume_up,
                          size: 16,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3, // Vertical
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.nebulaPurple,
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.1,
                                ),
                                thumbColor: Colors.white,
                                trackHeight: 2.0,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6.0,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14.0,
                                ),
                                overlayColor: AppTheme.nebulaPurple.withOpacity(
                                  0.2,
                                ),
                              ),
                              child: Selector<PlayerController, double>(
                                selector: (_, p) => p.volume,
                                builder: (_, volume, __) {
                                  return Slider(
                                    value: volume.clamp(0.0, 1.0),
                                    onChanged: (value) {
                                      context
                                          .read<PlayerController>()
                                          .setVolume(value);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.volume_mute,
                          size: 16,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    // Using CompositedTransformTarget to anchor the overlay
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        icon: const Icon(Icons.volume_up),
        color: Colors.white,
        tooltip: 'Volume',
        onPressed: _toggleOverlay,
      ),
    );
  }
}
