import 'dart:async';

import 'package:coin_log/constants/WeekMap.dart';
import 'package:coin_log/form_models/RecordFormModel.dart';
import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/utils/Calculator.dart';
import 'package:coin_log/views/app_frame/app_frame.dart';
import 'package:coin_log/shared_widgets/themed_text_field.dart';
import 'package:coin_log/shared_widgets/themed_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:coin_log/shared_widgets/switch_button.dart';
import 'package:coin_log/shared_widgets/grid_view_icon.dart';

import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/models/Record.dart';
import 'package:logging/logging.dart';

class RecordDetails extends StatefulWidget {
  int? identifier;
  DateTime? defaultDateTime;

  RecordDetails({
    super.key,
    this.identifier,
    this.defaultDateTime
  });

  @override
  State<RecordDetails> createState() => _RecordDetailsState();
}

class _RecordDetailsState extends State<RecordDetails> {
  final _log = Logger('RecordDetails');

  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  AccountService _accountService = AccountService();
  RecordService _recordService = RecordService();

  RecordFormModel _recordFormModel = RecordFormModel(date: DateTime.now(), type: RecordType.expense.name);
  // Record _record = Record(transactionCategoryId: 0, sourceAccountId: 0, date: DateTime.now(), type: RecordType.expense.name, amount: 0.0);
  List<TransactionCategory> _transactionCategories = [];
  List<Account> _accounts = [];
  int? _selectedTransactionCategoryId;
  int? _selectedAccountId;
  int? _selectedSourceAccountId;
  int? _selectedDestinationAccountId;
  TextEditingController _descriptionController = TextEditingController();
  String _amount = "0";

  bool _isKeyboardVisible = false;
  late final KeyboardVisibilityController keyboardVisibilityController;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();

    // Setup keyboard
    _keyboardSubscription = KeyboardVisibilityController().onChange.listen((isVisible) {
      setState(() {
        _isKeyboardVisible = isVisible;
      });
    });

    if (widget.defaultDateTime != null) {
      setState(() {
        _recordFormModel.date = widget.defaultDateTime!;
      });
    }

    if (widget.identifier != null) {
      load(widget.identifier!);
    }

    else {
      loadTransactionCategories();
      loadAccounts();
    }
  }

  void load(int identifier) async {
    await loadRecord(identifier);
    await Future.wait([
      loadTransactionCategories(),
      loadAccounts()
    ]);

    setState(() {
      if ([RecordType.expense.name, RecordType.income.name].contains(_recordFormModel.type)) {
        _selectedAccountId = _recordFormModel.sourceAccountId;
      }

      else if (_recordFormModel.type == RecordType.transfer.name) {
        _selectedSourceAccountId = _recordFormModel.sourceAccountId;
        _selectedDestinationAccountId = _recordFormModel.destinationAccountId;
      }
    });
  }

  Future<void> loadRecord(int identifier) async {
    final record = await _recordService.findById(identifier);

    if (record != null) {
      setState(() {
        _recordFormModel = record.toFormModel();
        _amount = record.amount.toStringAsFixed(2);
        _selectedTransactionCategoryId = record.transactionCategoryId;
      });
    }
  }

  Future<void> loadTransactionCategories() async {
    final transactionCategories = await _transactionCategoryService.listByType(_recordFormModel.type!);

    setState(() {
      _transactionCategories = transactionCategories;
    });
  }

  Future<void> loadAccounts() async {
    final accounts = await _accountService.list();

    if (widget.identifier == null) {
      Account defaultAccount = accounts.where((account) => account.isDefault == true).toList().first;
      _selectedAccountId = defaultAccount.identifier;
    }

    setState(() {
      _accounts = accounts;
    });
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  Account? getSelectedAccount() {
    if ([RecordType.income.name, RecordType.expense.name].contains(_recordFormModel.type)) {
      return _selectedAccountId == null ? null : _accounts.firstWhere((account) => account.identifier == _selectedAccountId);
    }

    else if (RecordType.transfer.name == _recordFormModel.type) {
      return _selectedSourceAccountId == null ? null : _accounts.firstWhere((account) => account.identifier == _selectedSourceAccountId);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Record Details")
          ),
          body: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), 
                          child: SwitchButton(
                            labels: widget.identifier == null ? [RecordType.expense.name, RecordType.income.name, RecordType.transfer.name] : [RecordType.expense.name, RecordType.income.name].contains(_recordFormModel.type) ? [RecordType.expense.name, RecordType.income.name] : [RecordType.transfer.name],
                            selectedValue: _recordFormModel.type!,
                            onChanged: (String value) {
                              setState(() {
                                _selectedTransactionCategoryId = null;
                                _selectedSourceAccountId = null;
                                _selectedDestinationAccountId = null;
                                _recordFormModel.type = value;
                              });
                              loadTransactionCategories();
                            },
                          )
                        ),
                        if (['Expense', 'Income'].contains(_recordFormModel.type)) ... {
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: SizedBox(
                              height: 175,
                              child: PageView.builder(
                                itemCount: (_transactionCategories.length / 8).ceil(), // Number of pages
                                itemBuilder: (context, pageIndex) {
                                  int itemPerPage = 8;
                                  return GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.25,
                                      mainAxisSpacing: itemPerPage.toDouble(),
                                    ),
                                    itemCount: itemPerPage,
                                    itemBuilder: (context, index) {
                                      int itemIndex = pageIndex * itemPerPage + index;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedTransactionCategoryId = _transactionCategories[itemIndex].identifier!;
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (itemIndex < _transactionCategories.length) ... {
                                              GridViewIcon(iconData: getTransactionCategoryIconData(_transactionCategories[itemIndex].icon), isSelected: _transactionCategories[itemIndex].identifier == _selectedTransactionCategoryId,),
                                              Text(_transactionCategories[itemIndex].name, style: TextStyle(
                                                  fontSize: 13
                                              ),)
                                            }
                                          ],
                                        ),
                                      );
                                    },
                                    physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), child: Text("From: ", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: SizedBox(
                                height: 85,
                                child: PageView.builder(
                                  itemCount: (_accounts.length / 4).ceil(), // Number of pages
                                  itemBuilder: (context, pageIndex) {
                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 1.25,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        int itemIndex = pageIndex * 4 + index;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedAccountId = _accounts[itemIndex].identifier!;
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (itemIndex < _accounts.length) ... {
                                                GridViewIcon(iconData: getAccountIconData(_accounts[itemIndex].icon), isSelected: _selectedAccountId == null ? _accounts[itemIndex].isDefault : _accounts[itemIndex].identifier == _selectedAccountId,),
                                                Text(_accounts[itemIndex].name, style: TextStyle(fontSize: 13),)
                                              }
                                            ],
                                          ),
                                        );
                                      },
                                      physics: NeverScrollableScrollPhysics(),
                                    );
                                  },
                                )
                            ),
                          ),
                        }
                        else if (_recordFormModel.type == RecordType.transfer.name) ... {
                          Padding(padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), child: Text("From: ", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: SizedBox(
                                height: 85,
                                child: PageView.builder(
                                  itemCount: (_accounts.length / 4).ceil(), // Number of pages
                                  itemBuilder: (context, pageIndex) {
                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 1.25,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        int itemIndex = pageIndex * 4 + index;
                                        return  (itemIndex < _accounts.length) ? GestureDetector(
                                          onTap: _accounts[itemIndex].identifier == _selectedDestinationAccountId ? () {} : () {
                                            setState(() {
                                              _selectedSourceAccountId = _accounts[itemIndex].identifier!;
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GridViewIcon(iconData: getAccountIconData(_accounts[itemIndex].icon), isSelected: _accounts[itemIndex].identifier == _selectedSourceAccountId, isDisabled: _accounts[itemIndex].identifier == _selectedDestinationAccountId,),
                                              Text(_accounts[itemIndex].name, style: TextStyle(fontSize: 13),)
                                            ],
                                          ),
                                        ) : null;
                                      },
                                      physics: NeverScrollableScrollPhysics(),
                                    );
                                  },
                                )
                            ),
                          ),
                          Padding(padding: EdgeInsetsDirectional.fromSTEB(10, 10, 0, 0), child: Text("To: ", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: SizedBox(
                                height: 85,
                                child: PageView.builder(
                                  itemCount: (_accounts.length / 4).ceil(), // Number of pages
                                  itemBuilder: (context, pageIndex) {
                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 1.25,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        int itemIndex = pageIndex * 4 + index;
                                        return (itemIndex < _accounts.length) ? GestureDetector(
                                          onTap: _accounts[itemIndex].identifier == _selectedSourceAccountId ? () {} : () {
                                            setState(() {
                                              _selectedDestinationAccountId = _accounts[itemIndex].identifier;
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GridViewIcon(iconData: getAccountIconData(_accounts[itemIndex].icon), isSelected: _accounts[itemIndex].identifier == _selectedDestinationAccountId, isDisabled: _accounts[itemIndex].identifier == _selectedSourceAccountId),
                                              Text(_accounts[itemIndex].name, style: TextStyle(fontSize: 13))
                                            ],
                                          ),
                                        ) : null;
                                      },
                                      physics: NeverScrollableScrollPhysics(),
                                    );
                                  },
                                )
                            ),
                          ),
                        }
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: _isKeyboardVisible ? 95: 270,
                  child: RecordDetailsKeyboard(
                    isKeyboardVisible: _isKeyboardVisible,
                    sourceAccount: getSelectedAccount(),
                    descriptionController: _descriptionController,
                    amount: _amount,
                    date: _recordFormModel.date,
                    onValueButtonPressed: (String input) {
                      Calculator calculator = Calculator(_amount);
                      final tempAmount = calculator.onInput(input);
                      setState(() {
                        _amount = tempAmount;
                      });
                    },
                    onDateButtonPressed: () async {
                      final DateTime? selectedDate = await showDatePicker(
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).colorScheme.primary,
                                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                                  surface: Theme.of(context).colorScheme.secondary,
                                  onSurface: Theme.of(context).textTheme.bodyMedium!.color!
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                  )
                                )
                              ),
                              child: child!
                            );
                          },
                          context: context,
                          helpText: "Date",
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2001),
                          lastDate: DateTime(2100)
                      );

                      if (selectedDate != null) {
                        setState(() {
                          _recordFormModel.date = selectedDate;
                        });
                      }
                    },
                    onSaveButtonPressed: () async {
                      if (_recordFormModel.type == RecordType.expense.name || _recordFormModel.type == RecordType.income.name) {
                        Record record;
                        try {
                          _recordFormModel.transactionCategoryId = _selectedTransactionCategoryId;
                          _recordFormModel.sourceAccountId = _selectedAccountId;

                          Calculator calculator = Calculator(_amount);
                          setState(() {
                            _amount = calculator.onCalculate();
                          });
                          _recordFormModel.amount = double.parse(_amount);

                          if (_recordFormModel.transactionCategoryId == null) {
                            throw "Invalid Transaction Category";
                          }

                          if (_recordFormModel.sourceAccountId == null) {
                            throw "Invalid Source Account";
                          }

                          record = _recordFormModel.toModel();
                        }
                        catch(e) {
                          ThemedToast.showToast(e.toString());
                          return;
                        }

                        if (widget.identifier == null) {
                          int? identifier = await _recordService.saveTransaction(record);
                          _log.info("Saved ${record.toMap()}");

                          Navigator.of(context).pop(["reload", record.date]);
                        }

                        else {
                          print(record.amount);
                          int? identifier = await _recordService.updateTransaction(record);
                          _log.info("Updated ${record.toMap()}");

                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AppFramePage()), (Route<dynamic> route) => false);
                        }

                      }

                      else if (_recordFormModel.type == RecordType.transfer.name) {
                        Record record;
                        try {
                          _recordFormModel.sourceAccountId = _selectedSourceAccountId;
                          _recordFormModel.destinationAccountId = _selectedDestinationAccountId;

                          Calculator calculator = Calculator(_amount);
                          setState(() {
                            _amount = calculator.onCalculate();
                          });
                          _recordFormModel.amount = double.parse(_amount);

                          if (_recordFormModel.sourceAccountId == null) {
                            throw "Invalid Source Account";
                          }

                          if (_recordFormModel.destinationAccountId == null) {
                            throw "Invalid Source Account";
                          }

                          record = _recordFormModel.toModel();
                        } catch(e) {
                          ThemedToast.showToast(e.toString());
                          return;
                        }

                        if (widget.identifier == null) {
                          int? identifier = await _recordService.saveTransfer(record);
                          _log.info("Saved ${record.toMap()}");

                          Navigator.of(context).pop(["reload", record.date]);
                        }

                        else {
                          int? identifier = await _recordService.updateTransfer(record);
                          _log.info("Updated ${record.toMap()}");

                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AppFramePage()), (Route<dynamic> route) => false);
                        }
                      }
                    }
                  )
                ),
              ],
            ),
          )
        )
      );
  }
}

@immutable
class RecordDetailsKeyboard extends StatefulWidget {

  bool isKeyboardVisible;
  Account? sourceAccount;
  TextEditingController? descriptionController = TextEditingController();
  String? amount = "";
  DateTime? date;
  final void Function(String)? onValueButtonPressed;
  final void Function()? onDateButtonPressed;
  final void Function()? onSaveButtonPressed;

  RecordDetailsKeyboard({
    super.key,
    required this.isKeyboardVisible,
    this.sourceAccount,
    this.descriptionController,
    this.amount,
    this.date,
    this.onValueButtonPressed,
    this.onDateButtonPressed,
    this.onSaveButtonPressed
  });

  @override
  State<RecordDetailsKeyboard> createState() => _RecordDetailsKeyboardState();
}

class _RecordDetailsKeyboardState extends State<RecordDetailsKeyboard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money),
                      Text(style: Theme.of(context).textTheme.bodyMedium, widget.sourceAccount == null ? "" : widget.sourceAccount!.balance.toStringAsFixed(2)),
                    ],
                  ),
                  Text(style: Theme.of(context).textTheme.bodyLarge, widget.amount ?? widget.amount!),
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6.0),
              child: ThemedTextField(
                placeholder: "Descriptions",
                controller: widget.descriptionController
              )
            ),
            if (!widget.isKeyboardVisible)
              SizedBox(
                height: 175,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RecordDetailsKeyboardButton(buttonText: "7", onValueButtonPressed: widget.onValueButtonPressed),
                        RecordDetailsKeyboardButton(buttonText: "8", onValueButtonPressed: widget.onValueButtonPressed),
                        RecordDetailsKeyboardButton(buttonText: "9", onValueButtonPressed: widget.onValueButtonPressed),
                        RecordDetailsKeyboardButton(buttonText: widget.date != null ? "${widget.date!.day}/${widget.date!.month} ${weekMap[widget.date!.weekday.toString()]}" : "", color: Theme.of(context).colorScheme.primary, onDateButtonPressed: widget.onDateButtonPressed),
                      ],
                    ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "4", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "5", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "6", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "+", onValueButtonPressed: widget.onValueButtonPressed),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "1", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "2", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "3", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "-", onValueButtonPressed: widget.onValueButtonPressed),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: ".", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "0", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "Del", onValueButtonPressed: widget.onValueButtonPressed),
                         RecordDetailsKeyboardButton(buttonIcon: Icons.check, color: Theme.of(context).colorScheme.onPrimary, backgroundColor: Theme.of(context).colorScheme.primary, onSaveButtonPressed: widget.onSaveButtonPressed),
                       ],
                     ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

@immutable
class RecordDetailsKeyboardButton extends StatefulWidget {
  String? buttonText;
  IconData? buttonIcon;
  Color? color;
  Color? backgroundColor;
  final void Function(String)? onValueButtonPressed;
  final void Function()? onDateButtonPressed;
  final void Function()? onSaveButtonPressed;

  RecordDetailsKeyboardButton({
    super.key,
    this.buttonText,
    this.buttonIcon,
    this.color,
    this.backgroundColor,
    this.onValueButtonPressed,
    this.onDateButtonPressed,
    this.onSaveButtonPressed
  });

  @override
  State<RecordDetailsKeyboardButton> createState() => _RecordDetailsKeyboardButtonState();
}

class _RecordDetailsKeyboardButtonState extends State<RecordDetailsKeyboardButton> {
  bool _pressed = false;
  Color? _color;
  Color? _backgroundColor;


  @override
  Widget build(BuildContext context) {
    _color = widget.color != null ? widget.color! : Theme.of(context).textTheme.bodyMedium?.color;
    _backgroundColor = widget.backgroundColor != null ? widget.backgroundColor! : Theme.of(context).colorScheme.secondary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.onValueButtonPressed != null && widget.buttonText != null) {
            widget.onValueButtonPressed!(widget.buttonText!);
          }

          else if (widget.onDateButtonPressed != null) {
            widget.onDateButtonPressed!();
          }

          else if (widget.onSaveButtonPressed != null) {
            widget.onSaveButtonPressed!();
          }
        },
        onTapDown: (_) {
          setState(() {
            _pressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _pressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressed = false;
          });
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: _pressed ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(6)
              ),
              child: Center(
                child: widget.buttonText != null ? Text(widget.buttonText!, style: TextStyle(color: _color,)) : widget.buttonIcon != null ? Icon(widget.buttonIcon, color: _color,) : null
              ),
            ),
          ),
        ),
      ),
    );
  }
}
