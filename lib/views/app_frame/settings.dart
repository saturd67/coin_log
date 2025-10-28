import 'package:coin_log/views/settings/budget_list.dart';
import 'package:coin_log/views/settings/data_details.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/views/settings/transaction_list.dart';
import 'package:coin_log/views/settings/account_list.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Settings")
      ),
      body: ListView(
        children: [
          SettingItem(icon: Icons.category, name: "Transactions", page: TransactionList()),
          SettingItem(icon: Icons.monetization_on, name: "Accounts", page: AccountList()),
          SettingItem(icon: Icons.align_horizontal_left, name: "Budgets", page: BudgetList()),
          SettingItem(icon: Icons.dataset_outlined, name: "Data", page: DataDetail())
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  IconData icon;
  String name;
  Widget page;

  SettingItem({
    super.key,
    required this.icon,
    required this.name,
    required this.page
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // required for ripple visibility
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(RouterUtils.createRoute(page));
        },
        splashColor: Colors.grey[300],    // ripple color
        highlightColor: Colors.grey[300], // gray color on press
        child: Ink(
          color: Theme.of(context).colorScheme.secondary, // your original color
          height: 65,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(icon, size: 30.0),
                ),
                Text(name),
              ],
            ),
          ),
        ),
      ),
    );
  }

}