
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/auth_state_model.dart';
import '../../../logic/bloc/login/login_bloc.dart';
import '../../../logic/cubit/auth/auth_cubit.dart';
import '../../routes/route_names.dart';
import '../../utils/constraints.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_form.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/primary_button.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late AuthCubit loginBloc;

  @override
  void initState() {
    loginBloc = context.read<AuthCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: CustomAppBar(title: '',visibleLeading: true,toolBarHeight: 40.0,bgColor: scaffoldBgColor),
      body: SizedBox(
        height: Utils.mediaQuery(context).height,
        width: Utils.mediaQuery(context).width,
        child: ListView(
          padding: Utils.all(),
          children: [
            Utils.verticalSpace(Utils.mediaQuery(context).height * 0.2),
            Container(
              height: Utils.mediaQuery(context).height * 0.7,
              width: Utils.mediaQuery(context).width,
              alignment: Alignment.bottomCenter,
              padding: Utils.symmetric(v: 30.0).copyWith(bottom: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Utils.radius(40.0)),
                  topRight: Radius.circular(Utils.radius(40.0)),
                ),
                color: whiteColor,
              ),
              child: Column(
                // padding: Utils.symmetric(),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "Create your account",
                    fontSize: 24.0,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                  const CustomText(
                    text: "Create an account to continue",
                    fontSize: 14.0,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  Utils.verticalSpace(10.0),
                  // BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                  //   final login = state.authState;
                  //   return Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       CustomForm(
                  //           label: 'Your Name',
                  //           bottomSpace: 10.0,
                  //           child: TextFormField(
                  //             initialValue: state.email,
                  //             onChanged:  loginBloc.addEmail,
                  //             decoration: const InputDecoration(
                  //               hintText: 'your name',
                  //             ),
                  //             keyboardType: TextInputType.name,
                  //           )),
                  //       // if (login is LoginStateFormValidate) ...[
                  //       //   if (login.errors.email.isNotEmpty)
                  //       //     FetchErrorText(text: login.errors.email.first)
                  //       // ]
                  //     ],
                  //   );
                  // }),
                  BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                    final login = state.authState;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomForm(
                            label: 'Email',
                            bottomSpace: 10.0,
                            child: TextFormField(
                              initialValue: state.email,
                              onChanged:  loginBloc.addEmail,
                              decoration: const InputDecoration(
                                hintText: 'email here',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            )),
                        // if (login is LoginStateFormValidate) ...[
                        //   if (login.errors.email.isNotEmpty)
                        //     FetchErrorText(text: login.errors.email.first)
                        // ]
                      ],
                    );
                  }),
                  // BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                  //   final login = state.authState;
                  //   return Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       CustomForm(
                  //           label: 'Phone Number',
                  //           bottomSpace: 10.0,
                  //           child: TextFormField(
                  //             initialValue: state.email,
                  //             onChanged:  loginBloc.addEmail,
                  //             decoration: const InputDecoration(
                  //               hintText: 'your phone number',
                  //             ),
                  //             inputFormatters: [
                  //               FilteringTextInputFormatter.digitsOnly,
                  //               FilteringTextInputFormatter.deny('a'),
                  //               // LengthLimitingTextInputFormatter(11),
                  //             ],
                  //             keyboardType: TextInputType.phone,
                  //           )),
                  //       // if (login is LoginStateFormValidate) ...[
                  //       //   if (login.errors.email.isNotEmpty)
                  //       //     FetchErrorText(text: login.errors.email.first)
                  //       // ]
                  //     ],
                  //   );
                  // }),

                  BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                    final login = state.authState;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomForm(
                            label: 'Password',
                            bottomSpace: 10.0,
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              initialValue: state.password,
                              onChanged:  loginBloc.addPassword,
                              obscureText: state.show,
                              decoration: InputDecoration(
                                hintText: 'password',
                                suffixIcon: IconButton(
                                  onPressed: () => loginBloc.showPassword(),
                                  icon: Icon(state.show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: blackColor),
                                ),
                              ),
                            )),
                        // if (login is LoginStateFormValidate) ...[
                        //   if (login.errors.password.isNotEmpty)
                        //     FetchErrorText(text: login.errors.password.first)
                        // ]
                      ],
                    );
                  }),
                  BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                    final login = state.authState;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomForm(
                            label: 'Confirm Password',
                            bottomSpace: 20.0,
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              initialValue: state.password,
                              onChanged:  loginBloc.addPassword,
                              obscureText: state.showConfirm,
                              decoration: InputDecoration(
                                hintText: 'confirm password',
                                suffixIcon: IconButton(
                                  onPressed: () => loginBloc.showConfirmPassword(),
                                  icon: Icon(state.showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: blackColor),
                                ),
                              ),
                            )),
                        // if (login is LoginStateFormValidate) ...[
                        //   if (login.errors.password.isNotEmpty)
                        //     FetchErrorText(text: login.errors.password.first)
                        // ]
                      ],
                    );
                  }),

                  BlocConsumer<AuthCubit, AuthStateModel>(
                    listener: (context, login) {
                      final state = login.authState;
                      if (state is AuthError) {
                        Utils.errorSnackBar(context, state.message??'');
                      } else if (state is AuthSuccess) {
                        Utils.showSnackBar(context, state.message??'');

                        WidgetsBinding.instance.addPostFrameCallback((_){
                          loginBloc.storeNewUser();
                        });
                      }
                    },
                    builder: (context, login) {
                      final state = login.authState;
                      if (state is AuthLoading) {
                        return const LoadingWidget();
                      }
                      return PrimaryButton(
                        text: Utils.translatedText(context, 'Sign up'),
                        onPressed: () {
                          Utils.closeKeyBoard(context);
                         loginBloc.signUp();
                        },
                      );
                    },
                  ),
                  Utils.verticalSpace(12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        text: "Already have an account? ",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        height: 1.6,
                      ),
                      GestureDetector(
                        onTap: () {
                          loginBloc.clear();
                          Navigator.pushNamed(context, RouteNames.authScreen);
                        },
                        child: const CustomText(
                          text: 'Login',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: secondaryColor,
                          height: 1.6,
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
