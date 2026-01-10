import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  const CircularActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildIconButton(), const SizedBox(height: 6), _buildLabel()],
    );
  }

  Widget _buildIconButton() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }
}
