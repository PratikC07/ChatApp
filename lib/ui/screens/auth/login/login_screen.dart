import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/screens/auth/login/login_viewmodel.dart';
import 'package:chat_app/ui/widgets/custom_button.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewmodel(AuthService()),

      child: Consumer<LoginViewmodel>(
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
                    Text("Login", style: h),
                    10.verticalSpace,
                    Text(
                      "Please Log in to your account!",
                      style: body.copyWith(color: grey),
                    ),
                    30.verticalSpace,

                    TextfieldWidget(
                      onChanged: model.setEmail,
                      hintText: "Enter Email",
                    ),
                    20.verticalSpace,
                    TextfieldWidget(
                      onChanged: model.setPassword,
                      hintText: "Enter Password",
                    ),

                    30.verticalSpace,
                    CustomButton(
                      text: 'Log In',
                      loading: model.state == ViewState.loading,
                      onPressed: () async {
                        try {
                          await model.login();
                          context.showSnackbar("User logged in successfully!");
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
                        Text("Don't have account?", style: small),
                        5.horizontalSpace,
                        InkWell(
                          onTap: () {
                            print("click on the SignUp");
                            Navigator.pushNamed(context, signup);
                          },
                          child: Text(
                            "SignUp",
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
