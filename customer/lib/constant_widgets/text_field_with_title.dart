// ignore_for_file: prefer_typing_uninitialized_variables, strict_top_level_inference
import 'package:customer/constant_widgets/country_code_selector_view.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/validate_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TextFieldWithTitle extends StatelessWidget {
  final String title;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final TextEditingController controller;
  final bool? isEnable;
  final validator;

  const TextFieldWithTitle({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.prefixIcon,
    this.isEnable,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, fontWeight: FontWeight.w500),
        ),
        Container(
          transform: Matrix4.translationValues(0.0, -05.0, 0.0),
          child: TextFormField(
            cursorColor: AppThemData.primary500,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            enabled: isEnable,
            validator: validator,
            style: GoogleFonts.inter(fontSize: 14, color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.grey950, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
              border: const UnderlineInputBorder(borderSide: BorderSide(color: AppThemData.grey500, width: 1)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppThemData.grey500, width: 1)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppThemData.grey500, width: 1)),
              errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppThemData.grey500, width: 1)),
              disabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppThemData.grey500, width: 1)),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: prefixIcon,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppThemData.grey500, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }
}

class MobileNumberTextField extends StatelessWidget {
  final ValueChanged<String> onCountryCodeChanged;
  final TextEditingController controller;
  final TextEditingController countryCodeController;
  final bool readOnly;
  final bool enableCountryPicker;

  const MobileNumberTextField(
      {super.key, required this.controller, required this.countryCodeController, this.readOnly = false, required this.onCountryCodeChanged, this.enableCountryPicker = true});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return TextFormField(
      validator: (value) => validateMobile(value, countryCodeController.value.text),
      readOnly: readOnly,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
      cursorColor: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        PhoneNumberInputFormatter(
          mask: phoneMaskForCountryCode(countryCodeController.text),
          maxLength: phoneMaxLengthForCountryCode(countryCodeController.text),
        ),
      ],
      textCapitalization: TextCapitalization.sentences,
      textAlign: TextAlign.start,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: themeChange.isDarkTheme() ? AppThemData.white : AppThemData.black,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: CountryCodeSelectorView(  isCountryNameShow: false,

                countryCodeController: countryCodeController,
                isEnable: enableCountryPicker,
                onChanged: (value) {
                  countryCodeController.text = value.dialCode.toString();
                  onCountryCodeChanged(value.dialCode.toString());
                },
              ),
            ),
            Text(
              "|",
              style: TextStyle(fontSize: 16, color: themeChange.isDarkTheme() ? AppThemData.grey600 : AppThemData.grey100),
            ).paddingSymmetric(horizontal: 6),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey100, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey100, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey100, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeChange.isDarkTheme() ? AppThemData.grey400 : AppThemData.grey100, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppThemData.danger500, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppThemData.primary500, width: 1),
        ),
        hintText: "Enter your Phone Number".tr,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppThemData.grey500,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
