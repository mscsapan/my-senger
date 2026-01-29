import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/auth_state_model.dart';
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

  late GlobalKey<FormState> loginFormKey;

  @override
  void initState() {
    loginBloc = context.read<AuthCubit>();
    loginFormKey = GlobalKey<FormState>();
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
              child: BlocConsumer<AuthCubit, AuthStateModel>(
                listener: (context, login) {
                  final state = login.authState;
                  if (state is AuthError) {
                    Utils.errorSnackBar(context, state.code??'');
                  } else if (state is AuthSuccess) {
                    Utils.showSnackBar(context, state.message??'');
                  }
                },
                builder: (context,state){
                  final login = state.authState;
                  final isShow = state.users?.showPassword?? true;
                  final isValidate = state.users?.validateLoginField ?? false;
                  return Form(
                    key: loginFormKey,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        CustomForm(
                            label: 'Email Address',
                            child: TextFormField(
                              initialValue: state.users?.loginEmail,
                              onChanged:(val)=>  loginBloc.addUserInfo((info)=>info.copyWith(loginEmail: val)),
                              validator: Utils.requiredValidator('Email'),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration:  InputDecoration(
                                hintText: 'email here',
                                prefix: Utils.horizontalSpace(textFieldSpace),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            )),
                        Utils.verticalSpace(10.0),
                        CustomForm(
                            label: 'Password',
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              initialValue: state.users?.loginPassword,
                              onChanged:(val)=>  loginBloc.addUserInfo((info)=>info.copyWith(loginPassword: val)),
                              obscureText: isShow,

                              validator: Utils.requiredValidator('Password'),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: 'Password here',
                                prefix: Utils.horizontalSpace(textFieldSpace),
                                suffixIcon: IconButton(
                                  onPressed: () => loginBloc.addUserInfo((info)=>info.copyWith(showPassword: !(state.users?.showPassword??false))),
                                  icon: Icon(isShow ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: blackColor),
                                ),
                              ),
                            )),
                        Utils.verticalSpace(12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: Utils.only(right: 8.0),
                                  height: Utils.vSize(20.0),
                                  width: Utils.hSize(20.0),
                                  child: Checkbox(
                                    onChanged: (val)=>  loginBloc.addUserInfo((info)=>info.copyWith(isActive: !(state.users?.isActive??false))),
                                    value: state.users?.isActive ?? false,
                                    activeColor: blackColor,
                                  ),
                                ),
                                const CustomText(
                                  text: 'Remember me',
                                  fontSize: 14.0,
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
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                color: redColor,
                              ),
                            ),
                          ],
                        ),
                        Utils.verticalSpace(30.0),
                        if(login is AuthLoading)...[
                          const LoadingWidget()
                        ]else...[
                          PrimaryButton(
                            bgColor: isValidate ? blackColor:disableColor,
                            text: Utils.translatedText(context, 'Login'),
                            textColor: isValidate ? whiteColor:grayColor,
                            onPressed: () {
                              Utils.closeKeyBoard(context);
                              // if(isValidate && (loginBloc.loginFormKey.currentState?.validate()??false)){
                              if(loginFormKey.currentState?.validate()??false){
                                loginBloc.signIn();
                              }
                            },
                          )
                        ],
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
                              Navigator.pushNamedAndRemoveUntil(context, RouteNames.mainScreen, (route) => false);
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
                  );
                },
                // listenWhen: (previous,current)=>previous == current,

              ),
            ),
          ],
        ),
      ),
    );
  }
}
