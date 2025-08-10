import 'package:flutter/material.dart';

class DurationPicker extends StatelessWidget {
  final int durationHours;
  final int durationMinutes;
  final Function(int hours, int minutes) onDurationChanged;

  const DurationPicker({
    super.key,
    required this.durationHours,
    required this.durationMinutes,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDurationDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    durationHours > 0 || durationMinutes > 0
                        ? '${durationHours}h ${durationMinutes}m'
                        : 'Select duration',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDurationDialog(BuildContext context) async {
    int tempHours = durationHours;
    int tempMinutes = durationMinutes;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Duration'),
              content: SizedBox(
                height: 200,
                child: Row(
                  children: [
                    // Hours picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Hours',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: FixedExtentScrollController(
                                initialItem: tempHours,
                              ),
                              itemExtent: 50,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 24,
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      '$index',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: index == tempHours
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  tempHours = index;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Minutes picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Minutes',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: FixedExtentScrollController(
                                initialItem: tempMinutes ~/ 5,
                              ),
                              itemExtent: 50,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12, // 0, 5, 10, 15, ..., 55
                                builder: (context, index) {
                                  final minutes = index * 5;
                                  return Center(
                                    child: Text(
                                      '$minutes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: minutes == tempMinutes
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  tempMinutes = index * 5;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onDurationChanged(tempHours, tempMinutes);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
