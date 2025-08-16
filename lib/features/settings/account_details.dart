import 'package:coin_log/main.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/shared/themed_switch.dart';
import 'package:coin_log/shared/themed_text_field.dart';
import 'package:coin_log/shared/themed_toast.dart';
import 'package:coin_log/shared/showConfirmationDialog.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/shared/grid_view_icon.dart';
import 'package:coin_log/constants/IconMap.dart';
import 'package:logging/logging.dart';

class AccountDetails extends StatefulWidget {

  final int? identifier;

  AccountDetails({
    super.key,
    this.identifier
  });

  @override
  State<AccountDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<AccountDetails> {
  final _log = Logger('AccountDetails');
  final AccountService accountService = AccountService();

  int? _identifier;
  late Account _account = Account(name: "", icon: "", sequence: 1, balance: 0.0, isDefault: false, isDeleted: false);
  IconData? onDisplayIconData;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _identifier = widget.identifier;

    if (widget.identifier != null) {
      load();
    }
  }

  void load() async {
    final _account = await accountService.findById(widget.identifier!);
    setState(() {
      this._account = _account!;
      _controller.text = this._account.name;
      onDisplayIconData = getAccountIconData(this._account.icon);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              shadowColor: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Account Details"),
              actions: [
                IconButton(
                    onPressed: () async {
                      _account.name = _controller.text;

                      if (_account.name == "") {
                        ThemedToast.showToast("Invalid Name.");
                        return;
                      }

                      if (_account.icon == "") {
                        ThemedToast.showToast("Invalid Icon.");
                        return;
                      }

                      if (_identifier == null) {
                        int? identifier = await accountService.save(_account);
                        _account.identifier = identifier;

                        _log.info("Saved ${_account.toMap()}");
                      }

                      else {
                        int? identifier = await accountService.update(_account);

                        _log.info("Updated ${_account.toMap()}");
                      }

                      Navigator.of(context).pop("reload");
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
                      padding: const EdgeInsets.fromLTRB(2.0, 12.0, 12.0, 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: 65,
                            height: 45,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: onDisplayIconData != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary
                            ),
                            child: Icon(onDisplayIconData ?? Icons.picture_in_picture, color: onDisplayIconData != null ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color),
                          ),
                          Expanded(
                              child: ThemedTextField(
                                placeholder: "Name",
                                maxLenght: 10,
                                controller: _controller,
                              )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("Default: "),
                                ThemedSwitch(
                                  value: _account.isDefault,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _account.isDefault = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_identifier != null)
                              IconButton(
                                  onPressed: () async {
                                    showConfirmationDialog(
                                        context,
                                        "Are you sure you want to delete?",
                                            () async {
                                          await accountService.delete(_identifier!);
                                          Navigator.of(context).pop("reload");
                                        },
                                            () {});
                                  },
                                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.danger)
                              )
                          ],
                        )
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                            children: getGroupedIcons(accountIconMap).entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                                        child: Text(entry.key.value.toString())
                                    ),
                                  ),
                                  GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 2.0,
                                        mainAxisSpacing: 2.0,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: entry.value.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _account.icon = entry.value[index].keys.first;
                                              onDisplayIconData = getAccountIconData(_account.icon);
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GridViewIcon(iconData: entry.value[index].values.first.iconData, isSelected: entry.value[index].keys.first == _account.icon),
                                              Text(entry.value[index].values.first.name, style: TextStyle(fontSize: 13))
                                            ],
                                          ),
                                        );
                                      }
                                  )
                                ],
                              );
                            }).toList(),
                          )
                      ),
                    )
                  ]
              ),
            )
        )
    );
  }
}