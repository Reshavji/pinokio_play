import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Screens
import 'game_screen.dart';
import 'ads_screen.dart';
import 'tasks_screen.dart';
import 'referral_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginPopup();
    });
  }

  // ================= LOGIN POPUP =================
  void _showLoginPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Welcome 👋",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Login to earn coins & rewards",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _emailLogin();
              },
              child: const Text("Email Login"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _emailSignup();
              },
              child: const Text("Signup"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await _googleLogin();
              },
              child: const Text("Google"),
            ),
          ],
        );
      },
    );
  }

  // ================= EMAIL LOGIN =================
  void _emailLogin() {
    final email = TextEditingController();
    final pass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
            ],
          ),
          actions: [

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email.text.trim(),
                  password: pass.text.trim(),
                );

                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Login"),
            )
          ],
        );
      },
    );
  }

  // ================= EMAIL SIGNUP =================
  void _emailSignup() {
    final email = TextEditingController();
    final pass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Signup"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
            ],
          ),
          actions: [

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email.text.trim(),
                  password: pass.text.trim(),
                );

                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Signup"),
            )
          ],
        );
      },
    );
  }

  // ================= GOOGLE LOGIN =================
  Future<void> _googleLogin() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = result.user;

      // 🔥 CREATE USER IN FIRESTORE
      if (user != null) {
        final ref = FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid);

        final doc = await ref.get();

        if (!doc.exists) {
          await ref.set({
            "coins": 0,
            "name": user.displayName ?? "User",
            "email": user.email,
            "photo": user.photoURL,
          });
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint("Google login error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // ================= TOP BAR =================
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {

                    final user = snapshot.data;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          "PINOKIO PLAY 🎮",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 🔴 NOT LOGGED IN
                        if (user == null)
                          ElevatedButton(
                            onPressed: _showLoginPopup,
                            child: const Text("LOGIN"),
                          )

                        // 🟢 LOGGED IN (PROFILE + COINS)
                        else
                          Row(
                            children: [

                              CircleAvatar(
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),

                              const SizedBox(width: 10),

                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(user.uid)
                                    .snapshots(),
                                builder: (context, snap) {

                                  if (!snap.hasData) {
                                    return const Text("0 🪙",
                                        style: TextStyle(color: Colors.white));
                                  }

                                  final data = snap.data!.data()
                                      as Map<String, dynamic>?;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${data?['coins'] ?? 0} 🪙",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ================= BANNER =================
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "🔥 Play & Earn Rewards 🔥",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= GRID =================
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [

                      _card("Play Games", Icons.sports_esports,
                          Colors.purple, const GameScreen()),

                      _card("Watch Ads", Icons.ondemand_video,
                          Colors.orange, const AdsScreen()),

                      _card("Daily Tasks", Icons.task_alt,
                          Colors.blue, const TasksScreen()),

                      _card("Refer & Earn", Icons.group,
                          Colors.green, const ReferralScreen()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(String title, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}