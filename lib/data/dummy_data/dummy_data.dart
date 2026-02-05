import 'package:equatable/equatable.dart';

class DummyDashboardModel extends Equatable {
  final String image;
  final String name;

  const DummyDashboardModel({required this.name, required this.image});

  @override
  List<Object?> get props => [image, name];
}

class CategoryNameId extends Equatable {
  final int id;
  final String name;

  const CategoryNameId({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

final List<CategoryNameId> categoryId = [
  const CategoryNameId(id: 1, name: 'Electronics'),
  const CategoryNameId(id: 2, name: 'Game'),
  const CategoryNameId(id: 3, name: 'Mobile'),
  const CategoryNameId(id: 4, name: 'Life Style'),
  const CategoryNameId(id: 5, name: 'Babies & Toys'),
  const CategoryNameId(id: 6, name: 'Bike'),
  const CategoryNameId(id: 7, name: "Men's Fasion"),
  const CategoryNameId(id: 8, name: 'Woman Fasion'),
  const CategoryNameId(id: 9, name: 'Talevision'),
  const CategoryNameId(id: 10, name: 'Accessories'),
  const CategoryNameId(id: 11, name: 'John Doe'),
];

class ProductStatusModel extends Equatable {
  final String title;
  final String id;

  const ProductStatusModel({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}

final List<ProductStatusModel> productStatusModel = [
  const ProductStatusModel(id: '1', title: 'Active'),
  const ProductStatusModel(id: '0', title: 'Inactive'),
];

// class DemoCurrencies extends Equatable {
//   final int id;
//   final String currencyName;
//   final String countryCode;
//   final String currencyCode;
//   final String currencyIcon;
//   final String isDefault;
//   final double currencyRate;
//   final String currencyPosition;
//   final int status;
//
//   const DemoCurrencies({
//     required this.id,
//     required this.currencyName,
//     required this.countryCode,
//     required this.currencyCode,
//     required this.currencyIcon,
//     required this.isDefault,
//     required this.currencyRate,
//     required this.currencyPosition,
//     required this.status,
//   });
//
//   @override
//   List<Object> get props {
//     return [
//       id,
//       currencyName,
//       countryCode,
//       currencyCode,
//       currencyIcon,
//       isDefault,
//       currencyRate,
//       currencyPosition,
//       status,
//     ];
//   }
// }

// final List<CurrenciesModel> demoCurrencies = [
//   const CurrenciesModel(
//     id: 1,
//     currencyName: '\$-USD',
//     currencyCode: 'USD',
//     countryCode: 'USD',
//     currencyIcon: '\$',
//     isDefault: 'Yes',
//     currencyPosition: 'left',
//     status: 1,
//     currencyRate: 1.0,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 2,
//     currencyName: '€-Euro',
//     currencyCode: 'EUR',
//     countryCode: 'EU',
//     currencyIcon: '€',
//     isDefault: 'No',
//     currencyPosition: 'right',
//     status: 1,
//     currencyRate: 0.93,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 3,
//     currencyName: '£-GBP',
//     currencyCode: 'GBP',
//     countryCode: 'GB',
//     currencyIcon: '£',
//     isDefault: 'No',
//     currencyPosition: 'left',
//     status: 1,
//     currencyRate: 0.74,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 4,
//     currencyName: '¥-Yen',
//     currencyCode: 'JPY',
//     countryCode: 'JP',
//     currencyIcon: '¥',
//     isDefault: 'No',
//     currencyPosition: 'right',
//     status: 1,
//     currencyRate: 110.0,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 5,
//     currencyName: '₹-INR',
//     currencyCode: 'INR',
//     countryCode: 'IN',
//     currencyIcon: '₹',
//     isDefault: 'No',
//     currencyPosition: 'left',
//     status: 1,
//     currencyRate: 73.5,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 6,
//     currencyName: '₽-RUB',
//     currencyCode: 'RUB',
//     countryCode: 'RU',
//     currencyIcon: '₽',
//     isDefault: 'No',
//     currencyPosition: 'right',
//     status: 1,
//     currencyRate: 73.5,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 7,
//     currencyName: '฿-Baht',
//     currencyCode: 'THB',
//     countryCode: 'TH',
//     currencyIcon: '฿',
//     isDefault: 'No',
//     currencyPosition: 'left',
//     status: 1,
//     currencyRate: 32.8,
//     createdAt: '',
//     updatedAt: '',
//   ),
//   const CurrenciesModel(
//     id: 11,
//     currencyName: '৳-BDT',
//     currencyCode: 'BDT',
//     countryCode: 'BD',
//     currencyIcon: '৳',
//     isDefault: 'No',
//     currencyPosition: 'right',
//     status: 1,
//     currencyRate: 109.76,
//     createdAt: '',
//     updatedAt: '',
//   ),
// ];


class DummyModel{
  final int id;
  final String name;
  final String value;
  final String image;
  final String time;
  final int unreadMsg;
  DummyModel(this.id,this.name, this.value,[this.image = '',this.time = '',this.unreadMsg = 0]);
}

class DemoMessage  {
  final int id;
  final String message;
  final String sendBy;
  const DemoMessage({
    required this.id,
    required this.message,
    required this.sendBy,
  });

  DemoMessage copyWith({
    int? id,
    String? message,
    String? sendBy,
  }) {
    return DemoMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      sendBy: sendBy ?? this.sendBy,
    );
  }
}


final List<DemoMessage> dummyMessages = [
  const DemoMessage(id: 1, message: "Hi! Is this item still available?", sendBy: "user"),
  const DemoMessage(id: 2, message: "Yes, it's available. Would you like to place an order?", sendBy: "seller"),
  const DemoMessage(id: 3, message: "Can you tell me the condition of the product?", sendBy: "user"),
  const DemoMessage(id: 4, message: "It's brand new and comes with a 1-year warranty.", sendBy: "seller"),
  const DemoMessage(id: 5, message: "Great! Can you deliver by tomorrow?", sendBy: "user"),
  const DemoMessage(id: 6, message: "Yes, we offer next-day delivery in your area.", sendBy: "seller"),
  const DemoMessage(id: 7, message: "Perfect. I’ll place the order now. Thanks!", sendBy: "user"),
  const DemoMessage(id: 8, message: "You're welcome! Let us know if you need anything else.", sendBy: "seller"),
  const DemoMessage(id: 9, message: "Just placed the order. Can you confirm?", sendBy: "user"),
  const DemoMessage(id: 10, message: "Order received! We’ll process it shortly.", sendBy: "seller"),
  const DemoMessage(id: 11, message: "Awesome. Can I get the tracking info once shipped?", sendBy: "user"),
  const DemoMessage(id: 12, message: "Of course. You’ll receive an update via message.", sendBy: "seller"),
  const DemoMessage(id: 13, message: "Do you have this in another color?", sendBy: "user"),
  const DemoMessage(id: 14, message: "Yes, it’s also available in black and blue.", sendBy: "seller"),
  const DemoMessage(id: 15, message: "Cool! I’ll take the black one next time.", sendBy: "user"),
  const DemoMessage(id: 16, message: "No problem. We’ll keep it ready for you.", sendBy: "seller"),
  const DemoMessage(id: 17, message: "What’s your return policy?", sendBy: "user"),
  const DemoMessage(id: 18, message: "You can return within 7 days if the item is unused.", sendBy: "seller"),
  const DemoMessage(id: 19, message: "Got it. Thanks for the quick replies!", sendBy: "user"),
  const DemoMessage(id: 20, message: "Anytime! Have a great day!", sendBy: "seller"),
];

List<DummyModel> dummyChatList = [
  DummyModel(9, 'Mohammad Ali', 'Can you send the file? so that i can make changes from you file', 'https://i.pravatar.cc/150?img=10', 'Fri',4),
  DummyModel(10, 'Kayum Mursalin', 'Can you send the file?', 'https://i.pravatar.cc/150?img=12', '2:33 PM', 2),
  DummyModel(1, 'Ayesha Siddiqua', 'I’ll call you later.', 'https://i.pravatar.cc/150?img=1', '10:45 AM'),
  DummyModel(2, 'Tanvir Rahman', 'Where are you?', 'https://i.pravatar.cc/150?img=2', '09:30 AM',1),
  DummyModel(3, 'Rifat Mahmud', 'Thanks bro!', 'https://i.pravatar.cc/150?img=3', 'Yesterday',3),
  DummyModel(4, 'Nusrat Jahan', 'Let me check and get back to you.', 'https://i.pravatar.cc/150?img=4', 'Mon'),
  DummyModel(5, 'Shahriar Hossain', 'Happy birthday! 🎉', 'https://i.pravatar.cc/150?img=5', 'Sun'),
  DummyModel(6, 'Mahiya Mim', 'Okay, noted.', 'https://i.pravatar.cc/150?img=6', 'Sat',3),
  DummyModel(7, 'Hasan Kabir', 'Let’s meet at 5 PM.', 'https://i.pravatar.cc/150?img=7', 'Fri'),
  DummyModel(8,'Salma Akter', 'Can you send the file?', 'https://i.pravatar.cc/150?img=8', 'Thu'),
];

