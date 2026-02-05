import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_senger/data/models/auth/auth_state_model.dart';

import '../../../logic/cubit/auth/auth_cubit.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_form.dart';

import '../../widgets/loading_widget.dart';
import '../authentication/change_password_screen.dart';
import '/presentation/utils/k_images.dart';
import 'package:flutter/material.dart';

import '../../routes/route_names.dart';
import '../../utils/constraints.dart';
import '../../utils/utils.dart';
import '../../widgets/circle_image.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthCubit profileCubit;

  @override
  void initState() {
    super.initState();
    profileCubit = context.read<AuthCubit>();
  }

  @override
  Widget build(BuildContext context) {
    // final loginBloc = context.read<LoginBloc>();
    // debugPrint('email-pass ${loginBloc.localUserInfo?.email}');
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: CustomAppBar(
        title: 'My Account',
        visibleLeading: false,
      ),
      body: ListView(
        padding: Utils.all(value: 16.0),
        children: [
          BlocBuilder<AuthCubit, AuthStateModel>(
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    padding: Utils.all(value: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: whiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleImage(
                      image: Utils.imagePath(state.updateInfo?.image),
                      // image: 'https://randomuser.me/api/portraits/women/50.jpg',
                      type: ImageType.circle,
                    ),
                  ),
                  CustomText(
                    text:
                        '${state.updateInfo?.firstName ?? 'Guest'} ${state.updateInfo?.lastName ?? 'User'}',
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                  CustomText(
                    text: state.updateInfo?.signUpEmail ?? 'guest@email.com',
                    fontSize: 14.0,
                    color: grayColor,
                  ),
                  Utils.verticalSpace(16.0),
                ],
              );
            },
          ),

          _buildCardSection([
            AccountItem(
              icon: Icon(Icons.person_outline),
              title: "Manage Account",
              onTap: () {
                NavigationService.navigateTo(RouteNames.updateProfile);
              },
            ),
            AccountItem(
              icon: Icon(Icons.lock_outline),
              title: "Change Password",
              onTap: () {
                //context.read<LoginBloc>().add(LoginClearEvent());
                //NavigationService.navigateTo(RouteNames.changePasswordScreen);
              },
            ),

            AccountItem(
              icon: Icon(Icons.compare_arrows_outlined),
              title: "Compare Product",
              isAuth: false,
              onTap: () {
                //NavigationService.navigateTo(RouteNames.compareScreen);
              },
            ),
            AccountItem(
              icon: Icon(Icons.shopping_bag_outlined),
              title: "My Orders",
              onTap: () {
                //NavigationService.navigateTo(RouteNames.orderScreen, arguments: true);
              },
            ),
            AccountItem(
              icon: Icon(Icons.confirmation_number_outlined),
              title: "My Points and Rewards",
              onTap: () {
                //NavigationService.navigateTo(RouteNames.rewardsScreen);
                // NavigationService.navigateTo(RouteNames.myMilestonesScreen);
              },
            ),

            AccountItem(
              icon: Icon(Icons.card_giftcard_outlined),
              title: "My Referrals",
              onTap: () {
                // NavigationService.navigateTo(RouteNames.referralScreen);
                // NavigationService.navigateTo(RouteNames.myMilestonesScreen);
              },
            ),

            AccountItem(
              icon: Icon(Icons.workspace_premium_outlined),
              title: "Be VIP Member",
              isAuth: false,
              onTap: () {
                //NavigationService.navigateTo(RouteNames.becomeVipMemberScreen);
                // NavigationService.navigateTo(RouteNames.myMilestonesScreen);
              },
            ),
          ]),

          Utils.verticalSpace(12.0),
          //
          // _buildCardSection([
          //   AccountItem(
          //     icon: Icon(Icons.reviews_outlined),
          //     title: "Reviews",
          //     onTap: () {
          //       NavigationService.navigateTo(RouteNames.reviewScreen);
          //     },
          //   ),
          //   AccountItem(
          //     icon: Icon(Icons.live_help_outlined),
          //     title: "Need Help",
          //     onTap: () {
          //       NavigationService.navigateTo(RouteNames.contactUsScreen);
          //     },
          //   ),
          // ]),
          // Utils.verticalSpace(12.0),
          _buildCardSection([
            // AccountItem(icon:Icon(Icons.info_outline),title: 'About us',onTap: (){
            //   NavigationService.navigateTo(RouteNames.aboutUsScreen);
            // },),
            AccountItem(
              icon: Icon(Icons.privacy_tip_outlined),
              title: 'Privacy policy',
              isAuth: false,
              onTap: () {
                // NavigationService.navigateTo(RouteNames.privacyPolicyScreen, arguments: 'policy');
              },
            ),
            AccountItem(
              icon: Icon(Icons.article_outlined),
              title: 'Terms & Condition',
              isAuth: false,
              onTap: () {
                // NavigationService.navigateTo(RouteNames.privacyPolicyScreen, arguments: 'terms');
              },
            ),
            AccountItem(
              icon: Icon(Icons.reset_tv_outlined),
              title: 'Refund & Return Policy',
              isAuth: false,
              onTap: () {
                // NavigationService.navigateTo(RouteNames.privacyPolicyScreen, arguments: 'return');
              },
            ),
            AccountItem(
              icon: Icon(Icons.contact_mail_outlined),
              title: 'Contact us',
              isAuth: false,
              onTap: () {
                //NavigationService.navigateTo(RouteNames.contactUsScreen);
              },
            ),
            AccountItem(
              icon: Icon(Icons.question_answer_outlined),
              title: 'Faq',
              isAuth: false,
              onTap: () {
                // NavigationService.navigateTo(RouteNames.faqScreen);
                //NavigationService.navigateTo(RouteNames.privacyPolicyScreen, arguments: 'faq');
              },
            ),
          ]),
          Utils.verticalSpace(20.0),
          BlocListener<AuthCubit, AuthStateModel>(
            listener: (context, login) {
             final state = login.authState;
             if(state is AuthSuccess && state.authType == AuthType.logOut){
               NavigationService.showSnackBar(context,state.message??'');
               NavigationService.navigateToAndClearStack(RouteNames.authScreen);
             }
            },
            child: PrimaryButton(
              text: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmDialog(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      image: KImages.logout,
                      title: 'Logout',
                      subTitle: 'Are you sure, you want to logout?',
                      isOneButton: false,
                      child: Padding(
                        padding: Utils.only(top: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: PrimaryButton(
                                text: 'Cancel',
                                onPressed: () => NavigationService.goBack(),
                                bgColor: Colors.grey.shade200,
                                textColor: blackColor,
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              flex: 8,
                              child: PrimaryButton(
                                text: 'Yes,Logout',
                                bgColor: redColor,
                                onPressed: () async{
                                  Navigator.of(context).pop();
                                  await profileCubit.logOut();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              buttonType: ButtonType.iconButton,
              icon: const Icon(Icons.logout_outlined, color: whiteColor),
              borderColor: transparent,
            ),
          ),



          /*

              Column(
                children: [

                  _buildCardSection([
                    AccountItem(
                      icon: Icon(Icons.delete_outline, color: redColor),
                      title: "Delete Account",
                      textColor: redColor,
                      onTap: () {

                        //loginBloc.add(StoreSignUpInfo((info)=>info.copyWith(currentPassword: '')));

                        showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmDialog(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              image: KImages.actDelete,
                              title: 'Delete Account',
                              subTitle:
                              'Are you sure, you want to delete your account?',
                              isOneButton: false,
                              child: BlocBuilder<LoginBloc, UserModel>(
                                  builder: (context,passState){

                                    final tempState = passState.loginState;

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      padding: Utils.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Form(
                                            key: loginBloc.deleteFormKey,
                                            child: CustomForm(
                                              label: 'Current Password',
                                              bottomSpace: 10.0,
                                              child: TextFormField(
                                                initialValue: passState.user?.currentPassword,
                                                onChanged: (String ? val)=>loginBloc.add(StoreSignUpInfo((info)=>info.copyWith(currentPassword: val))),
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: Utils.requiredValidator('Current Password'),
                                                decoration: InputDecoration(hintText: 'Current password',
                                                    prefix: Utils.horizontalSpace(textFieldSpace),

                                                    suffixIcon: suffixIcon(()=>loginBloc.add(StoreSignUpInfo((info)=>info.copyWith(isShowCurrent5Word: !(passState.user?.isShowCurrent5Word??true)))), passState.user?.isShowCurrent5Word??true)),
                                                keyboardType: TextInputType.visiblePassword,
                                                obscureText: passState.user?.isShowCurrent5Word??true,
                                              ),
                                            ),
                                          ),

                                          if(tempState is AuthPassTypeLoading)...[
                                            LoadingWidget(),
                                          ]else...[
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 8,
                                                  child: PrimaryButton(
                                                    text: 'Cancel',
                                                    onPressed: () => NavigationService.goBack(),
                                                    bgColor: Colors.grey.shade200,
                                                    textColor: blackDarkColor,
                                                  ),
                                                ),
                                                Spacer(),
                                                Expanded(
                                                  flex: 8,
                                                  child: PrimaryButton(
                                                    text: 'Yes,Delete',
                                                    bgColor: redColor,
                                                    onPressed: () {
                                                      Utils.closeKeyBoard(context);

                                                      if(loginBloc.deleteFormKey.currentState?.validate()??false){
                                                        loginBloc..add(StoreSignUpInfo((info)=>info.copyWith(updatedAt: loginBloc.userInformation?.accessToken))).. add(AuthPassTypeEvent(AuthPassType.deleteAct));
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]

                                        ],
                                      ),
                                    );
                                  } ),
                            );
                          },
                        );
                      },
                    ),
                  ]),
                  Utils.verticalSpace(15.0),

                  PrimaryButton(
                    text: 'Logout',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmDialog(
                            onTap: () {
                              Navigator.of(context).pop();
                              //Navigator.pushNamedAndRemoveUntil(context,RouteNames.authScreen,(route)=>false);
                            },
                            image: KImages.logout,
                            title: 'Logout',
                            subTitle: 'Are you sure, you want to logout?',
                            isOneButton: false,
                            child: Padding(
                              padding: Utils.only(top: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: PrimaryButton(
                                      text: 'Cancel',
                                      onPressed: () => NavigationService.goBack(),
                                      bgColor: Colors.grey.shade200,
                                      textColor: blackDarkColor,
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    flex: 8,
                                    child: PrimaryButton(
                                      text: 'Yes,Logout',
                                      bgColor: redColor,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context.read<LoginBloc>().add(LoginEventLogout());
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    buttonType: ButtonType.iconButton,
                    icon: const Icon(Icons.logout_outlined, color: blackDarkColor),
                    bgColor: Colors.grey.shade200,
                    borderColor: transparent,
                    textColor: blackDarkColor,
                  ),
                ],
              ),
            ),
            Utils.verticalSpace(20.0),
          ],*/
        ],
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      decoration: defaultDecoration,
      child: Column(children: children),
    );
  }
}

class AccountItem extends StatelessWidget {
  const AccountItem({
    super.key,
    required this.icon,
    required this.title,
    this.textColor,
    this.onTap,
    this.isAuth = true,
  });

  final Widget icon;
  final String title;
  final Color? textColor;
  final bool isAuth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: CustomText(
        text: title,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: textColor ?? blackColor,
      ),
      trailing: const Icon(Icons.chevron_right, color: grayColor),
      onTap: () {
        //final loggedIn = Utils.isLoggedIn(context);

        // if (isAuth && !loggedIn) {
        //   //NavigationService.navigateTo(RouteNames.pleaseLoginScreen);
        //   // Utils.showSnackBarWithLogin(context);
        //   return;
        // }

        onTap?.call();
      },
    );
  }
}
