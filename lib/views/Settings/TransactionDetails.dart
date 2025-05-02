import 'package:coin_log/widgets/ThemedTextField.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';
import 'package:coin_log/widgets/SwitchButton.dart';
import 'package:coin_log/constants/TransactionCategoryMap.dart';

class TransactionDetails extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Transaction Details"),
          actions: [
            IconButton(
              onPressed: () {
                print("Save");
              }, 
              icon: const Icon(Icons.check)
            )
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 12.0, 2.0, 6.0),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.tertiary
                      ),
                      child: Icon(Icons.picture_in_picture),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ThemedTextField(placeholder: "Name")
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10), 
                child: SwitchButton(labels: ["Expense", "Income"])
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: getGroupedIcons().entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                              child: Text(entry.key.value.toString(), style: TextStyle(fontWeight: FontWeight.bold),)
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GridViewIcon(icon: entry.value[index].icon),
                                  Text(entry.value[index].name, style: TextStyle(fontSize: 13))
                                ],
                              );
                            }
                          )
                        ],
                      );
                    }).toList(),
                  )
                ),
              )
              // for (int i = 0; i < CoinLogIconCategory.values.length; i++) ... {
              //   Column(
              //     mainAxisSize: MainAxisSize.max,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(CoinLogIconCategory.values[i].value.toString()),
              //       SizedBox(
              //         height: MediaQuery.of(context).size.height * 0.75,
              //         child: GridView.count(
              //           crossAxisCount: 4,
              //           shrinkWrap: true,
              //           children: List.generate(50, (index) {
              //             return Column(
              //               mainAxisSize: MainAxisSize.max,
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 GridViewIcon(),
              //                 Text("Item ${index + 1}", style: TextStyle(fontSize: 13),)
              //               ],
              //             );
              //           }),
              //         ),
              //       ),
              //     ]
              //   )
              // }
            ]
          ),
        )
      )
    );
  }
}