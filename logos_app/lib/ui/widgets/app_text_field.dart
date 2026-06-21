import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/app_text_field_type.dart';
import 'package:logos_app/ui/widgets/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final AppTextFieldType fieldType;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.title,
    this.errorText,
    this.keyboardType = TextInputType.name,
    this.inputFormatters,
    this.fieldType = AppTextFieldType.primary,
    this.obscureText = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xs1),
      borderSide: BorderSide(color: AppColors.backgroundLightVariant),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xs1),
      borderSide: BorderSide(color: AppColors.primaryTextButton),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: TextField(
            minLines: (fieldType == AppTextFieldType.primary) ? 1 : 2,
            maxLines: (fieldType == AppTextFieldType.primary) ? 1 : 10,
            textAlign: TextAlign.start,
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            autofocus: autofocus,
            decoration: InputDecoration(
              border: border,
              enabledBorder: border,
              focusedBorder: focusedBorder,
              errorText: errorText,
              errorStyle: TextStyle(
                color: AppColors.error,
                fontFamily: AppFont().font.fontFamily,
                decorationColor: AppColors.error,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xs1),
                borderSide: BorderSide(color: AppColors.error),
              ),
              labelText: title,
              labelStyle: TextStyle(color: AppColors.darkText, fontFamily: AppFont().font.fontFamily),
              hintStyle: TextStyle(
                color: AppColors.secundaryDarkText,
                fontFamily: AppFont().font.fontFamily,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
