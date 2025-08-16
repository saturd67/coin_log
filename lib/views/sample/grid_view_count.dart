// GridView.count(
// crossAxisCount: 4,
// shrinkWrap: true,
// children: List.generate(transactionCategories.length, (index) {
// return GestureDetector(
// onTap: () async {
// final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionDetails(identifier: transactionCategories[index].identifier)));
//
// if (result == "reload") {
// loadTransactionCategories();
// }
// },
// child: Column(
// mainAxisSize: MainAxisSize.max,
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// GridViewIcon(iconData: coinLogIconMap[transactionCategories[index].icon]!.icon),
// Text(transactionCategories[index].name, style: TextStyle(fontSize: 13),)
// ],
// ),
// );