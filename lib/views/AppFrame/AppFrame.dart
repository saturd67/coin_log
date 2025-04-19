import 'package:flutter/material.dart';
import 'package:namer_app/views/AppFrame/Record.dart';
import 'package:namer_app/views/AppFrame/Summary.dart';
import 'package:namer_app/views/RecordDetails.dart';

class AppFramePage extends StatefulWidget {
  const AppFramePage({super.key});

  @override
  State<AppFramePage> createState() => _AppFramePageState();
}

class _AppFramePageState extends State<AppFramePage> {
    int selectedIndex = 0;
    static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    static List<Widget> widgetOptions = <Widget>[
        Record(),
        Summary(),
        Text('Index 2: School', style: optionStyle),
        Text('Index 3: School', style: optionStyle),
    ];

    @override
    Widget build(BuildContext context) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: AppBarRecordSummary()
            ),
            body: Center(child: widgetOptions.elementAt(selectedIndex)),
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
                  onPressed: () {
                      Navigator.of(context).push(_createRoute());
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
                      BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
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

class AppBarRecordSummary extends StatelessWidget {
  const AppBarRecordSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2024',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              Text(
                'Dec',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500
                ),
              )
            ]
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Income:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              Text(
                '+800.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              )
            ]
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expenses:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              Text(
                '-500.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              )
            ]
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              Text(
                '300.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              )
            ]
          )
        ],
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => RecordDetails(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}