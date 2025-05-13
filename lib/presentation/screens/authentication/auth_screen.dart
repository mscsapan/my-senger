import 'package:flutter/material.dart';
import 'package:my_senger/presentation/routes/route_packages_name.dart';
import 'package:my_senger/presentation/utils/k_images.dart';
import 'package:my_senger/presentation/utils/utils.dart';
import 'package:my_senger/presentation/widgets/custom_image.dart';
import 'package:my_senger/presentation/widgets/custom_text.dart';
import 'package:my_senger/presentation/widgets/primary_button.dart';

import '../../widgets/custom_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        // title: const CustomText(
        //   text: 'Login',
        //   color: blackColor,
        //   fontSize: 20.0,
        //   fontWeight: FontWeight.w600,
        // ),
      ),
      body: SizedBox(
        height: Utils.mediaQuery(context).height,
        width: Utils.mediaQuery(context).width,
        child: ListView(
          shrinkWrap: true,
          children: [
            Utils.verticalSpace(Utils.mediaQuery(context).height * 0.3),
            IntrinsicHeight(
              child: Flexible(child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.antiAlias,
                  children: [
                    const CustomImage(path: KImages.loginBg,fit: BoxFit.cover,),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40.0),
                        UserInput(hintText: 'Name', prefixIcon: Icons.person),
                        const SizedBox(height: 10.0),
                        UserInput(
                            hintText: 'Email', prefixIcon: Icons.mail_outline),
                        const SizedBox(height: 10.0),
                        UserInput(
                          hintText: 'Password',
                          prefixIcon: Icons.lock,
                          suffixIcon: Icons.visibility,
                          obscureText: true,
                        ),
                        // remember(),
                        PrimaryButton(text: 'Login', onPressed: (){},padding: Utils.symmetric(v: 10.0)),
                      ],
                    )
                  ],
                ),
              )),
            ),
            // SizedBox(
            //   height: Utils.mediaQuery(context).height * 0.5,
            //   width: Utils.mediaQuery(context).width,
            //   child: ,
            // )
          ],
        ),
      ),
    );
  }

  Center buildCenter() {
    return Center(
        child: Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          shadowColor: Colors.blueAccent,
          child: SizedBox(
            height: 400.0,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.antiAlias,
                children: [
                  const CustomImage(path: KImages.loginBg,fit: BoxFit.cover,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40.0),
                      UserInput(hintText: 'Name', prefixIcon: Icons.person),
                      const SizedBox(height: 10.0),
                      UserInput(
                          hintText: 'Email', prefixIcon: Icons.mail_outline),
                      const SizedBox(height: 10.0),
                      UserInput(
                        hintText: 'Password',
                        prefixIcon: Icons.lock,
                        suffixIcon: Icons.visibility,
                        obscureText: true,
                      ),
                      // remember(),
                      PrimaryButton(text: 'Login', onPressed: (){},padding: Utils.symmetric(v: 10.0)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  ListView buildListView(BuildContext context) {
    return ListView(
      padding: Utils.symmetric(),
      children: [
        Utils.verticalSpace(Utils.mediaQuery(context).height * 0.15),
        const CustomText(text: 'Login',fontSize: 30.0,fontWeight: FontWeight.w700,textAlign: TextAlign.center),
        CustomForm(
          label: 'Email',
          child: TextFormField(),
        ),

      ],
    );
  }
}



class UserInput extends StatelessWidget {
  UserInput({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon = Icons.visibility,
    this.obscureText = false,
  });
  final String hintText;
  final IconData prefixIcon;
  final IconData suffixIcon;
  bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 60.0,
        child: TextField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            focusColor: Colors.transparent,
            prefixIcon: Container(
              height: 40.0,
              width: 40.0,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
              ),
              child: Icon(
                prefixIcon,
                color: Colors.black.withOpacity(0.6),
                size: 20.0,
              ),
            ),
            suffixIconColor: Colors.black.withOpacity(0.6),
            suffixIcon: obscureText
                ? Icon(
              suffixIcon,
              size: 20.0,
            )
                : null,
          ),
          obscureText: obscureText,
        ),
      ),
    );
  }
}
