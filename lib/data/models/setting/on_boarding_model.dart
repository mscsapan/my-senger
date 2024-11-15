import 'package:equatable/equatable.dart';

class OnBoardingModel extends Equatable {
  final String image;
  final String name;
  final String subtitle;

  const OnBoardingModel(
      {required this.image, required this.name, required this.subtitle});

  @override
  List<Object?> get props => [image, name];
}

// final List<OnBoardingModel> onBoardingList = [
//   const OnBoardingModel(
//       image: KImages.onBoarding01, name: Language.onBoardingTitle01,subtitle: Language.onBoardingSubtitle01),
//   const OnBoardingModel(
//       image: KImages.onBoarding02, name: Language.onBoardingTitle02,subtitle: Language.onBoardingSubtitle02),
//   const OnBoardingModel(
//       image: KImages.onBoarding03, name: Language.onBoardingTitle03,subtitle: Language.onBoardingSubtitle03),
// ];
