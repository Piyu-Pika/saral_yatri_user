import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/station_model.dart';
import '../../../data/providers/station_provider.dart';
import '../../../data/providers/location_provider.dart';

class StationDropdown extends ConsumerStatefulWidget {
  final String label;
  final String? hintText;
  final StationModel? selectedStation;
  final Function(StationModel?) onChanged;
  final String? Function(StationModel?)? validator;
  final bool showDistance;
  final List<String>? excludeStationIds;

  const StationDropdown({
    super.key,
    required this.label,
    this.hintText,
    this.selectedStation,
    required this.onChanged,
    this.validator,
    this.showDistance = true,
    this.excludeStationIds,
  });

  @override
  ConsumerState<StationDropdown> createState() => _StationDropdownState();
}

class _StationDropdownState extends ConsumerState<StationDropdown> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  List<StationModel> _filteredStations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stationProvider.notifier).loadActiveStations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStations(String query) {
    final stationState = ref.read(stationProvider);
    final allStations = stationState.stations;
    
    setState(() {
      if (query.isEmpty) {
        _filteredStations = allStations
            .where((station) => 
                widget.excludeStationIds?.contains(station.id) != true)
            .toList();
      } else {
        _filteredStations = allStations
            .where((station) =>
                (widget.excludeStationIds?.contains(station.id) != true) &&
                (station.stationName.toLowerCase().contains(query.toLowerCase()) ||
                 station.stationCode.toLowerCase().contains(query.toLowerCase()) ||
                 station.address.city.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  String _getDistanceText(StationModel station) {
    if (!widget.showDistance) return '';
    
    final locationNotifier = ref.read(locationProvider.notifier);
    final distance = locationNotifier.calculateDistanceToStation(
      station.location.latitude,
      station.location.longitude,
    );
    
    if (distance == null) return '';
    
    if (distance < 1000) {
      return ' • ${distance.round()}m away';
    } else {
      return ' • ${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationState = ref.watch(stationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isExpanded ? AppColors.primary : Colors.grey[300]!,
              width: _isExpanded ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Selected station display / Search field
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _filterStations('');
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: widget.selectedStation != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.selectedStation!.stationName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${widget.selectedStation!.stationCode} • ${widget.selectedStation!.address.city}${_getDistanceText(widget.selectedStation!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                widget.hintText ?? 'Select ${widget.label.toLowerCase()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown content
              if (_isExpanded) ...[
                const Divider(height: 1),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Column(
                    children: [
                      // Search field
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterStations,
                          decoration: InputDecoration(
                            hintText: 'Search stations...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),

                      // Station list
                      Expanded(
                        child: stationState.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : _filteredStations.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No stations found',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _filteredStations.length,
                                    itemBuilder: (context, index) {
                                      final station = _filteredStations[index];
                                      final isSelected = widget.selectedStation?.id == station.id;
                                      
                                      return InkWell(
                                        onTap: () {
                                          widget.onChanged(station);
                                          setState(() {
                                            _isExpanded = false;
                                          });
                                          _searchController.clear();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary.withValues(alpha: 0.1)
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      station.stationName,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: isSelected
                                                            ? AppColors.primary
                                                            : AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${station.stationCode} • ${station.address.city}${_getDistanceText(station)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}