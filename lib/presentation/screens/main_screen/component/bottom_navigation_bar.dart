import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/auth/login_state_model.dart';
import '../../../../logic/bloc/login/login_bloc.dart';
import '../../../utils/constraints.dart';
import '../../../utils/k_images.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import 'main_controller.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainController();
    return Container(
      height: Platform.isAndroid ? 86 : 110,
      decoration:  BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0.0, 4.0),
            spreadRadius: 0.0,
            blurRadius: 40.0,
            color:  Color(0xFF000000).withOpacity(0.1),
            blurStyle: BlurStyle.outer,

          ),
        ]
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: StreamBuilder(
          initialData: 0,
          stream: controller.naveListener.stream,
          builder: (_, AsyncSnapshot<int> index) {
            int selectedIndex = index.data ?? 0;
            return BlocBuilder<LoginBloc, LoginStateModel>(
              builder: (context, state) {
                // debugPrint('isDealer-from-main ${state.isDealer}');
                return BottomNavigationBar(
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedLabelStyle:
                  const TextStyle(fontSize: 14, color: blackColor),
                  unselectedLabelStyle:
                  const TextStyle(fontSize: 14, color: paraColor),
                  items: <BottomNavigationBarItem>[
                    if(state.isDealer)...[
                      BottomNavigationBarItem(
                        tooltip: 'Dashboard',
                        icon: _navIcon(KImages.dashboard),
                        activeIcon: _navIcon(KImages.dashboardActive),
                        label: 'Dashboard',
                      ),

                      BottomNavigationBarItem(
                        tooltip: 'Submit Ads',
                        icon: _navIcon(KImages.submitAdd),
                        activeIcon: _navIcon(KImages.submitAddActive),
                        label: 'Submit Ads',
                      ),
                    ]else...[
                      BottomNavigationBarItem(
                        tooltip: 'Home',
                        icon: _navIcon(KImages.home),
                        activeIcon: _navIcon(KImages.homeActive),
                        label: 'Home',
                      ),
                      // BottomNavigationBarItem(
                      //   tooltip: 'Quote',
                      //   icon: _navIcon(KImages.quote),
                      //   activeIcon: _navIcon(KImages.quoteActive),
                      //   label: 'Quote',
                      // ),
                      BottomNavigationBarItem(
                        tooltip: 'Categories',
                        icon: _navIcon(KImages.category),
                        activeIcon: _navIcon(KImages.categoryActive),
                        label: 'Categories',
                      ),
                      // BottomNavigationBarItem(
                      //   tooltip: 'Favourite',
                      //   icon: _navIcon(KImages.favourite),
                      //   activeIcon: _navIcon(KImages.favouriteActive),
                      //   label: 'Favourite',
                      // ),
                    ],
                    BottomNavigationBarItem(
                      tooltip: 'Quote',
                      icon: _navIcon(KImages.quote),
                      activeIcon: _navIcon(KImages.quoteActive),
                      label: 'Quote',
                    ),
                    BottomNavigationBarItem(
                      tooltip: 'More',
                      activeIcon: _navIcon(KImages.moreActive),
                      icon: _navIcon(KImages.more),
                      label: 'More',
                    ),
                  ],
                  // type: BottomNavigationBarType.fixed,
                  currentIndex: selectedIndex,
                  onTap: (int index) {
                    controller.naveListener.sink.add(index);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _navIcon(String path) => Padding(
      padding: Utils.symmetric(v: 0.0, h: 0.0), child: CustomImage(path:path));
}
