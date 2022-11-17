import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/providers/auth_provider.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/register_screen.dart';
import 'package:grocery_vendor_app/widgets/reset_password_screen.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  Icon? icon;
  bool _visible = false;
  final _emailTextController = TextEditingController();
  String? email;
  String? password;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('LOGIN', style: TextStyle(fontFamily: 'Anton',
                              fontSize: 30),),
                          SizedBox(width: 20,),
                          Image.asset('images/logo-1.png', height: 100,
                            width: 100,
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: _emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Email';
                          }
                          final bool _isvalid = EmailValidator.validate(
                              _emailTextController.text);
                          if (!_isvalid) {
                            return 'Invalid Email Format';
                          }
                          setState(() {
                            email = value;
                          });
                          return null;
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme
                                  .of(context)
                                  .primaryColor, width: 2),
                            ),
                            focusColor: Theme
                                .of(context)
                                .primaryColor
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Password';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 Characters';
                          }
                          setState(() {
                            password = value;
                          });
                          return null;
                        },
                        obscureText: _visible == false ? true : false,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: _visible ? Icon(Icons.visibility) : Icon(
                                  Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _visible = !_visible;
                                });
                              },),
                            enabledBorder: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme
                                  .of(context)
                                  .primaryColor, width: 2),
                            ),
                            focusColor: Theme
                                .of(context)
                                .primaryColor
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, ResetPassword.id);
                              },
                              child: Text('Forgot Password ? ',
                                textAlign: TextAlign.end,
                                style: TextStyle(color: Colors.blue,
                                    fontWeight: FontWeight.bold),)),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              child: _loading ? LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                backgroundColor: Colors.transparent,
                              ) : Text('Login', style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  _authData.loginVendor(email, password).then((
                                      credential) {
                                    if (credential != null) {
                                      setState(() {
                                        _loading = false;
                                      });
                                      Navigator.pushReplacementNamed(
                                          context, HomeScreen.id);
                                    } else {
                                      setState(() {
                                        _loading = false;
                                      });
                                      ScaffoldMessenger.
                                      of(context)
                                          .showSnackBar(SnackBar(
                                          content: Text(_authData.error)));
                                    }
                                  });
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xff84c225))
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                            child:RichText(
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(text: 'Don\'t have an account ? ',style: TextStyle(color: Colors.black)),
                                TextSpan(text: 'Register',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                              ]
                            ),
                          ),
                            onPressed: (){
                              Navigator.pushNamed(context, RegisterScreen.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
