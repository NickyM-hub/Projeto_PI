import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ServiCategory {
  final IconData icon;
  final String label;
  final Color color;

  const ServiCategory({
    required this.icon,
    required this.label,
    required this.color,
  });
}

  const List<ServiCategory> kCategories = [
    ServiCategory(icon: Icons.content_cut,            label: 'Beleza',  color: AppColors.secondary),
    ServiCategory(icon: Icons.favorite_outline,       label: 'Saúde',   color: AppColors.error),
    ServiCategory(icon: Icons.build_outlined,         label: 'Reparos', color: AppColors.primary),
    ServiCategory(icon: Icons.menu_book_outlined,     label: 'Aulas',   color: AppColors.success),
    ServiCategory(icon: Icons.pets,                   label: 'Pets',    color: AppColors.secondary),
    ServiCategory(icon: Icons.monitor_heart_outlined, label: 'Tech',    color: AppColors.primary),
    ServiCategory(icon: Icons.cleaning_services,      label: 'Limpeza', color: AppColors.textMuted),
    ServiCategory(icon: Icons.more_horiz,             label: 'Outros',  color: AppColors.textMuted),
  ];

  class FeaturedService {
    final int id;
    final String name;
    final String category;
    final double rating;
    final int reviews;
    final String distance;
    final String imageUrl;
    final String badge;

    const FeaturedService({
      required this.id,
      required this.name,
      required this.category,
      required this.rating,
      required this.reviews,
      required this.distance,
      required this.imageUrl,
      required this.badge,
  });
}

const List<FeaturedService> kFeatured = [
  FeaturedService(
      id: 1,
      name: 'Studio Joana Cabelos',
      category: 'Beleza',
      rating: 4.9,
      reviews: 128,
      distance: '0.8 km',
      imageUrl: 'https://images.unsplash.com/photo-1556740758-90de374c12ad?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400',
      badge: 'Destaque',
  ),
  FeaturedService(
      id: 2,
      name: 'Eletric Fix',
      category: 'Reparos',
      rating: 4.7,
      reviews: 89,
      distance: '1.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1746723378067-83a345ff3160?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400',
      badge: 'Top',
  ),
  FeaturedService(
      id: 3,
      name: 'Clínica Bem Estar',
      category: 'Saúde',
      rating: 4.8,
      reviews: 203,
      distance: '2.0 km',
      imageUrl: 'https://images.unsplash.com/photo-1750263147723-ebd447918d89?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400',
      badge: 'Destaque',
  ),
];

  class NearbyService {
    final int id;
    final String name;
    final String service;
    final double rating;
    final String location;
    final String category;
    final Color catColor;
    final String imageUrl;

    const NearbyService({
      required this.id,
      required this.name,
      required this.service,
      required this.rating,
      required this.location,
      required this.category,
      required this.catColor,
      required this.imageUrl,
  });
}

const List<NearbyService> kNearby = [
  NearbyService(
      id: 1,
      name: 'Barba & Cia',
      service: 'Barbearia premium',
      rating: 4.8,
      location: 'Centro',
      category: 'Beleza',
      catColor: AppColors.secondary,
      imageUrl:  'https://images.unsplash.com/photo-1737574821698-862e77f044c1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=300'
  ),
  NearbyService(
      id: 2,
      name: 'TechReparo',
      service: 'Conserto de celulares',
      rating: 4.6,
      location: 'Pinheiros',
      category: 'Tech',
      catColor: AppColors.primary,
      imageUrl: 'https://images.unsplash.com/photo-1778692258270-bc0e80e975c0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=300',
  ),
  NearbyService(
      id: 3,
      name: 'Yoga & Paz',
      service: 'Aulas de yoga de meditação',
      rating: 4.9,
      location: 'Vila Madalena',
      category: 'Saúde',
      catColor: AppColors.error,
      imageUrl: 'https://images.unsplash.com/photo-1769636929131-56dd60238266?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=300',
  ),
  NearbyService(
      id: 4,
      name: 'PetCare Plus',
      service: 'Banho e tosa',
      rating: 4.7,
      location: 'Moema',
      category: 'Pets',
      catColor: AppColors.secondary,
      imageUrl: 'https://images.unsplash.com/photo-1771898343647-bd979ad8cca5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=300',
  ),
];