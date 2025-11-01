import 'package:coin_log/models/Account.dart';
import 'package:coin_log/views/settings/account_details.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/shared_widgets/grid_view_icon.dart';
import 'package:logging/logging.dart';
import 'package:reorderables/reorderables.dart';
import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/services/AccountService.dart';

class AccountList extends StatefulWidget {
  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  final _log = Logger('AccountDetails');
  AccountService _accountService = AccountService();

  List<Account> _accounts = [];
  int? _reorderIndex;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final accounts = await _accountService.listByIsClosed(false);
    for (Account account in accounts) {
      print(account.toMap());
    }
    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Accounts"),
          actions: [
            IconButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AccountDetails()));
                  if (result == "reload") {
                    load();
                  }
                },
                icon: const Icon(Icons.add_box)
            )
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: MediaQuery.of(context).size.width,
                          child: PrimaryScrollController(
                            controller: ScrollController(),
                            child: ReorderableWrap(
                                spacing: 2.0,
                                runSpacing: 2.0,
                                maxMainAxisCount: 4,
                                buildDraggableFeedback: (context, constraints, child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GridViewIcon(iconData: getAccountIconData(_accounts[_reorderIndex!].icon), containerSize: 55, iconSize: 26),
                                    ],
                                  );
                                },
                                onReorderStarted: (index) {
                                  setState(() {
                                    _reorderIndex = index;
                                  });
                                },
                                onReorder: (oldIndex, newIndex) async {
                                  setState(() {
                                    _reorderIndex = null;
                                    final item = _accounts.removeAt(oldIndex);
                                    _accounts.insert(newIndex, item);
                                  });

                                  await _accountService.updateSequence(_accounts);
                                },
                                children: List.generate(_accounts.length, (index) {
                                  return SizedBox(
                                    width: (MediaQuery.of(context).size.width / 4) - 4,
                                    height: 85,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AccountDetails(identifier: _accounts[index].identifier)));
                                        if (result == "reload") {
                                          load();
                                        }
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          GridViewIcon(iconData: getAccountIconData(_accounts[index].icon)),
                                          Text(_accounts[index].name, textAlign: TextAlign.center, style: TextStyle(fontSize: 13))
                                        ],
                                      ),
                                    ),
                                  );
                                })
                            ),
                          )
                      ),
                    ),
                  ),
                ),
              ]
          ),
        )
      )
    );
  }
}