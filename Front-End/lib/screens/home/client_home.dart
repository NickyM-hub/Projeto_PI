import 'package:flutter/material.dart';
import 'package:projeto_pi/core/theme/app_colors.dart';
import '../core/theme/app_colors.dart';
import 'client_home_data.dart';

class ClientHome extends StatelessWidget {
  const ClientHome ({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

  class _ClientHomeState extends State<ClientHome> {
    int _activeNav = 0; // 0=home 1=buscar 2=agendamentos 3=cupons 4=perfil

    void _go(String route) => Navigator.pushNamed(context, route);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildCategories()),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(child: _buildFeatured()),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(child: _buildNearby()),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),

            _buildBottomNav(),
          ],
        ),
      );
    }

    Widget _buildHeader() {
      return Container(
        color: AppColors.surface,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.primary),

                const SizedBox(width: 4),
                const Text(
                  'São Paulo, SP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 14, color: AppColors.textMuted),
                const Spacer(),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined,
                            size: 20, color: AppColors.textPrimary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                    onPressed: () => _go('/chat'),
                    icon: const Icon(Icons.chat_bubble_outline,
                        size: 20, color: AppColor.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            
              Container(
                padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Buscar serviço ou profissional...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

    Widget _buildCategories() {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorias',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _CategoryChip(category: cat),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

      Widget _buildFeatured() {
        return Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mais bem avaliados',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 230,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                    itemCount: kFeatured.length,
                    separatorBuilder: (_,__) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _FeaturedCard(
                      item: kFeatured[i],
                      onTap: () => _go('/entrepreneur-profile'),
                    ),
                  ),
                )
              ],
            ),
          );
        }

        Widget _buildNearby() {
          return Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Perto de você',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver mapa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SidedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kNearby.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                    ),
                    itemBuilder: (_, i) => _NearbyCard(
                      item: kNearby[i],
                      onTap: () => _go('/entrepreneur-profile'),
                    ),
                  ),
                ],
              ),
            );
          }

          Widget _buildBottomNav() {
            final items = [
              (icon: Icons.home_outlined,             label: 'Home',        route:''),
              (icon: Icons.search,                    label: 'Buscar',      route:'/notfications'),
              (icon: Icons.calendar_today_outlined,   label: 'Agendamento', route:'/my-bookings'),
              (icon: Icons.confirmation_num_outlined, label: 'Cupons',      route:''),
              (icon: Icons.person_outline,            label: 'Perfil',      route:'/client-profile'),
            ];

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: List.generate(items.length, (i) {
                  final active = i == _activeNav;
                  final item = items[i];
                  return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _activeNav = i);
                          if (item.route.isNotEmpty) _go(item.route);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                            padding: const EdgeInsetsGeometry.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: active
                                    ? AppColors.primary
                                    : AppColors.textMuted
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                    color: active
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }
            }

  class _CategoryChip extends StatelessWidget {
    final ServiceCategory category;
    const _CategoryChip({required this.category});

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child:  Icon(category.icon, size: 22, color: category.color),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }
  }

  class _FeaturedCard extends StatelessWidget {
    final FeaturedService item;
    final VoidCallback onTap;
    const _FeaturedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.80),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  item.imageUrl,
                  width: 180,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    color: AppColors.primaryBg,
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsetsGeometry.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.badge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star,
                            size: 11,
                            color: AppColors.secondary),
                          const SizedBox(width: 2),
                          Text(
                            '${item.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${item.reviews})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.distance,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    class _NearbyCard extends StatelessWidget {
      final NearbyService item;
      final VoidCallback onTop;
      const _NearbyCard({required this.item, required this.onTop});

      @override
      Widget build(BuildContext context) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 90,
                    color: AppColors.primaryBg,
                    child: const Center(
                      child: Icon(
                          Icons.image_outlined,
                          color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Container(
                           padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                                color: item.catColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.service,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                  size: 10,
                                  color: AppColors.secondary),
                                const SizedBox(width: 2),
                                Text(
                                  '${item.rating}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.location_on,
                                    size: 9,
                                    color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Expanded(
                                    child: Text(
                                      item.location,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }