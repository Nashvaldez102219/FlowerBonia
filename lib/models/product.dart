class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double rating;
  final String sold;
  final int discount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.rating = 4.8,
    this.sold = '1K+ sold',
    this.discount = 0,
  });
}

const products = <Product>[
  Product(id: 'p1', name: 'Rosy Tulip Pot', description: 'Bright pink tulips in a clean white pot.', image: 'assets/images/img-1.jpg', price: 499, rating: 4.9, sold: '3K+ sold', discount: 12),
  Product(id: 'p2', name: 'Sunshine Tulips', description: 'Cheerful mixed tulips with sunny accents.', image: 'assets/images/img-2.jpg', price: 549, rating: 4.8, sold: '2K+ sold', discount: 10),
  Product(id: 'p3', name: 'Red Tulip Vase', description: 'Deep red tulips in a simple elegant vase.', image: 'assets/images/img-3.jpg', price: 459, rating: 4.9, sold: '5K+ sold', discount: 15),
  Product(id: 'p4', name: 'Flame Tulips', description: 'Orange-red tulips in a clear glass vase.', image: 'assets/images/img-4.jpg', price: 429, rating: 4.7, sold: '1K+ sold', discount: 8),
  Product(id: 'p5', name: 'White Tulip Calm', description: 'Soft white tulips for thoughtful gifts.', image: 'assets/images/img-5.jpg', price: 479, rating: 4.8, sold: '900+ sold', discount: 5),
  Product(id: 'p6', name: 'Blush Signature', description: 'Premium blush-pink signature flower arrangement.', image: 'assets/images/img-6.png', price: 699, rating: 4.9, sold: '4K+ sold', discount: 18),
  Product(id: 'p7', name: 'Ruby Romance', description: 'Luxurious red bouquet for romantic occasions.', image: 'assets/images/img-7.jpg', price: 799, rating: 4.9, sold: '6K+ sold', discount: 20),
  Product(id: 'p8', name: 'Warm Spring Vase', description: 'Warm-toned tulips in a textured clear vase.', image: 'assets/images/img-8.jpg', price: 489, rating: 4.7, sold: '1K+ sold', discount: 7),
  Product(id: 'p9', name: 'Scarlet Garden', description: 'Full red tulips in a rustic white garden pot.', image: 'assets/images/img-9.jpg', price: 529, rating: 4.8, sold: '2K+ sold', discount: 11),
  Product(id: 'p10', name: 'Classic Crimson', description: 'Classic crimson tulips in a modern white vase.', image: 'assets/images/img-10.png', price: 569, rating: 4.8, sold: '2K+ sold', discount: 9),
  Product(id: 'p11', name: 'Peach Garden Roses', description: 'Soft peach-pink garden roses for celebrations.', image: 'assets/images/img-11.png', price: 749, rating: 5.0, sold: '3K+ sold', discount: 14),
];
