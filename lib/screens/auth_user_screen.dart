import 'package:begzar/common/page_status.dart';
import 'package:begzar/common/theme.dart';
import 'package:begzar/common/utils.dart';
import 'package:begzar/model/user_model.dart';
import 'package:begzar/widgets/submit_verification_code.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show
        FacebookAuthProvider,
        FirebaseAuth,
        FirebaseAuthException,
        GoogleAuthProvider,
        OAuthCredential,
        UserCredential;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:iconsax/iconsax.dart';

class AuthUserScreen extends StatefulWidget {
  const AuthUserScreen({super.key});

  @override
  State<AuthUserScreen> createState() => _AuthUserScreenState();
}

class _AuthUserScreenState extends State<AuthUserScreen> {
  int _selectedTabIndex = 0;
  change_tab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  PageStatus loginStatus = PageStatus.initial;
  PageStatus signUpStatus = PageStatus.initial;

  _build_login() {
    final TextEditingController email = TextEditingController();
    final TextEditingController pass = TextEditingController();

    return Column(
      children: [
        const SizedBox(height: 20),
        // beatuiful TextField for email material 3
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: email,
            decoration: InputDecoration(
              // set radius
              // borderRadius: BorderRadius.circular(8),
              labelText: context.tr('email'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Iconsax.message),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // beautiful TextField for password material 3
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: pass,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.tr('password'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Iconsax.lock),
            ),
          ),
        ),
        // add forgot password
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 20,
            ),
            Text(context.tr('forgot_password'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                )),
          ],
        ),
        // add submit button
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // set max width
              fixedSize: const Size(double.infinity, 48),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // textStyle: const TextStyle(fontSize: 16),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Handle login
              if (loginStatus == PageStatus.loading) return;
              _login(email.text, pass.text);
            },
            child: loginStatus == PageStatus.initial
                ? Text(context.tr('login'),
                    style: TextStyle(
                        fontSize: 16, color: ThemeColor.backgroundColor))
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }

  _build_register() {
    final TextEditingController email = TextEditingController();
    final TextEditingController pass = TextEditingController();

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: email,
            decoration: InputDecoration(
              // set radius
              // borderRadius: BorderRadius.circular(8),
              labelText: context.tr('email'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Iconsax.message),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // beautiful TextField for password material 3
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: pass,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.tr('password'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Iconsax.lock),
            ),
          ),
        ),
        // add forgot password
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 10,
        ),

        // add submit button
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // set max width
              fixedSize: const Size(double.infinity, 48),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // textStyle: const TextStyle(fontSize: 16),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Handle login
              if (signUpStatus == PageStatus.loading) return;
              if (signUpStatus == PageStatus.loaded) return;
              _signup(email.text, pass.text);
            },
            child: signUpStatus == PageStatus.initial
                ? Text(context.tr('signup'),
                    style: TextStyle(
                        fontSize: 16, color: ThemeColor.backgroundColor))
                : const CircularProgressIndicator(
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                  'By signing up you agree to our Terms of Service and Privacy Policy'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 30,
                    color: Theme.of(context).colorScheme.onSurface,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                  Text(
                    context.tr('auth_user.title'),
                    style: const TextStyle(
                      fontFamily: 'sb',
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
              // Center(
              //   child: RiveAnimation.asset(
              //     'assets/lottie/login_screen_character.riv',
              //   ),
              // )
              const SizedBox(height: 100),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  context.tr('app_title'),
                  style: const TextStyle(
                    fontFamily: 'sm',
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  context.tr('easy_login'),
                  style: const TextStyle(
                    fontFamily: 'sm',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      // set maximum width
                      fixedSize: const Size(150, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(100, 48),
                      backgroundColor: Colors.white10, // Google blue color
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _login_with_google,
                    icon: Image.asset(
                      'assets/images/Google__G__logo.svg.png',
                      width: 20,
                      height: 20,
                    ),
                    label: Text(('Google')),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      // set maximum width
                      fixedSize: const Size(150, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(100, 48),
                      backgroundColor: Colors.white10, // Facebook blue color
                      foregroundColor: Colors.white,
                      // fixedSize: const Size(150, 48),
                    ),
                    onPressed: _signInWithFacebook,
                    // Handle Facebook Sign-In
                    icon: Image.asset(
                      'assets/images/2021_Facebook_icon.svg.png',
                      width: 20,
                      height: 20,
                    ),
                    label: Text(('Facebook ')),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Divider(),

              const SizedBox(height: 10),

              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(26, 243, 225, 225),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // must 2 tab
                      children: [
                        // login tab
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            change_tab(0);
                          },
                          child: Container(
                            color: _selectedTabIndex == 0
                                ? Colors.white12
                                : Colors.transparent,
                            // iconMargin: const EdgeInsets.only(right: 100),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.lock,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                const SizedBox(width: 10),
                                Text(
                                  context.tr('login'),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            // icon: Icon(Iconsax.lock,
                            //     size: 20,
                            //     color: Theme.of(context).colorScheme.onSurface),
                            // text: context.tr('login'),
                          ),
                        ),
                        const SizedBox(width: 40),
                        // register tab
                        GestureDetector(
                          onTap: () {
                            change_tab(1);
                          },
                          child: Container(
                            color: _selectedTabIndex == 1
                                ? Colors.white10
                                : Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.user_add,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                const SizedBox(width: 10),
                                Text(
                                  context.tr('register'),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            // icon: Icon(Iconsax.user_add,
                            //     size: 20,
                            //     color: Theme.of(context).colorScheme.onSurface),
                            // text: context.tr('register'),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // make layout
              _selectedTabIndex == 0 ? _build_login() : _build_register(),
            ],
          ),
        ),
      ),
    );
  }

  _signup(String email, String password) async {
    // Validate email and password before attempting sign up
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      signUpStatus = PageStatus.loading;
    });
    // FirebaseAuth.instance.pass

    try {
      UserCredential? userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      final res = await showDialog(
          context: context, builder: (context) => SubmitVerificationCode());

      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification cancelled')),
        );
        return;
      }

      if (res['status'] != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${res['message']}')),
        );
        return;
      }

      _signin(userCredential);

// FirebaseAuth.instance.pass
      // print(userCredential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful!')),
      );
      // Optionally, navigate or update UI here
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed: ${e.message}';
      if (e.code == 'email-already-in-use') {
        message = 'email_already-in-use';
      } else if (e.code == 'weak-password') {
        message = 'weak-password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      //
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    }

    setState(() {
      signUpStatus = PageStatus.initial;
    });
  }

  _login(String email, String password) async {
    // Validate email and password before attempting sign in
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      loginStatus = PageStatus.loading;
    });

    // login with email and password
    try {
      UserCredential? user =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _signin(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }

    setState(() {
      loginStatus = PageStatus.initial;
    });
  }

  Future<UserCredential?> _signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      // Create a credential from the access token
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return null;
  }

  _login_with_google() async {
    print('Login with Google clicked');

    const List<String> scopes = <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ];

    // final LoginResult result = await GoogleSignIn().signIn();

    GoogleSignIn _googleSignIn = GoogleSignIn(
      // Optional clientId
      // clientId: 'your-client_id.apps.googleusercontent.com',
      scopes: scopes,
    );

    try {
      // GoogleSignInAccount? account = await _googleSignIn.signIn();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      print('Google Sign-In successful');
      // print(account);
    } catch (error) {
      print(error);
    }
  }

  _signin(UserCredential? user) async {
    // sign in to website
    Dio dio = Dio();

    final res =
        await dio.get('${Utils.base_url}/818_vpn/v1/auth/auth.php', data: {
      'email': user?.user?.email,
      'name': 'ss',
      'uid': user?.user?.uid,
    });

    // print(res.data);

    _saveUser(UserInfo.fromJson(res.data));

    // go back
    Navigator.of(context).pop();
  }

  _saveUser(UserInfo user) async {
    final box = await Hive.openBox<UserInfo>('users');
    await box.put('users', user);

    return true;
  }
}
