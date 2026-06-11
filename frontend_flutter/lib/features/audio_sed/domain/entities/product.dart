import 'package:equatable/equatable.dart';

enum ProductIconType { pill, siro, spray, droplet }

class Product extends Equatable {
  final String name;
  final String brand;
  final String price;
  final String unit;
  final ProductIconType iconType;
  final String desc;
  final String? tag;
  final bool isWarningCard; // True if it is a warning for children/infants

  const Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.unit,
    required this.iconType,
    required this.desc,
    this.tag,
    this.isWarningCard = false,
  });

  @override
  List<Object?> get props => [
        name,
        brand,
        price,
        unit,
        iconType,
        desc,
        tag,
        isWarningCard,
      ];

  // Mock Products Database matching app.js
  static const Map<String, List<Product>> mockProducts = {
    'dry': [
      Product(
        name: 'Viên ngậm thảo dược bổ phế Bảo Thanh',
        brand: 'Hoa Linh (Việt Nam)',
        price: '36.000đ',
        unit: 'Hộp 5 vỉ x 4 viên',
        iconType: ProductIconType.pill,
        desc: 'Bổ phế, trừ ho khan, dịu họng, loãng đờm',
        tag: 'Bán chạy nhất',
      ),
      Product(
        name: 'Siro ho thảo dược Prospan 100ml',
        brand: 'Engelhard (Đức)',
        price: '82.000đ',
        unit: 'Chai 100ml',
        iconType: ProductIconType.siro,
        desc: 'Làm loãng dịch nhầy, dịu phế quản co thắt',
        tag: 'Dược sĩ khuyên dùng',
      ),
      Product(
        name: 'Xịt họng sát khuẩn Keo Ong Propobee',
        brand: 'DK Pharma (Việt Nam)',
        price: '115.000đ',
        unit: 'Lọ 15ml',
        iconType: ProductIconType.spray,
        desc: 'Sát khuẩn tại chỗ, dịu nhanh cơn ho kích ứng',
        tag: 'Công nghệ mới',
      ),
    ],
    'phlegm': [
      Product(
        name: 'Siro ho trẻ em Prospan',
        brand: 'Engelhard (Đức)',
        price: '82.000đ',
        unit: 'Chai 100ml',
        iconType: ProductIconType.siro,
        desc: 'Chiết xuất lá thường xuân hỗ trợ long đờm hiệu quả',
        tag: 'Nhập khẩu Đức',
      ),
      Product(
        name: 'Viên sủi long đờm nhầy ACC200',
        brand: 'Sandoz (Đức)',
        price: '68.000đ',
        unit: 'Hộp 20 viên',
        iconType: ProductIconType.pill,
        desc: 'Làm loãng đờm đặc trong các bệnh phế quản cấp & mạn',
        tag: 'Người lớn khuyên dùng',
      ),
      Product(
        name: 'Dung dịch súc họng sát khuẩn Betadine 1%',
        brand: 'Mundipharma (Thụy Sĩ)',
        price: '72.000đ',
        unit: 'Chai 125ml',
        iconType: ProductIconType.spray,
        desc: 'Diệt khuẩn hầu họng, ngăn ngừa nhiễm trùng thứ phát',
        tag: 'Bác sĩ khuyên dùng',
      ),
    ],
    'allergic': [
      Product(
        name: 'Thuốc chống dị ứng giảm kích ứng ngứa cổ Telfast 180mg',
        brand: 'Sanofi (Pháp)',
        price: '90.000đ',
        unit: 'Hộp 1 vỉ x 10 viên',
        iconType: ProductIconType.pill,
        desc: 'Kháng histamin thế hệ mới, giảm ngứa họng và ho dị ứng',
        tag: 'Thương hiệu Pháp',
      ),
      Product(
        name: 'Viên sủi tăng sức đề kháng Redoxon Double Action',
        brand: 'Bayer (Đức)',
        price: '75.000đ',
        unit: 'Tuýp 10 viên',
        iconType: ProductIconType.pill,
        desc: 'Bổ sung Vitamin C & Kẽm tăng miễn dịch đường hô hấp',
        tag: 'Bảo vệ sức khỏe',
      ),
    ],
    'irritant': [
      Product(
        name: 'Viên ngậm giảm ho ngứa rát họng Strepsils Cool',
        brand: 'Reckitt (Anh)',
        price: '34.000đ',
        unit: 'Hộp 2 vỉ x 12 viên',
        iconType: ProductIconType.pill,
        desc: 'Giảm đau rát họng, giảm ho kích ứng do nhiệt độ, máy lạnh',
        tag: 'Phổ biến',
      ),
      Product(
        name: 'Dung dịch xịt vệ sinh mũi họng nước muối biển sâu Xịt Spray',
        brand: 'Pharmed (Việt Nam)',
        price: '45.000đ',
        unit: 'Lọ 75ml',
        iconType: ProductIconType.droplet,
        desc: 'Rửa trôi khói bụi và các chất kích thích niêm mạc hô hấp',
        tag: 'Khuyên dùng hàng ngày',
      ),
    ],
    'whooping': [
      Product(
        name: 'Siro ho bổ phế Nam Hà Chỉ Khái Lộ',
        brand: 'Dược Nam Hà (Việt Nam)',
        price: '32.000đ',
        unit: 'Chai 125ml',
        iconType: ProductIconType.siro,
        desc: 'Thảo dược trị ho lâu ngày, ho rít phế quản',
        tag: 'Y học cổ truyền',
      ),
    ]
  };

  // Get matching products based on coughType and subject (age group)
  static List<Product> getSuggestedProducts(String coughType, String subject) {
    final list = mockProducts[coughType] ?? mockProducts['dry']!;
    final isPediatric = (subject == 'child' || subject == 'infant');

    if (!isPediatric) return list;

    // Map pediatric adaptations
    return list.map((p) {
      if (p.name.contains('Prospan')) {
        return Product(
          name: 'Siro ho trẻ em Prospan (Đức)',
          brand: p.brand,
          price: p.price,
          unit: p.unit,
          iconType: p.iconType,
          desc: p.desc,
          tag: 'Khuyên dùng cho bé',
        );
      } else if (p.name.contains('Bảo Thanh')) {
        return Product(
          name: 'Siro bổ phế Bảo Thanh (Chai Trẻ Em)',
          brand: p.brand,
          price: p.price,
          unit: p.unit,
          iconType: ProductIconType.siro,
          desc: p.desc,
          tag: 'Thảo dược dịu ngọt',
        );
      } else if (p.name.contains('ACC200') || p.name.contains('Telfast')) {
        // Warning card for kids
        return Product(
          name: p.name,
          brand: p.brand,
          price: p.price,
          unit: p.unit,
          iconType: p.iconType,
          desc: 'Sản phẩm này chủ yếu cho người lớn. Cần liên hệ Dược sĩ Long Châu để tư vấn liều dùng & thay thế thuốc siro phù hợp với trẻ nhỏ.',
          tag: 'Cảnh báo',
          isWarningCard: true,
        );
      }
      return p;
    }).toList();
  }
}
