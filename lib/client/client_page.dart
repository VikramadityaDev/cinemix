// import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:logger/logger.dart';
import 'package:cinemix/client/video_utils.dart';
import 'package:cinemix/utils/permissions.dart';
import 'package:cinemix/client/p2p_utils.dart';

void main() {
  runApp(const ClientPage());
}

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
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

  String? get videoUrl => null;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController msgText = TextEditingController();
  final _flutterP2pConnectionPlugin = FlutterP2pConnection();
  late final Permissions permissions;
  late final p2p_utils p2p_util_obj;
  List<DiscoveredPeers> peers = [];
  WifiP2PInfo? wifiP2PInfo;
  StreamSubscription<WifiP2PInfo>? _streamWifiInfo;
  StreamSubscription<List<DiscoveredPeers>>? _streamPeers;
  String videoUrl = "";
  String hostDeviceName = "";

  final TextEditingController _urlController = TextEditingController();

  late video_utils player;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // BackButtonInterceptor.add(myInterceptor);
    permissions = Permissions(p2pObj: _flutterP2pConnectionPlugin, context: context);
    player = video_utils(context: context);
    p2p_util_obj = p2p_utils(p2pObj: _flutterP2pConnectionPlugin, context: context, permissions: permissions, player: player);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flutterP2pConnectionPlugin.unregister();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _flutterP2pConnectionPlugin.unregister();
    } else if (state == AppLifecycleState.resumed) {
      _flutterP2pConnectionPlugin.register();
    }
  }

  void _init() async {
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();
    _streamWifiInfo = _flutterP2pConnectionPlugin.streamWifiP2PInfo().listen((event) {
      setState(() {
        wifiP2PInfo = event;
        if (wifiP2PInfo == null) {
          logger.d("SETSTATE wifip2pinfo is null");
        }
      });
    });
    _streamPeers = _flutterP2pConnectionPlugin.streamPeers().listen((event) {
      setState(() {
        peers = event;
      });
    });
    permissions.checkPermissions();
    p2p_util_obj.discover();
  }

  //Get Clients

  List getClients() {
    List clientsList = [];
    if (wifiP2PInfo != null) {
      for (var clients in wifiP2PInfo!.clients) {
        clientsList.add(clients.deviceName);
      }
      return clientsList;
    } else {
      return [];
    }
  }

  void snack(String msg) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          msg,
        ),
      ),
    );
  }

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            (wifiP2PInfo == null || wifiP2PInfo!.groupOwnerAddress.isEmpty || hostDeviceName.isEmpty) ? '' : 'Host Name - $hostDeviceName',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "LIST OF",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                "AVAILABLE",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                "HOSTS",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: peers.length,
              itemBuilder: (context, index) => Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Center(
                              child: AlertDialog(
                                content: SizedBox(
                                  height: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("name: ${peers[index].deviceName}"),
                                      Text("address: ${peers[index].deviceAddress}"),
                                      Text("isGroupOwner: ${peers[index].isGroupOwner}"),
                                      Text("isServiceDiscoveryCapable: ${peers[index].isServiceDiscoveryCapable}"),
                                      Text("primaryDeviceType: ${peers[index].primaryDeviceType}"),
                                      Text("secondaryDeviceType: ${peers[index].secondaryDeviceType}"),
                                      Text("status: ${peers[index].status}"),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await p2p_util_obj.connectToHost(peers[index].deviceAddress);

                                      setState(() {
                                        hostDeviceName = peers[index].deviceName;
                                      });

                                      while (wifiP2PInfo == null) {
                                        await Future.delayed(const Duration(milliseconds: 200));
                                      }
                                      while (wifiP2PInfo!.groupOwnerAddress.isEmpty) {
                                        await Future.delayed(const Duration(milliseconds: 200));
                                      }

                                      logger.d("Group owneradddress - ${wifiP2PInfo?.groupOwnerAddress}");
                                      p2p_util_obj.connectToSocket(wifiP2PInfo!.groupOwnerAddress);
                                    },
                                    child: const Text("connect"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 80,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              peers[index].deviceName.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis, // Add this line
                              softWrap: false, // Add this line
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: p2p_util_obj.disconnectFromHost, child: const Row(children: [Icon(Icons.group_remove), Text(" Disconnect")])),
                TextButton(onPressed: p2p_util_obj.discover, child: const Row(children: [Icon(Icons.refresh_rounded), Text(" Refresh")])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
