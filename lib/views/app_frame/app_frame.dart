import 'package:coin_log/views/app_frame/accounts_balance.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/views/app_frame/record_list.dart';
import 'package:coin_log/views/app_frame/summary.dart';
import 'package:coin_log/views/app_frame/settings.dart';
import 'package:coin_log/views/record_details.dart';

class AppFramePage extends StatefulWidget {
  const AppFramePage({super.key});

  @override
  State<AppFramePage> createState() => _AppFramePageState();
}

class _AppFramePageState extends State<AppFramePage> {
    int selectedIndex = 0;

    final GlobalKey<RecordListState> recordListKey =  GlobalKey<RecordListState>();

    late List<Widget> bodies;

    @override
    void initState() {
      bodies = <Widget>[
        RecordList(key: recordListKey,),
        Summary(),
        AccountsBalance(),
        Settings(),
      ];
    }

    @override
    Widget build(BuildContext context) {
        return SafeArea(
          child: Scaffold(
            body: Center(child: bodies.elementAt(selectedIndex)),
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
            floatingActionButton: Container(
                margin: const EdgeInsets.only(top: 10),
                height: 40,
                width: 60,
                child: FloatingActionButton(
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 3),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  splashColor: Colors.transparent,
                  child: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary
                  ),
                  onPressed: () async {
                    final results = await Navigator.of(context).push(RouterUtils.createRoute(RecordDetails()));
                    if (results.length > 1 && results[0] == "reload") {
                      setState(() {
                        selectedIndex = 0;
                      });
                      recordListKey.currentState?.load(results[1]);
                    }
                  }
                ),
            ),
            bottomNavigationBar: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent
              ),
              child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Records'),
                      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Summary'),
                      BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Accounts'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (int index) {
                      setState(() {
                          selectedIndex = index;
                      });
                  },
              ),
            ),
          ),
        );
    }
}