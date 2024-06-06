import 'package:flutter/material.dart';
import 'package:cinemix/utils/loading.dart';
import 'dart:async';
import 'client/client_page.dart';
import 'host/host_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool isLoading = false;
  Future<void> hostPageDirect() async {
    // Navigate to host stream page
    setState(() {
      isLoading = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HostPage()),
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> clientPageDirect() async {
    // Navigate to receive stream page
    setState(() {
      isLoading = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClientPage()),
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/images/cinemix_logo.png', height: 200,),
                  const SizedBox(
                    height: 25,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: hostPageDirect,
                      child: Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Color.fromARGB(255, 16, 0, 48)),
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                        child: const Center(
                          child: Text(
                            "Host",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: clientPageDirect,
                      child: Container(
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Color(0xfff4f4f4)),
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                        child: const Center(
                          child: Text(
                            "Client",
                            style: TextStyle(color: Colors.black, fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 65,
                  ),
                ],
              ),
            ),
          );
  }
}