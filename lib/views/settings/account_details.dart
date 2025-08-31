import 'package:coin_log/form_models/AccountFormModel.dart';
import 'package:coin_log/main.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/shared_widgets/themed_switch.dart';
import 'package:coin_log/shared_widgets/themed_text_field.dart';
import 'package:coin_log/shared_widgets/themed_toast.dart';
import 'package:coin_log/shared_widgets/showConfirmationDialog.dart';
import 'package:flutter/material.dart';
import 'package:coin_log/shared_widgets/grid_view_icon.dart';
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

  AccountFormModel _accountFormModel = AccountFormModel(sequence: 1, balance: 0.0, isDefault: false, isClosed: false);
  IconData? onDisplayIconData;

  @override
  void initState() {
    super.initState();
    if (widget.identifier != null) {
      load();
    }
  }

  void load() async {
    final account = await accountService.findById(widget.identifier!);
    if  (account != null) {
      setState(() {
        _accountFormModel = account.toFormModel();
        onDisplayIconData = getAccountIconData(_accountFormModel.icon!);
      });
    }
  }

  @override
  void dispose() {
    _accountFormModel.dispose();
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

                      Account account;
                      try {
                        account = _accountFormModel.toModel();
                      }

                      catch (e) {
                        ThemedToast.showToast(e.toString());
                        return;
                      }

                      if (widget.identifier == null) {
                        int? identifier = await accountService.save(account);
                        account.identifier = identifier;

                        _log.info("Saved ${account.toMap()}");
                      }

                      else {
                        int? identifier = await accountService.update(account);

                        _log.info("Updated ${account.toMap()}");
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
                                maxLength: 10,
                                controller: _accountFormModel.nameController,
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
                                  value: _accountFormModel.isDefault!,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _accountFormModel.isDefault = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (widget.identifier != null)
                              IconButton(
                                  onPressed: () async {
                                    showConfirmationDialog(
                                        context,
                                        "Are you sure you want to delete?",
                                            () async {
                                          await accountService.delete(widget.identifier!);
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
                                              _accountFormModel.icon = entry.value[index].keys.first;
                                              onDisplayIconData = getAccountIconData(_accountFormModel.icon!);
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GridViewIcon(iconData: entry.value[index].values.first.iconData, isSelected: entry.value[index].keys.first == _accountFormModel.icon),
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