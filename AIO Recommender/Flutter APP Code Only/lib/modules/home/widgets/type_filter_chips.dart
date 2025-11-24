import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';

class TypeFilterChips extends StatelessWidget {
  final HomeController controller;
  const TypeFilterChips({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final types = [
      {'key': 'mixed', 'label': 'All'},
      {'key': 'movie', 'label': 'Movies'},
      {'key': 'anime', 'label': 'Anime'},
      {'key': 'webseries', 'label': 'Webseries'},
    ];

    return Obx(
      () => Wrap(
        spacing: 10,
        children:
            types.map((t) {
              final isSelected = controller.selectedType.value == t['key'];
              return ChoiceChip(
                label: Text(t['label']!),
                selected: isSelected,
                onSelected: (_) => controller.changeType(t['key']!),
                selectedColor: const Color(0xFF6366F1).withOpacity(0.9),
                backgroundColor: const Color(0xFF0F172A),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected ? const Color(0xFF6366F1) : Colors.white24,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
