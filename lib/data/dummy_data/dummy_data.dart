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
