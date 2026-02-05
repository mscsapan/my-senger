import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth/auth_state_model.dart';
import '../../../logic/cubit/auth/auth_cubit.dart';
import '../../utils/constraints.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_form.dart' show CustomForm;
import '../../widgets/custom_text.dart' show CustomText;
import '../../widgets/primary_button.dart' show PrimaryButton;

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthCubit>();
    return Scaffold(
      appBar: const CustomAppBar(
        title: '',
        visibleLeading: true,
        bgColor: whiteColor,
      ),
      backgroundColor: whiteColor,
      body: ListView(
        padding: Utils.symmetric(),
        children: [
          Utils.verticalSpace(Utils.mediaQuery(context).height * 0.05),
          // const CustomImage(path: KImages.forgotPassword),
          // Utils.verticalSpace(Utils.mediaQuery(context).height * 0.05),
          CustomText(
            text: Utils.translatedText(context, 'Forgot Password'),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          Utils.verticalSpace(30.0),
          BlocBuilder<AuthCubit, AuthStateModel>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomForm(
                    label: Utils.translatedText(context, 'Email Address'),
                    child: TextFormField(
                      // initialValue: state.loginEmail,
                      // onChanged: fCubit.addEmail,
                      decoration: const InputDecoration(hintText: 'email here'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  // if (validate is ForgotPasswordFormValidateError) ...[
                  //   if (validate.errors.email.isNotEmpty)
                  //     FetchErrorText(text: validate.errors.email.first),
                  // ]
                ],
              );
            },
          ),
          Utils.verticalSpace(30.0),
          BlocListener<AuthCubit, AuthStateModel>(
            listener: (context, state) {
              final reg = state.authState;

              if (reg is AuthLoading) {
                Utils.loadingDialog(context);
              } else {
                Utils.closeDialog(context);
                if (reg is AuthError) {
                  Utils.errorSnackBar(context, reg.message ?? '');
                } else if (reg is AuthSuccess) {
                  Utils.showSnackBar(context, reg.message ?? '');

                  // fCubit..reset()..isNavigate = true;
                  // Navigator.pushNamed(context, RouteNames.forgotPasswordOtpScreen).then((_){
                  //   fCubit.isNavigate = false;
                  // });
                }
              }
            },
            child: PrimaryButton(
              text: Utils.translatedText(context, 'Send OTP'),
              onPressed: () {
                Utils.closeKeyBoard(context);
                // fCubit.forgotPassword();
              },
            ),
          ),
        ],
      ),
    );
  }
}
