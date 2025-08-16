import 'package:flutter/material.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/views/Settings/transaction_list.dart';
import 'package:coin_log/views/Settings/account_list.dart';

class Settings extends StatelessWidget {
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(RouterUtils.createRoute(page));
      },
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        height: 65,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                child: Icon(
                  icon,
                  size: 30.0
                ),
              ),
              Text(name)
            ]
          ),
        )
      ),
    );
  }
}