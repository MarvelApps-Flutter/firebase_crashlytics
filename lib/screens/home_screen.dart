import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashlytics_app/constants/app_constants.dart';
import 'package:flutter_crashlytics_app/utils/text_styles.dart';

import '../utils/src/fab_menu.dart';
import '../utils/src/fab_menus_item.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize

    if (AppConstants.testingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (AppConstants.shouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  String? text;
  String? selectedText;
  @override
  void initState() {
    super.initState();
   init();
  }

  init()
  {
    _initializeFlutterFireFuture = _initializeFlutterFire();
    text = AppConstants.continueText;
    selectedText = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: buildBody()),
        floatingActionButton: FutureBuilder(
          future: _initializeFlutterFireFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return buildFabMenu();
              default:
                return const Center(child: Text(AppConstants.loadingText));
            }
          },
        ),
      );
  }

  buildFabMenu()
  {
    return FabMenu(
        fabBackgroundColor: Colors.amber[600],
        elevation: 2.0,
        fabAlignment: Alignment.bottomCenter,
        fabIcon: const Icon(
          Icons.touch_app_outlined,
          color: Colors.white,
        ),
        closeMenuButton: const Icon(
          Icons.clear,
          color: Colors.white,
          size: 25,
        ),
        overlayOpacity: 0.6,
        overlayColor: Colors.amber[600],
        children: [
          FabMenuItem(
            title: AppConstants.customKeySelectedText,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                selectedText = AppConstants.customKeySelectedText;
                text = AppConstants.customKeyText;
                //"To associate key/value pairs with your crash reports, you can use the setCustomKey method";
              });
              FirebaseCrashlytics.instance
                  .setCustomKey(AppConstants.firebase, AppConstants.crash);
            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
          FabMenuItem(
            title: AppConstants.generateLogsSelectedText,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                selectedText = AppConstants.generateLogsSelectedText;
                text = AppConstants.generateLogsText;
                //"To add custom Crashlytics log messages to your app, use the log method";
              });
              FirebaseCrashlytics.instance
                  .log(AppConstants.addLogText);
            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
          FabMenuItem(
            title: AppConstants.forceCrashSelectedText,
            onTap: () {
              sleep(const Duration(seconds: 3));
              FirebaseCrashlytics.instance.crash();
            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
          FabMenuItem(
            title: AppConstants.throwErrorSelectedText,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                selectedText = AppConstants.throwErrorSelectedText;
                text = AppConstants.throwErrorText;
                //"Thrown error has been caught";
              });
              throw StateError(AppConstants.uncaughtError);

            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
          FabMenuItem(
            title: AppConstants.zonedErrorSelectedText,
            onTap: () {
              Navigator.pop(context);
              runZonedGuarded(() {
                Future<void>.delayed(const Duration(seconds: 2),
                        () {
                      final List<int> list = <int>[];
                      print(list[0]);
                    });
              }, FirebaseCrashlytics.instance.recordError);
              setState(() {
                selectedText = AppConstants.zonedErrorSelectedText;
                text = AppConstants.zonedErrorText;
                //"Not all errors are caught by Flutter. Sometimes, errors are instead caught by Zones.To catch such errors, we can use runZonedGuarded.";
              });
            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
          FabMenuItem(
            title: AppConstants.fatalErrorSelectedText,
            onTap: () async {
              Navigator.pop(context);
              print("yyyy");
              try {

                throw Error();
              } catch (e, s) {
                await FirebaseCrashlytics.instance.recordError(e, s,
                    reason: AppConstants.exampleForFatalSelectedError,
                    fatal: true);
              }
              setState(() {
                selectedText = AppConstants.fatalErrorSelectedText;
                text = AppConstants.fatalErrorText;
                //"If you would like to record a fatal error, you may pass in a fatal argument as true. The crash report will appear in your Crashlytics dashboard with the event type Crash.";
              });
            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
          FabMenuItem(
            title: AppConstants.nonFatalErrorSelectedText,
            onTap: () async {
              Navigator.pop(context);
              try {
                throw Error();
              } catch (e, s) {
                await FirebaseCrashlytics.instance.recordError(e, s,
                    reason: AppConstants.exampleForNonFatalSelectedError);
              }
              setState(() {
                selectedText = AppConstants.nonFatalErrorSelectedText;
                text = AppConstants.nonFatalErrorText;
                //"By default non-fatal errors are recorded. The crash report will appear in your Crashlytics dashboard with the event type Non-fatal.";
              });
            },
            style: AppTextStyles.boldWhiteTextStyle,
          ),
        ]);
  }

  Widget buildBody() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const Image(
                  image: AssetImage(
                      AppConstants.crasdAssetImage
                  ),
                  fit: BoxFit.contain,
                  height: 150,
                  width: 170,
                ),
                const Center(
                  child: Text(AppConstants.firebaseCrashlyticsText,style: AppTextStyles.boldTextStyle,),
                ),
                const SizedBox(height: 10),
                Center(
                  /** Card Widget **/
                  child: Card(
                    elevation: 50,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              selectedText!,
                              style: AppTextStyles.boldTextStyle
                            ), //Text
                            const SizedBox(
                              height: 10,
                            ), //SizedBox
                            Text(
                                text!,
                                style: AppTextStyles.regularForLargeTextStyle
                            ),//SizedBox
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

SliverAppBar buildSliverAppBar() {
  return SliverAppBar(
    snap: true,
    floating: true,
    elevation: 10,
    backgroundColor: Colors.white,
    expandedHeight: 90,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
    flexibleSpace: FlexibleSpaceBar(
      background: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(40)),
          child: Row(
            children: const [
              Spacer(),
              Expanded(
                  child: Text(
                AppConstants.title,
              )),
              Expanded(
                child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Image(
                        image: AssetImage(
                          AppConstants.crashAssetImage,
                        ),
                        fit: BoxFit.fill,
                      ),
                    )),
              ),
            ],
          )),
    ),
  );
}
