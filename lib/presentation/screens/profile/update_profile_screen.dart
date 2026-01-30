import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_senger/presentation/widgets/loading_widget.dart';
import '../../utils/navigation_service.dart';
import '/data/models/auth/auth_state_model.dart';

import '../../../logic/cubit/auth/auth_cubit.dart';

import '../../utils/constraints.dart';
import '../../utils/k_images.dart';
import '../../utils/utils.dart';
import '../../widgets/bottom_widget.dart';
import '../../widgets/circle_image.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_form.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/primary_button.dart';


class UpdateProfileScreen extends StatefulWidget {
   const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {

  late AuthCubit profileCubit;
  late GlobalKey<FormState> profileUpdateKey;

  @override
  void initState() {
    super.initState();
    profileCubit = context.read<AuthCubit>()..updateUserInfo((info)=>info.copyWith(localImage: ''));
    profileUpdateKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar(title: 'Manage Account', bgColor: whiteColor),
      body: BlocBuilder<AuthCubit, AuthStateModel>(
        builder: (context, state) {

          final existingImg = Utils.imagePath(profileCubit.userInformation?.image);
          final pickImg = state.updateInfo?.localImage.isNotEmpty??false?state.updateInfo?.localImage??KImages.placeholderImg:existingImg;

          return Form(
            key: profileUpdateKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: Utils.symmetric(h: 16.0),
              children: [
                Utils.verticalSpace(Utils.mediaQuery(context).height * 0.02),

                Center(
                  child: Stack(
                    children: [
                      CircleImage(size: 120.0,image: pickImg,isFile: state.updateInfo?.localImage.isNotEmpty??false),
                      Positioned(
                        right: 0.0,
                        bottom: 10.0,
                        child: GestureDetector(
                          onTap: () async {
                            final image = await Utils.pickSingleImage();
                            if (image?.isNotEmpty??false) {
                               profileCubit
                                 ..updateUserInfo((info)=>info.copyWith(localImage: image))
                                 ..uploadProfileImg();
                                 // ..updateProfile();
                            }
                          },
                          child: Container(
                            padding: Utils.all(value:4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scaffoldBgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: whiteColor,width: 2.0),
                            ),
                            child: CustomImage(path: KImages.editIcon,height: 18.0,width: 18.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                CustomForm(
                  label: 'First Name',
                  bottomSpace: 12.0,
                  child: TextFormField(
                    initialValue: state.updateInfo?.firstName,
                    onChanged: (String? val)=>profileCubit.updateUserInfo((user)=>user.copyWith(firstName: val)),
                    validator: Utils.requiredValidator('First Name'),
                    decoration: InputDecoration(
                      prefix: Utils.horizontalSpace(textFieldSpace),
                      hintText: Utils.translatedText(context, 'First Name'),
                      fillColor: fillColor,
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ),
                CustomForm(
                  label: 'Last Name',
                  bottomSpace: 12.0,
                  child: TextFormField(
                    initialValue: state.updateInfo?.lastName,
                    onChanged: (String? val)=>profileCubit.updateUserInfo((user)=>user.copyWith(lastName: val)),
                    validator: Utils.requiredValidator('Last Name'),
                    decoration: InputDecoration(
                      prefix: Utils.horizontalSpace(textFieldSpace),
                      hintText: Utils.translatedText(context, 'Last Name'),
                      fillColor: fillColor,
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ),
                CustomForm(
                  label: 'Email',
                  bottomSpace: 12.0,
                  child: TextFormField(
                    initialValue: state.updateInfo?.signUpEmail,
                    onChanged: (String? val)=>profileCubit.updateUserInfo((user)=>user.copyWith(signUpEmail: val)),
                    readOnly: true,
                    validator: Utils.requiredValidator('Email'),
                    decoration: InputDecoration(
                      prefix: Utils.horizontalSpace(textFieldSpace),
                      hintText: Utils.translatedText(context, 'Email'),
                      fillColor: fillColor,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                CustomForm(
                  label: 'Phone',
                  bottomSpace: 27.0,
                  child: TextFormField(
                    initialValue: state.updateInfo?.phone,
                    onChanged: (String? val)=>profileCubit.updateUserInfo((user)=>user.copyWith(phone: val)),
                    validator: Utils.requiredValidator('Phone'),
                    decoration: InputDecoration(
                      prefix: Utils.horizontalSpace(textFieldSpace),
                      hintText: Utils.translatedText(context, 'Phone'),
                      fillColor: fillColor,
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.deny('a'),
                    ],
                    obscureText: false,
                  ),
                ),

                /*     CustomForm(
                      label: 'Country',
                      bottomSpace: 14.0,
                      child: CustomDropdownButton<ProductStatusModel>(
                        value: _country,
                        hintText: "Country",
                        items: countries,
                        onChanged: (value) {
                        },
                        itemBuilder: (item) => CustomText(text: item.title), // Customize item display
                      )
                      ,
                    ),
                    CustomForm(
                        label: 'State',
                        bottomSpace: 14.0,
                        child: CustomDropdownButton<ProductStatusModel>(
                          value: _state,
                          hintText: "State",
                          items: countries,
                          onChanged: (value) {
                          },
                          itemBuilder: (item) => CustomText(text: item.title), // Customize item display
                        )
                    ),
                    CustomForm(
                      label: 'City',
                      bottomSpace: 14.0,
                      child: CustomDropdownButton<ProductStatusModel>(
                        value: _city,
                        hintText: "City",
                        items: countries,
                        onChanged: (value) {
                        },
                        itemBuilder: (item) => CustomText(text: item.title), // Customize item display
                      ),
                    ),*/
                // CustomForm(
                //   label: 'Country',
                //   bottomSpace: 12.0,
                //   child: TextFormField(
                //     initialValue: state.user?.country,
                //     onChanged: (String? val)=>profileCubit.addProfileInfo((user)=>user.copyWith(country: val)),
                //     // validator: Utils.requiredValidator('Country'),
                //     decoration: InputDecoration(
                //       prefix: Utils.horizontalSpace(textFieldSpace),
                //       hintText: Utils.translatedText(context, 'Country'),
                //       fillColor: fillColor,
                //     ),
                //     keyboardType: TextInputType.text,
                //   ),
                // ),
                // CustomForm(
                //   label: 'State',
                //   bottomSpace: 12.0,
                //   isRequired: false,
                //   child: TextFormField(
                //     initialValue: state.user?.state,
                //     onChanged: (String? val)=>profileCubit.addProfileInfo((user)=>user.copyWith(state: val)),
                //     decoration: InputDecoration(
                //       prefix: Utils.horizontalSpace(textFieldSpace),
                //       hintText: Utils.translatedText(context, 'State'),
                //       fillColor: fillColor,
                //     ),
                //     keyboardType: TextInputType.text,
                //   ),
                // ),
                // CustomForm(
                //   label: 'City',
                //   bottomSpace: 12.0,
                //   isRequired: false,
                //   child: TextFormField(
                //     initialValue: state.user?.city,
                //     onChanged: (String? val)=>profileCubit.addProfileInfo((user)=>user.copyWith(city: val)),
                //     decoration: InputDecoration(
                //       prefix: Utils.horizontalSpace(textFieldSpace),
                //       hintText: Utils.translatedText(context, 'City'),
                //       fillColor: fillColor,
                //     ),
                //     keyboardType: TextInputType.text,
                //   ),
                // ),
                // CustomForm(
                //   label: 'Zip Code',
                //   bottomSpace: 12.0,
                //   isRequired: false,
                //   child: TextFormField(
                //     initialValue: state.user?.zip,
                //     onChanged: (String? val)=>profileCubit.addProfileInfo((user)=>user.copyWith(zip: val)),
                //     decoration: InputDecoration(
                //       prefix: Utils.horizontalSpace(textFieldSpace),
                //       hintText: Utils.translatedText(context, 'Zip Code'),
                //       fillColor: fillColor,
                //     ),
                //     keyboardType: TextInputType.text,
                //   ),
                // ),
                CustomForm(
                  label: 'Address',
                  bottomSpace: 12.0,
                  child: TextFormField(
                    initialValue: state.updateInfo?.address,
                    onChanged: (String? val)=>profileCubit.updateUserInfo((user)=>user.copyWith(address: val)),
                    decoration: InputDecoration(
                      prefix: Utils.horizontalSpace(textFieldSpace),
                      hintText: Utils.translatedText(context, 'Address'),
                      fillColor: fillColor,
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _submitButton(context),
    );
  }

  Widget _submitButton(BuildContext context) {
    return BottomWidget(
      child: BlocConsumer<AuthCubit, AuthStateModel>(
        listener: (context, profile) {
          final state = profile.authState;
         if(state is  AuthError && state.authType == AuthType.update){
           NavigationService.showSnackBar(context,state.message??'');
         }else if(state is AuthSuccess && state.authType == AuthType.update){

           profileCubit.fetchUserData();

           WidgetsBinding.instance.addPostFrameCallback((_){
             NavigationService.goBack();
           });

         }

          if(state is AuthSuccess && state.authType == AuthType.uploadImg){
            profileCubit
              ..updateUserInfo((info)=>info.copyWith(image: state.message))
              ..updateProfile();
          }
        },
        builder: (context, profile) {
          final state = profile.authState;
          if(state is AuthLoading){
            return UpdateWidget();
          }else{
            return PrimaryButton(
              text: 'Update Now',
              onPressed: () async{
                Utils.closeKeyBoard(context);
                await profileCubit.updateProfile();
              },
            );
          }

        },
      ),
    );
  }
}
