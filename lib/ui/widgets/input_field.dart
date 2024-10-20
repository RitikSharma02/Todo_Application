import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/get_utils.dart';

import '../theme.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;

  const MyInputField({
    Key? key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
    EdgeInsets? margin,


  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),

          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.only(left: 14),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            width: double.infinity,
            child:Row(
              children: [
                Expanded(child: TextFormField(
                  readOnly: widget==null?false: true,
                  autofocus: false,
                  cursorColor: Get.isDarkMode?Colors.grey[100]: Colors.grey[700],
                  controller: controller,
                  style: subTitleStyle,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: subTitleStyle,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surface,
                        width: 0,
                      )
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.surface,
                          width: 0,
                        )
                    ),
                  ),
                )),
                widget==null?Container():Container(child: widget,)
              ],
            ),
          ),

        ],
      ),
    );
  }
}