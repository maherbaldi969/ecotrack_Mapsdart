import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import '../alerts/alert_models.dart';

class WeatherAlertBar extends StatefulWidget {
  final WeatherData weather;
  final VoidCallback onTap;
  final Duration displayDuration;

  const WeatherAlertBar({
    Key? key,
    required this.weather,
    required this.onTap,
    this.displayDuration = const Duration(seconds: 15),
  }) : super(key: key);

  @override
  State<WeatherAlertBar> createState() => _WeatherAlertBarState();
}

class _WeatherAlertBarState extends State<WeatherAlertBar> {
  late bool _visible;
  Timer? _dismissTimer;
  final _logger = Logger('WeatherAlertBar');

  @override
  void initState() {
    super.initState();
    _visible = true;
    if (widget.weather.alerts.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(widget.displayDuration, () {
      if (mounted) {
        setState(() => _visible = false);
        widget.onTap();
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final hasAlerts = widget.weather.alerts.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasAlerts
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasAlerts ? Icons.warning : Icons.check_circle,
            color:
                hasAlerts ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAlerts ? 'Alerte météo active' : 'Conditions favorables',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasAlerts && widget.weather.alerts.isNotEmpty)
                  Text(
                    widget.weather.alerts.first.title,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _dismissTimer?.cancel();
          widget.onTap();
        },
        child: _buildContent(context),
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }
}
