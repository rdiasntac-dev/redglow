import 'package:flutter/material.dart';

class Professional {
  const Professional({
    required this.name,
    required this.specialty,
    required this.price,
    required this.rating,
    required this.services,
    required this.imageUrl,
    required this.avatarColor,
  });

  final String name;
  final String specialty;
  final String price;
  final double rating;
  final int services;
  final String imageUrl;
  final Color avatarColor;
}

class Appointment {
  const Appointment({
    required this.time,
    required this.duration,
    required this.client,
    required this.service,
    required this.address,
    required this.price,
    required this.imageUrl,
  });

  final String time;
  final String duration;
  final String client;
  final String service;
  final String address;
  final String price;
  final String imageUrl;
}
