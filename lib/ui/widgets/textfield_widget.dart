import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextfieldWidget extends StatelessWidget {
  const TextfieldWidget({
    super.key,
    required this.hintText,
    this.controller,
    // required this.focusNode,
    this.onChanged,
    this.onTap,
    this.isPassword = false,
    this.isChatText = false,
    this.isSearch = false,
  });

  final void Function(String)? onChanged;
  final String? hintText;
  // final FocusNode? focusNode;
  final bool isSearch;
  final bool isChatText;
  final TextEditingController? controller;
  final void Function()? onTap;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: controller,
      // focusNode: focusNode,
      obscureText: isPassword,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16),
        filled: true,
        fillColor: isChatText ? white : grey.withOpacity(0.12),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isChatText ? 25.r : 10.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            isSearch
                ? Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(searchIcon),
                )
                : isChatText
                ? InkWell(onTap: onTap, child: const Icon(Icons.send))
                : null,
      ),
    );
  }
}
