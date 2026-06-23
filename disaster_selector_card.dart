import 'package:flutter/material.dart';
import 'preloaded_disaster_card.dart';
import 'selected_disaster_card.dart';
import 'package:umeed_v0/widgets/shared/form_widgets.dart';

class DisasterSelectorCard extends StatelessWidget {
  final bool loadingDisasters;
  final String? disasterLoadError;
  final List<Map<String, dynamic>> pendingDisasters;
  final Map<String, dynamic>? selectedDisaster;
  final String? selectedDisasterId;
  final bool hasLoadedPassedDisaster;
  final VoidCallback onRetry;
  final ValueChanged<String?> onDisasterSelected;
  final VoidCallback onClearPreloaded;

  const DisasterSelectorCard({
    super.key,
    required this.loadingDisasters,
    this.disasterLoadError,
    required this.pendingDisasters,
    this.selectedDisaster,
    this.selectedDisasterId,
    required this.hasLoadedPassedDisaster,
    required this.onRetry,
    required this.onDisasterSelected,
    required this.onClearPreloaded,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingDisasters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(
            color: Color(0xFF4A0D0D),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (disasterLoadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErrorBanner(disasterLoadError!), // Make sure ErrorBanner is imported
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Color(0xFF4A0D0D), size: 16),
            label: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF4A0D0D), fontSize: 13),
            ),
          ),
        ],
      );
    }

    // Check if we have a pre-loaded disaster that's NOT in the pending list
    final hasPreloadedDisaster =
        selectedDisaster != null &&
        selectedDisasterId != null &&
        !pendingDisasters.any(
          (d) => d['_id'].toString() == selectedDisasterId,
        );

    // Check if we have a selected disaster that IS in the pending list
    final hasSelectedDisaster =
        selectedDisaster != null &&
        selectedDisasterId != null &&
        pendingDisasters.any(
          (d) => d['_id'].toString() == selectedDisasterId,
        );

    // Handle empty pending list with pre-loaded disaster
    if (pendingDisasters.isEmpty) {
      if (hasPreloadedDisaster || hasSelectedDisaster) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormLabel('Selected Disaster'),
            const SizedBox(height: 6),
            if (hasPreloadedDisaster)
              PreloadedDisasterCard(
                disaster: selectedDisaster!,
                onClear: onClearPreloaded,
              )
            else
              SelectedDisasterCard(disaster: selectedDisaster!),
            const SizedBox(height: 12),
            _buildEmptyBanner(),
          ],
        );
      }

      return _buildEmptyBanner();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormLabel('Disaster Without Resources'),
        const SizedBox(height: 6),
        if (hasPreloadedDisaster) ...[
          PreloadedDisasterCard(
            disaster: selectedDisaster!,
            onClear: onClearPreloaded,
          ),
          const SizedBox(height: 12),
        ],
        _buildDropdown(hasSelectedDisaster),
        if (hasSelectedDisaster) ...[
          const SizedBox(height: 12),
          SelectedDisasterCard(disaster: selectedDisaster!),
        ],
      ],
    );
  }

  Widget _buildEmptyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.4),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No disasters pending resource allocation.',
              style: TextStyle(color: Color(0xFFFF9800), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(bool hasSelectedDisaster) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: hasSelectedDisaster ? selectedDisasterId : null,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text(
          'Select a disaster…',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        items: pendingDisasters.map((d) {
          final type = d['disasterType'] ?? 'Disaster';
          final province = d['province'] ?? '';
          final date = d['startDate'] != null
              ? DateTime.tryParse(d['startDate'].toString())
              : null;
          final dateStr = date != null
              ? '${date.day}/${date.month}/${date.year}'
              : '';
          return DropdownMenuItem<String>(
            value: d['_id'].toString(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$type – $province',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: onDisasterSelected,
      ),
    );
  }
}