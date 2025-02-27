import 'dart:developer';

import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:chat_app/ui/screens/auth/signup/signup_viewmodel.dart';
import 'package:chat_app/ui/widgets/custom_button.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignupViewmodel>(
      create:
          (context) => SignupViewmodel(
            AuthService(),
            DatabaseService(),
            SupabaseStorageService(),
          ),
      child: Consumer<SignupViewmodel>(
        builder: (context, model, child) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.sw * 0.05,
                  vertical: 10.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Create your account", style: h),
                    10.verticalSpace,
                    Text(
                      "Please provide the Details",
                      style: body.copyWith(color: grey),
                    ),
                    30.verticalSpace,
                    InkWell(
                      onTap: () {
                        model.pickImage();
                      },
                      child:
                          model.image == null
                              ? CircleAvatar(
                                radius: 40.r,
                                child: const Icon(Icons.camera_alt),
                              )
                              : CircleAvatar(
                                radius: 40.r,
                                backgroundImage: FileImage(model.image!),
                              ),
                    ),
                    20.verticalSpace,
                    TextfieldWidget(
                      onChanged: model.setName,
                      hintText: "Enter Name",
                    ),
                    20.verticalSpace,
                    TextfieldWidget(
                      onChanged: model.setEmail,
                      hintText: "Enter Email",
                    ),
                    20.verticalSpace,
                    TextfieldWidget(
                      onChanged: model.setPassword,
                      hintText: "Enter Password",
                      isPassword: true,
                    ),
                    20.verticalSpace,
                    TextfieldWidget(
                      onChanged: model.setConfirmPassword,
                      hintText: "Confirm Password",
                      isPassword: true,
                    ),
                    30.verticalSpace,
                    CustomButton(
                      text: 'SignUp',
                      loading: model.state == ViewState.loading,
                      onPressed: () async {
                        try {
                          log("SignUp Button is pressed");
                          await model.signup();
                          Navigator.pop(context);
                          context.showSnackbar('User Signup in successfully!');
                        } on FirebaseAuthException catch (e) {
                          context.showSnackbar(e.toString());
                        } catch (e) {
                          context.showSnackbar(e.toString());
                        }
                      },
                    ),
                    15.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?", style: small),
                        5.horizontalSpace,
                        InkWell(
                          onTap: () {
                            print("click on the login");
                            Navigator.pushNamed(context, login);
                          },
                          child: Text(
                            "Login",
                            style: small.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
