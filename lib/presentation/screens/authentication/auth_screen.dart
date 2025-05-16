import 'package:flutter/material.dart';
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


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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
      appBar: CustomAppBar(title: '',visibleLeading: false,bgColor: scaffoldBgColor),
      body: SizedBox(
        height: Utils.mediaQuery(context).height,
        width: Utils.mediaQuery(context).width,
        child: ListView(
          children: [
            Utils.verticalSpace(Utils.mediaQuery(context).height * 0.1),
            Container(
              height: Utils.mediaQuery(context).height * 0.8,
              width: Utils.mediaQuery(context).width,
              alignment: Alignment.bottomCenter,
              // padding: EdgeInsets.only(left: 20.0, right: 20.0,top: 20.0, bottom: MediaQuery.of(context).viewInsets.bottom),
              padding: Utils.symmetric(v: 30.0),
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
                    text: "Log in to your Account",
                    fontSize: 24.0,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                  const CustomText(
                    text: "Welcome back! Please enter your details.",
                    fontSize: 14.0,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  Utils.verticalSpace(16.0),
                  BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                    final login = state.authState;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomForm(
                            label: 'Email Address',
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
                  Utils.verticalSpace(10.0),
                  BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                    final login = state.authState;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomForm(
                            label: 'Password',
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              initialValue: state.password,
                              onChanged:  loginBloc.addPassword,
                              obscureText: state.show,
                              decoration: InputDecoration(
                                hintText: 'Password here',
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
                  Utils.verticalSpace(12.0),
                  BlocBuilder<AuthCubit, AuthStateModel>(builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: Utils.only(right: 8.0),
                              height: Utils.vSize(24.0),
                              width: Utils.hSize(24.0),
                              child: Checkbox(
                                onChanged: (val)=>  loginBloc.addIsActive(),
                                value: state.isActive,
                                activeColor: blackColor,
                              ),
                            ),
                            const CustomText(
                              text: 'Remember me',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: blackColor,
                              height: 1.6,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, RouteNames.forgotPasswordScreen),
                          child: CustomText(
                            text: 'Forgot Password?',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: redColor,
                          ),
                        ),
                      ],
                    );
                  }),
                  Utils.verticalSpace(30.0),
                  BlocConsumer<AuthCubit, AuthStateModel>(
                    listener: (context, login) {
                      final state = login.authState;
                      if (state is AuthError) {
                        Utils.errorSnackBar(context, state.code??'');
                      } else if (state is AuthSuccess) {
                        Utils.showSnackBar(context, state.message??'');
                      }
                    },
                    builder: (context, login) {
                      final state = login.authState;
                      if (state is AuthLoading) {
                        return const LoadingWidget();
                      }
                      return PrimaryButton(
                        text: Utils.translatedText(context, 'Login'),
                        onPressed: () {
                          Utils.closeKeyBoard(context);
                          loginBloc.signIn();
                        },
                      );
                    },
                  ),
                  Utils.verticalSpace(18.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        text: "Don't have an account? ",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: blackColor,
                        height: 1.6,
                      ),
                      GestureDetector(
                        onTap: () {
                          loginBloc.clear();
                          Navigator.pushNamed(context, RouteNames.signUpScreen);
                        },
                        child: const CustomText(
                          text: 'Sign up',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: secondaryColor,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  Utils.verticalSpace(20.0),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, RouteNames.mainScreen, (route) => false);
                      },
                      child: const CustomText(
                        textAlign: TextAlign.center,
                        text: "Guest Login",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
