import 'package:coin_log/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/views/settings/transaction_list.dart';
import 'package:coin_log/views/settings/account_list.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  DatabaseService _databaseService = DatabaseService();
  
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
          SettingItem(icon: Icons.download, name: "Backup", action: () { 
            _databaseService.backupDatabaseToDownloads();
          })
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  IconData icon;
  String name;
  Widget? page;
  void Function()? action;

  SettingItem({
    super.key,
    required this.icon,
    required this.name,
    this.page,
    this.action
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.of(context).push(RouterUtils.createRoute(page!));
        }

        if (action != null) {
          action!();
        }
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