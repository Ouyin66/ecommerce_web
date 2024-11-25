import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';
import '../api/sharepre.dart';
import '../config/const.dart';
import '../main.dart';
import 'mainpage.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorPassword;
  String? errorEmail;

  bool _isHidden = true;

  void login() async {
    try {
      autoLogin();

      var response = await APIUser()
          .login(_emailController.text, _passwordController.text);

      // Kiểm tra phản hồi từ API

      errorEmail = null;
      errorPassword = null;

      if (response?.user != null && response?.user?.role == 0) {
        if (await saveUser(response!.user!)) {
          showToast(context, "Đăng nhập thành công");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MainPage()));
        } else {
          print("Không saveUser được");
        }
      } else if (response?.errorMessageEmail != null) {
        errorEmail = response?.errorMessageEmail;
      } else if (response?.errorMessagePassword != null) {
        errorPassword = response?.errorMessagePassword;
      } else if (response?.errorMessage != null) {
        showToast(context, response!.errorMessage!, isError: true);
      } else {
        showToast(context, "Hãy đăng nhập bằng tài khoản Administrator",
            isError: true);
      }
      _formKey.currentState!.validate();
    } catch (ex) {
      print("Error: $ex");
      showToast(context, "Đăng nhập thất bại", isError: true);
    }
  }

  autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      var user = await getUser();
      await updateUser(user.id!);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MainPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      MainApp.routeObserver.subscribe(this, route as PageRoute<dynamic>);
    }
  }

  @override
  void dispose() {
    MainApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Auto login when coming back to this widget
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(150, 50, 150, 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Trang quản lý ECOMMERCE UNIQLO",
                style: heading,
                softWrap: true,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      urlImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputField(
                                "Email",
                                _emailController,
                                'Email...',
                                Icons.email,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập email';
                                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    return 'Email không hợp lệ';
                                  }
                                  return errorEmail;
                                },
                              ),
                              const SizedBox(height: 15),
                              _buildInputField(
                                "Mật khẩu",
                                _passwordController,
                                'Mật khẩu...',
                                Icons.password,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  } else if (!RegExp(
                                          r'^(?=.*[a-zA-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$')
                                      .hasMatch(value)) {
                                    return 'Phải từ 6 ký tự, 1 chữ cái, 1 ký tự đặc biệt';
                                  }

                                  return errorPassword;
                                },
                                isPassword: true,
                                isHidden: _isHidden,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: _buildButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: blackColor,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadowColor: Colors.black.withOpacity(0.5),
        elevation: 8,
      ),
      onPressed: () {
        setState(() {
          if (_formKey.currentState!.validate()) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('Form hợp lệ')),
            // );
            login();
          } else if (errorEmail != null || errorPassword != null) {
            login();
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          "Đăng nhập",
          style: subhead,
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      String labelText, IconData icon, String? Function(String?) errorMess,
      {bool isPassword = false, bool isHidden = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: subhead,
        ),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16),
          obscureText: isPassword ? isHidden : false,
          decoration: InputDecoration(
            hintText: labelText,
            prefixIcon: Icon(
              icon,
              color: greyColor,
            ),
            iconColor: greyColor,
            hintStyle: const TextStyle(
              color: greyColor,
              fontSize: 16,
            ),
            border: FocusBorder(),
            focusedBorder: FocusBorder(),
            enabledBorder: EnableBorder(),
            errorBorder: ErrorBorder(),
            focusedErrorBorder: ErrorFocusBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isHidden ? Icons.visibility_off : Icons.visibility,
                      color: greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isHidden = !_isHidden;
                      });
                    },
                  )
                : null,
            errorStyle: error,
          ),
          validator: errorMess,
          onChanged: null,
        ),
      ],
    );
  }
}
