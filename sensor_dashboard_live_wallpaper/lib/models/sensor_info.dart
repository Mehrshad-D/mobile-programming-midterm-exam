import 'package:flutter/material.dart';

enum SensorStatus { available, unavailable, permissionDenied, error }

class SensorInfo {
  const SensorInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.updateFrequency,
    this.value = '—',
    this.status = SensorStatus.unavailable,
    this.statusMessage = 'Checking availability…',
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String updateFrequency;
  final String value;
  final SensorStatus status;
  final String statusMessage;

  bool get isAvailable => status == SensorStatus.available;

  SensorInfo copyWith({
    String? value,
    SensorStatus? status,
    String? statusMessage,
  }) {
    return SensorInfo(
      id: id,
      name: name,
      description: description,
      icon: icon,
      updateFrequency: updateFrequency,
      value: value ?? this.value,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
