import 'dart:async';

import 'package:coin_log/constants/WeekMap.dart';
import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/services/RecordService.dart';
import 'package:coin_log/utils/Calculator.dart';
import 'package:coin_log/views/AppFrame/AppFrame.dart';
import 'package:coin_log/widgets/ThemedTextField.dart';
import 'package:coin_log/widgets/ThemedToast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:coin_log/widgets/SwitchButton.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';

import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/objects/Record.dart';
import 'package:logging/logging.dart';

class RecordDetails extends StatefulWidget {
  int? identifier;

  RecordDetails({
    super.key,
    this.identifier
  });

  @override
  State<RecordDetails> createState() => _RecordDetailsState();
}

class _RecordDetailsState extends State<RecordDetails> {
  final _log = Logger('RecordDetails');

  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  AccountService _accountService = AccountService();
  RecordService _recordService = RecordService();

  Record _record = Record(transactionCategoryId: 0, sourceAccountId: 0, date: DateTime.now(), type: "Expense", amount: 0.0);
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

    _keyboardSubscription = KeyboardVisibilityController().onChange.listen((isVisible) {
      setState(() {
        _isKeyboardVisible = isVisible;
      });
    });

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
      if (["Expense", "Income"].contains(_record.type)) {
        _selectedAccountId = _record.sourceAccountId;
      }

      else if (_record.type == "Transfer") {
        _selectedSourceAccountId = _record.sourceAccountId;
        _selectedDestinationAccountId = _record.destinationAccountId;
      }
    });
  }

  Future<void> loadRecord(int identifier) async {
    final _record = await _recordService.findById(identifier);

    if (_record != null) {
      setState(() {
        this._record = _record;
        _amount = _record.amount.toStringAsFixed(2);
        _selectedTransactionCategoryId = _record.transactionCategoryId;
      });
    }
  }

  Future<void> loadTransactionCategories() async {
    final _transactionCategories = await _transactionCategoryService.listByType(_record.type);

    setState(() {
      this._transactionCategories = _transactionCategories;
    });
  }

  Future<void> loadAccounts() async {
    final _accounts = await _accountService.list();

    if (widget.identifier == null) {
      Account defaultAccount = _accounts.where((account) => account.isDefault == true).toList().first;
      _selectedAccountId = defaultAccount.identifier;
    }

    setState(() {
      this._accounts = _accounts;
    });
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    _descriptionController.dispose();
    super.dispose();
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
                            labels: ["Expense", "Income", "Transfer"],
                            selectedValue: _record.type,
                            onChanged: (String value) {
                              setState(() {
                                _selectedTransactionCategoryId = null;
                                _selectedSourceAccountId = null;
                                _selectedDestinationAccountId = null;
                                _record.type = value;
                              });
                              loadTransactionCategories();
                            },
                          )
                        ),
                        if (['Expense', 'Income'].contains(_record.type)) ... {
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
                                              GridViewIcon(iconData: coinLogTransactionCategoryIconMap[_transactionCategories[itemIndex].icon]!.icon, isSelected: _transactionCategories[itemIndex].identifier == _selectedTransactionCategoryId,),
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
                                                GridViewIcon(iconData: coinLogAccountIconMap[_accounts[itemIndex].icon]!.icon, isSelected: _selectedAccountId == null ? _accounts[itemIndex].isDefault : _accounts[itemIndex].identifier == _selectedAccountId,),
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
                        else if (_record.type == "Transfer") ... {
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
                                              GridViewIcon(iconData: coinLogAccountIconMap[_accounts[itemIndex].icon]!.icon, isSelected: _accounts[itemIndex].identifier == _selectedSourceAccountId, isDisabled: _accounts[itemIndex].identifier == _selectedDestinationAccountId,),
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
                                              GridViewIcon(iconData: coinLogAccountIconMap[_accounts[itemIndex].icon]!.icon, isSelected: _accounts[itemIndex].identifier == _selectedDestinationAccountId, isDisabled: _accounts[itemIndex].identifier == _selectedSourceAccountId),
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
                    descriptionController: _descriptionController,
                    amount: _amount,
                    date: _record.date,
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
                          _record.date = selectedDate;
                        });
                      }
                    },
                    onSaveButtonPressed: () async {
                      if (_record.type == "Expense" || _record.type == "Income") {
                        if (_selectedTransactionCategoryId == null || _selectedTransactionCategoryId == 0) {
                          return ThemedToast.showToast("Invalid Transaction Category");
                        }

                        else if (_selectedAccountId == null || _selectedAccountId == 0) {
                          return ThemedToast.showToast("Invalid Account");
                        }

                        _record.transactionCategoryId = _selectedTransactionCategoryId!;
                        _record.sourceAccountId = _selectedAccountId!;

                        Calculator calculator = Calculator(_amount);
                        setState(() {
                          _amount = calculator.onCalculate();
                        });
                        _record.amount = double.parse(_amount);

                        if (widget.identifier == null) {
                          int? identifier = await _recordService.saveTransaction(_record);
                          _log.info("Saved ${_record.toMap()}");

                          Navigator.of(context).pop(["reload", _record.date]);
                        }

                        else {
                          int? identifier = await _recordService.updateTransaction(_record);
                          _log.info("Updated ${_record.toMap()}");

                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AppFramePage()), (Route<dynamic> route) => false);
                        }

                      }

                      else if (_record.type == "Transfer") {
                        if (_selectedSourceAccountId == null) {
                          return ThemedToast.showToast("Invalid Source Account");
                        }

                        if (_selectedDestinationAccountId == null) {
                          return ThemedToast.showToast("Invalid Destination Account");
                        }

                        Calculator calculator = Calculator(_amount);
                        setState(() {
                          _amount = calculator.onCalculate();
                        });

                        _record.sourceAccountId = _selectedSourceAccountId;
                        _record.destinationAccountId = _selectedDestinationAccountId;

                        _record.amount = double.parse(_amount);

                        if (widget.identifier == null) {
                          int? identifier = await _recordService.saveTransfer(_record);
                          _log.info("Saved ${_record.toMap()}");

                          Navigator.of(context).pop(["reload", _record.date]);
                        }

                        else {
                          int? identifier = await _recordService.updateTransfer(_record);
                          _log.info("Updated ${_record.toMap()}");

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
  TextEditingController? descriptionController = TextEditingController();
  String? amount = "";
  DateTime? date;
  final void Function(String)? onValueButtonPressed;
  final void Function()? onDateButtonPressed;
  final void Function()? onSaveButtonPressed;

  RecordDetailsKeyboard({
    super.key,
    required this.isKeyboardVisible,
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
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
