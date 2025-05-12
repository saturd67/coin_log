import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/router/RouterUtils.dart';
import 'package:coin_log/services/AccountService.dart';
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
    final _accounts = await _accountService.list();
    setState(() {
      this._accounts = _accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(_accounts.length, (index) {
        return AccountsBalanceItem(icon: coinLogAccountIconMap[_accounts[index].icon]!.icon, name: _accounts[index].name, balance: _accounts[index].balance);
      })
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