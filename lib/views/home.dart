import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    int selectedIndex = 0;
    static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    static List<Widget> widgetOptions = <Widget>[
        Home(),
        // Text('Index 0: Home', style: optionStyle),
        Text('Index 1: Business', style: optionStyle),
        Text('Index 2: School', style: optionStyle),
        Text('Index 3: School', style: optionStyle),
    ];

    @override
    Widget build(BuildContext context) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("H O M E P A G E")
            ),
            body: Center(child: widgetOptions.elementAt(selectedIndex)),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Container(
                margin: const EdgeInsets.only(top: 10),
                height: 65,
                width: 65,
                child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 5),
                        borderRadius: BorderRadius.circular(100)
                    ),
                    splashColor: Colors.transparent,
                    child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onPrimary
                    ),
                    onPressed: () {
                        //
                    }
                ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Business'),
                    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'School'),
                    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'School'),
                ],
                currentIndex: selectedIndex,
                onTap: (int index) {
                    setState(() {
                        selectedIndex = index;
                    });
                },
            ),
          ),
        );
    }
}

class _BottomNavigationBar extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Container(
            height: 58,
            padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                ),
                ],
            ),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    SizedBox(
                        height: 58,
                        width: 78,
                        child: TextButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(0),
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(),
                                overlayColor: Colors.transparent,
                                splashFactory: NoSplash.splashFactory
                            ),
                            onPressed: () {
                                //
                            }, 
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.school_outlined, color: Theme.of(context).iconTheme.color, size: Theme.of(context).iconTheme.size),
                                    Text("Record", style: Theme.of(context).textTheme.displaySmall,)
                                ],
                            )
                        ),
                    ),
                        IconButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.all(0)
                        ),
                        onPressed: () {
                            //
                        }, 
                        icon: Icon(Icons.abc)
                    )
                ],
            ),
        );
    }
}

class Home extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Center(
            child: ElevatedButton(
                onPressed: () {
                  
                },
                child: const Text("Go To Intro")
            ),
        );
    }
}
