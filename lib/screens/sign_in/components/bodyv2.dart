import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sima_pengiriman/helper/database_helper.dart';
import 'package:sima_pengiriman/shared_preferences/shared_token.dart';

import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../login_success/login_success_screen.dart';
import '../controller/sign_in_controller.dart';
import 'package:intl/intl.dart';

class BodyV2 extends StatefulWidget {
  const BodyV2({Key? key}) : super(key: key);

  @override
  _BodyV2State createState() => _BodyV2State();
}

class _BodyV2State extends State<BodyV2> {
  final _ctl = SignInController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  @override
  void initState() {
    DatabaseHelper.instance.dropDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'SIMA',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'PENGIRIMAN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                  width: WidgetsBinding.instance.window.viewInsets.bottom > 0.0
                      ? 100
                      : 200,
                  child: Image.asset('assets/images/sign_in_logo.png'),
                ), // Specify the path to your image
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        _ctl.chgCredential(':username', value);
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.person, color: kPrimaryColor),
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      onChanged: (value) {
                        _ctl.chgCredential(':password', value);
                      },
                      obscureText: !_passwordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: kPrimaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50),
                    DefaultButton(
                      text: "Sign In",
                      press: () async {
                        await SharedToken.tokenRemover();
                        if (_formKey.currentState!.validate()) {
                          final resp = await _ctl.loging();

                          final val = jsonDecode(resp);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${val['msg']}')),
                          );

                          if (val['success']) {
                            final token = val['token'];
                            // await SharedToken.univSetterString(
                            //     'lokasi', val['lokasi']);
                            await SharedToken.univSetterString(
                                'username', val['username']);
                            await SharedToken.tokenSetter(token);
                            DateTime now = DateTime.now();

                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(now);

                            await SharedToken.univSetterString(
                                'last_login_dt', formattedDate);
                            // _formKey.currentState!.save();
                            KeyboardUtil.hideKeyboard(context);
                            Navigator.pushReplacementNamed(
                                context, LoginSuccessScreen.routeName);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
