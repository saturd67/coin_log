import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/views/account_log_details.dart';
import 'package:flutter/material.dart';

class AccountsBalance extends StatefulWidget {
  @override
  State<AccountsBalance> createState() => _AccountsBalanceState();
}

class _AccountsBalanceState extends State<AccountsBalance> {

  AccountService _accountService = AccountService();

  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final accounts = await _accountService.listByIsClosed(false);
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text("Accounts")
      ),
      body: ListView(
        children: List.generate(_accounts.length, (index) {
          return AccountsBalanceItem(
            icon: getAccountIconData(_accounts[index].icon),
            name: _accounts[index].name,
            balance: _accounts[index].balance,
            page: AccountLogDetails(identifier: _accounts[index].identifier!)
          );
        })
      ),
    );
  }
}

class AccountsBalanceItem extends StatelessWidget {
  IconData icon;
  String name;
  Widget? page;
  double balance;

  AccountsBalanceItem({
    super.key,
    required this.icon,
    required this.name,
    required this.balance,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.of(context).push(RouterUtils.createRoute(page!));
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        height: 65,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                        icon,
                        size: 30.0
                    ),
                  ),
                  Text(name)
                ],
              ),
              Text(balance.toStringAsFixed(2))
            ]
          )
        ),
      )
    );
  }
}