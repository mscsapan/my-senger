import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    profileCubit = context.read<AuthCubit>();
    profileUpdateKey = GlobalKey<FormState>();

    //final model = CoverModel(blurUrl: '',tempImg: '',isPreviousImg: true,url: profileCubit.profile?.cover?.url?? '');

   // debugPrint('init-model $model');

    //profileCubit..resetState()..addProfileInfo((r)=>r.copyWith(cover: model));
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar(title: 'Manage Account', bgColor: whiteColor),
      body: BlocBuilder<AuthCubit, AuthStateModel>(
        builder: (context, state) {

          // debugPrint('current-state ${state.profileState}');

          // debugPrint('state-cover ${state.user?.cover}');

          //final coverUrl = state.user?.cover?.url.trim().isNotEmpty??false?state.user?.cover?.url??'':KImages.placeholder;

          // final existingImg = state.user?.cover?.tempImg?.trim().isNotEmpty??false? state.user?.cover?.tempImg??KImages.placeholder:KImages.placeholder;
          //final existingImg = state.user?.cover?.tempImg?.trim().isNotEmpty??false? state.user?.cover?.tempImg??KImages.placeholder:coverUrl;
          // final existingImg = state.user?.cover?.url.trim().isNotEmpty??false? state.user?.cover?.url??KImages.defaultImg:KImages.defaultImg;

          //final pickedImg = state.user?.cover?.blurUrl.trim().isNotEmpty??false?state.user?.cover?.blurUrl??KImages.placeholder:existingImg;

          // debugPrint('existing-image $existingImg');
          // debugPrint('picked-image $pickedImg');
          //
          // debugPrint('temp-image ${state.user?.cover?.tempImg}');
          // debugPrint('blur-image ${state.user?.cover?.blurUrl}');
          // debugPrint('url-image ${state.user?.cover?.url}');

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
                      CircleImage(size: 120.0,image: Utils.imagePath(profileCubit.userInformation?.image)),
                      // CircleImage(size: 120.0,image: pickedImg,isFile: state.user?.cover?.blurUrl.trim().isNotEmpty),
                      Positioned(
                        right: 0.0,
                        bottom: 10.0,
                        child: GestureDetector(
                          onTap: () async {
                            // final image = await Utils.pickSingleImage();
                            // //debugPrint('picked-image $image');
                            // if (image?.isNotEmpty??false) {
                            //   final cover = CoverModel(blurUrl: image?? '');
                            //   profileCubit..addProfileInfo((r)=>r.copyWith(cover: cover))..uploadImgToCloudinary(ProfileUrlType.uploadImg);
                            // }
                            // debugPrint('picked-state-image ${state.user?.cover?.blurUrl}');
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
                    initialValue: state.users?.firstName,
                    onChanged: (String? val)=>profileCubit.addUserInfo((user)=>user.copyWith(firstName: val)),
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
                    initialValue: state.users?.lastName,
                    onChanged: (String? val)=>profileCubit.addUserInfo((user)=>user.copyWith(lastName: val)),
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
                    initialValue: state.users?.signUpEmail,
                    // initialValue: profileCubit.userInformation?.signUpEmail,
                    onChanged: (String? val)=>profileCubit.addUserInfo((user)=>user.copyWith(signUpEmail: val)),
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
                    initialValue: state.users?.phone,
                    onChanged: (String? val)=>profileCubit.addUserInfo((user)=>user.copyWith(phone: val)),
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
                // CustomForm(
                //   label: 'About Yourself',
                //   bottomSpace: 12.0,
                //   isRequired: false,
                //   child: TextFormField(
                //     initialValue: state.user?.about,
                //     onChanged: (String? val)=>profileCubit.addProfileInfo((user)=>user.copyWith(about: val)),
                //     decoration: InputDecoration(
                //       prefix: Utils.horizontalSpace(textFieldSpace),
                //       hintText: Utils.translatedText(context, 'about yourself'),
                //       fillColor: fillColor,
                //     ),
                //     keyboardType: TextInputType.text,
                //   ),
                // ),
                // CustomText(text: 'Location',fontSize: 16.0,fontWeight: FontWeight.w500,color: primaryColor),
                // Utils.verticalSpace(16.0),
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
                    // initialValue: state.user?.address,
                    // onChanged: (String? val)=>profileCubit.addProfileInfo((user)=>user.copyWith(address: val)),
                    decoration: InputDecoration(
                      prefix: Utils.horizontalSpace(textFieldSpace),
                      hintText: Utils.translatedText(context, 'Address'),
                      fillColor: fillColor,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
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
         //  final state = profile.profileState;
         // if(state is ProfileInfoError && state.apiType == ProfileUrlType.update){
         //   NavigationService.showSnackBar(context,state.message);
         // }else if(state is ProfileInfoLoaded && state.apiType == ProfileUrlType.update){
         //
         //   profileCubit.profileInfo(ProfileUrlType.getInfo);
         //
         //   WidgetsBinding.instance.addPostFrameCallback((_){
         //     NavigationService.goBack();
         //   });
         // }
         //
         //
         // if(state is UploadImgToCloudinaryLoaded){
         //
         //   if(state.uploaded?.isNotEmpty??false){
         //     final cover = CoverModel(tempImg: state.uploaded?? '',isPreviousImg: false);
         //
         //     profileCubit.addProfileInfo((user)=>user.copyWith(cover: cover));
         //   }
         //
         // }

        },
        builder: (context, profile) {
          // final state = profile.profileState;
          return PrimaryButton(
            text: 'Update Now',
            onPressed: () {
              Utils.closeKeyBoard(context);
              //profileCubit.profileInfo(ProfileUrlType.update);
            },
          );
        },
      ),
    );
  }
}
