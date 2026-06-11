import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/recommendation_result.dart';

class RecommendationPage extends StatelessWidget {
  final RecommendationResult result;

  const RecommendationPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final classification = result.classification;

    // Load matched local products database
    final suggestedProducts = Product.getSuggestedProducts(
      classification.coughType,
      classification.subject,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('KẾT QUẢ KHUYẾN NGHỊ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Red Flag Alerts / Warnings
              if (result.warnings.isNotEmpty) _buildWarningsList(context),

              // Patient Profile Clinical Summary
              _buildClinicalSummaryCard(context),

              // Main Medical Recommendations (Home Care, Food, OTC)
              _buildRecommendationsList(context),

              // OTC Drugs & Products recommended section
              if (suggestedProducts.isNotEmpty)
                _buildProductsSection(context, suggestedProducts),

              // Bottom note
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tham khảo Dược sĩ tại quầy thuốc trước khi sử dụng để có liều lượng chính xác.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningsList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      spacing: 8,
      children: result.warnings.map((warning) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFFEF2F2), // Red 50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.red.withValues(alpha: 0.4) : const Color(0xFFFCA5A5)), // Red 300
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  warning,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.red.shade300 : const Color(0xFFB91C1C), // Red 700
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClinicalSummaryCard(BuildContext context) {
    final cl = result.classification;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              children: [
                const Text('📝', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Thông tin chẩn đoán',
                  style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            
            // Grid of parameters
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildSummaryTile('Chẩn đoán ho', cl.coughTypeVi, isDark ? theme.colorScheme.onSurface : Colors.black87),
                _buildSummaryTile('Mức độ ho', cl.severity.toUpperCase(), isDark ? theme.colorScheme.secondary : AppColors.accentOrange),
                _buildSummaryTile('Đối tượng', cl.subjectVi, isDark ? theme.colorScheme.onSurface : Colors.black87),
                _buildSummaryTile('Thời gian ho', '${cl.durationVi} (${cl.durationDesc})', isDark ? theme.colorScheme.onSurface : Colors.black87),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      spacing: 12,
      children: result.recommendations.map((rec) {
        final isSeeDoctor = rec.category == 'see_doctor';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSeeDoctor
                ? (isDark ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFFEF2F2).withValues(alpha: 0.5))
                : (isDark ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSeeDoctor
                  ? (isDark ? Colors.red.withValues(alpha: 0.4) : const Color(0xFFFECACA))
                  : (isDark ? theme.colorScheme.outline : Colors.grey.withValues(alpha: 0.15)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                children: [
                  Text(rec.categoryIcon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    rec.categoryLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSeeDoctor
                          ? (isDark ? Colors.red.shade300 : const Color(0xFFB91C1C))
                          : (isDark ? theme.colorScheme.onSurface : const Color(0xFF111827)),
                    ),
                  ),
                ],
              ),
              
              // Bullet points list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: rec.items.map((item) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? theme.colorScheme.onSurfaceVariant : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductsSection(BuildContext context, List<Product> products) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          children: [
            const Text('🛒', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Sản phẩm khuyến nghị điều trị',
              style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        
        // Products list
        Column(
          spacing: 12,
          children: products.map((product) {
            return _buildProductCard(context, product);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product p) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (p.isWarningCard) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.amber.withValues(alpha: 0.15) : const Color(0xFFFEF3C7), // Amber 50
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.amber.withValues(alpha: 0.4) : const Color(0xFFFDE68A)), // Amber 200
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.amber.shade200 : const Color(0xFF92400E), // Amber 800
                    ),
                  ),
                  Text(
                    p.desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.amber.shade300 : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.colorScheme.outline : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: isDark ? null : const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.primaryContainer : AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getProductIcon(p.iconType),
              color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.primaryContainer : AppColors.primaryBlueLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.brand.toUpperCase(),
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    if (p.tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.secondaryContainer : AppColors.accentOrangeLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.tag!,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: isDark ? theme.colorScheme.secondary : AppColors.accentOrange,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? theme.colorScheme.onSurface : const Color(0xFF111827),
                  ),
                ),
                Text(
                  '${p.unit} | ${p.desc}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.grey,
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.price,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? theme.colorScheme.secondary : AppColors.accentOrange,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm "${p.name}" vào giỏ hàng!'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                        foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Chọn mua', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(ProductIconType type) {
    switch (type) {
      case ProductIconType.pill:
        return Icons.medication;
      case ProductIconType.siro:
        return Icons.vaccines;
      case ProductIconType.spray:
        return Icons.cleaning_services_rounded;
      case ProductIconType.droplet:
        return Icons.opacity;
    }
  }
}
