import 'package:flutter/material.dart';
import '../../services/preference_service.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.showAsGrid,
    required this.onLayoutToggled,
  });

  final bool showAsGrid;
  final ValueChanged<bool> onLayoutToggled;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redoPreferences(BuildContext context) async {
    final prefService = await PreferenceService.getInstance();
    await prefService.resetOnboarding();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Animated App Bar
          SliverAppBar(
            backgroundColor: Colors.black,
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade900, Colors.black],
                  ),
                ),
              ),
            ),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Section
                  _AnimatedSection(
                    index: 0,
                    controller: _controller,
                    child: _SettingsSection(
                      title: 'Display',
                      icon: Icons.palette_outlined,
                      children: [
                        _AnimatedSettingsTile(
                          icon: Icons.grid_view_rounded,
                          iconColor: Colors.blue,
                          title: 'Grid View',
                          subtitle: 'Show wallpapers in a grid layout',
                          trailing: _AnimatedSwitch(
                            value: widget.showAsGrid,
                            onChanged: widget.onLayoutToggled,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preferences Section
                  _AnimatedSection(
                    index: 1,
                    controller: _controller,
                    child: _SettingsSection(
                      title: 'Preferences',
                      icon: Icons.tune_rounded,
                      children: [
                        _AnimatedSettingsTile(
                          icon: Icons.refresh_rounded,
                          iconColor: Colors.orange,
                          title: 'Redo Preferences',
                          subtitle: 'Swipe through categories again',
                          onTap: () => _redoPreferences(context),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  _AnimatedSection(
                    index: 2,
                    controller: _controller,
                    child: _SettingsSection(
                      title: 'About',
                      icon: Icons.info_outline_rounded,
                      children: [
                        _AnimatedSettingsTile(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          title: 'Version',
                          subtitle: '1.0.0',
                        ),
                        _AnimatedSettingsTile(
                          icon: Icons.code_rounded,
                          iconColor: Colors.purple,
                          title: 'Made with',
                          subtitle: 'Flutter & ❤️',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer animation
                  _AnimatedSection(
                    index: 3,
                    controller: _controller,
                    child: Center(
                      child: Column(
                        children: [
                          _PulsingIcon(icon: Icons.wallpaper_rounded),
                          const SizedBox(height: 8),
                          Text(
                            'Wallpaper App',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated section entrance
class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.index,
    required this.controller,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.15;
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay,
          (delay + 0.4).clamp(0, 1),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Settings section card
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade800.withValues(alpha: 0.5),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// Animated settings tile with tap feedback
class _AnimatedSettingsTile extends StatefulWidget {
  const _AnimatedSettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<_AnimatedSettingsTile> createState() => _AnimatedSettingsTileState();
}

class _AnimatedSettingsTileState extends State<_AnimatedSettingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withValues(alpha: 0.05),
    ).animate(_tapController);
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _tapController.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _tapController.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _tapController.reverse() : null,
      child: AnimatedBuilder(
        animation: _tapController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(color: _colorAnimation.value, child: child),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Animated icon container
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

// Custom animated switch
class _AnimatedSwitch extends StatelessWidget {
  const _AnimatedSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? Colors.green : Colors.grey.shade700,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Pulsing icon animation
class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon});

  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(scale: _animation.value, child: child),
        );
      },
      child: Icon(widget.icon, color: Colors.grey.shade700, size: 32),
    );
  }
}
