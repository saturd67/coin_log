import 'dart:async';

import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/TransactionCategory.dart';
import 'package:coin_log/utils/Calculator.dart';
import 'package:coin_log/widgets/ThemedTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:coin_log/widgets/SwitchButton.dart';
import 'package:coin_log/widgets/GridViewIcon.dart';
import 'package:math_expressions/math_expressions.dart';

import 'package:coin_log/constants/IconMap.dart';
import 'package:coin_log/services/TransactionCategoryService.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/objects/Record.dart';

class RecordDetails extends StatefulWidget {
  @override
  State<RecordDetails> createState() => _RecordDetailsState();
}

class _RecordDetailsState extends State<RecordDetails> {

  TransactionCategoryService _transactionCategoryService = TransactionCategoryService();
  AccountService _accountService = AccountService();

  Record _record = Record(transactionCategoryId: 0, accountId: 0, date: DateTime.now(), entryType: "Out", amount: 0.0);
  List<TransactionCategory> _transactionCategories = [];
  List<Account> _accounts = [];
  String _selectedType = "Expense";
  int? _selectedTransactionCategoryId;
  int? _selectedAccountId;
  int? _selectedSourceAccountId;
  int? _selectedDestinationAccountId;
  TextEditingController _descriptionController = TextEditingController();
  String _amount = "0";
  double _targetItemsPerColumn = 4;
  double _sourceItemsPerColumn = 1;

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

    loadTransactionCategories();
    loadAccounts();
  }

  void loadTransactionCategories() async {
    final _transactionCategories = await _transactionCategoryService.listByType(_selectedType);

    setState(() {
      this._transactionCategories = _transactionCategories;
    });
  }

  void loadAccounts() async {
    final _accounts = await _accountService.list();

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
                            selectedValue: _selectedType,
                            onChanged: (String value) {
                              setState(() {
                                _selectedTransactionCategoryId = null;
                                _selectedSourceAccountId = null;
                                _selectedDestinationAccountId = null;
                                _selectedType = value;
                              });
                              loadTransactionCategories();
                            },
                          )
                        ),
                        if (['Expense', 'Income'].contains(_selectedType)) ... {
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: SizedBox(
                              height: 265,
                              child: PageView.builder(
                                itemCount: (_transactionCategories.length / 12).ceil(), // Number of pages
                                itemBuilder: (context, pageIndex) {
                                  return GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.25,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: 12, // 4 items per page
                                    itemBuilder: (context, index) {
                                      int itemIndex = pageIndex * 4 + index;
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
                        },
                        if (_selectedType == "Transfer") ... {
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
                                              _selectedSourceAccountId = _accounts[itemIndex].identifier!;
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (itemIndex < _accounts.length) ... {
                                                GridViewIcon(iconData: coinLogAccountIconMap[_accounts[itemIndex].icon]!.icon, isSelected: _accounts[itemIndex].identifier == _selectedSourceAccountId),
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
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedDestinationAccountId = _accounts[itemIndex].identifier;
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (itemIndex < _accounts.length) ... {
                                                GridViewIcon(iconData: coinLogAccountIconMap[_accounts[itemIndex].icon]!.icon, isSelected: _accounts[itemIndex].identifier == _selectedDestinationAccountId),
                                                Text(_accounts[itemIndex].name, style: TextStyle(fontSize: 13))
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
                      onButtonPressed: (String input) {
                        Calculator calculator = Calculator(_amount);
                        final tempAmount = calculator.onInput(input);
                        setState(() {
                          _amount = tempAmount;
                        });
                      }
                  )
                ),
              ],
            ),
          )
        )
      );
  }

  void calculate(String expressionString) {
    ExpressionParser parser = GrammarParser();
    Expression expression = parser.parse(expressionString);
    ContextModel contextModel = ContextModel();

    double result = expression.evaluate(EvaluationType.REAL, contextModel);

    setState(() {
      print(result * 100 % 100);
      if (result * 100 % 100 == 0) {
        _amount = result.toStringAsFixed(0);
      }

      else {
        _amount = result.toStringAsFixed(2);
      }
    });
  }

  void deleteInput() {
    setState(() {
      _amount = _amount.substring(0, _amount.length - 1);
    });
  }
}

class RecordDetailsKeyboard extends StatefulWidget {

  bool isKeyboardVisible;
  TextEditingController? descriptionController = TextEditingController();
  String? amount = "";
  final void Function(String)? onButtonPressed;

  RecordDetailsKeyboard({
    super.key,
    required this.isKeyboardVisible,
    this.descriptionController,
    this.amount,
    this.onButtonPressed
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
                        RecordDetailsKeyboardButton(buttonText: "7", onButtonPressed: widget.onButtonPressed),
                        RecordDetailsKeyboardButton(buttonText: "8", onButtonPressed: widget.onButtonPressed),
                        RecordDetailsKeyboardButton(buttonText: "9", onButtonPressed: widget.onButtonPressed),
                        RecordDetailsKeyboardButton(buttonText: "Date: ", onButtonPressed: widget.onButtonPressed),
                      ],
                    ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "4", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "5", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "6", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "+", onButtonPressed: widget.onButtonPressed),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: "1", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "2", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "3", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "-", onButtonPressed: widget.onButtonPressed),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         RecordDetailsKeyboardButton(buttonText: ".", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "0", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "Del", onButtonPressed: widget.onButtonPressed),
                         RecordDetailsKeyboardButton(buttonText: "=", onButtonPressed: widget.onButtonPressed),
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

class RecordDetailsKeyboardButton extends StatefulWidget {
  String buttonText;
  final void Function(String)? onButtonPressed;

  RecordDetailsKeyboardButton({
    super.key,
    required this.buttonText,
    this.onButtonPressed
  });

  @override
  State<RecordDetailsKeyboardButton> createState() => _RecordDetailsKeyboardButtonState();
}

class _RecordDetailsKeyboardButtonState extends State<RecordDetailsKeyboardButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.onButtonPressed != null) {
            widget.onButtonPressed!(widget.buttonText);
          }
        },
        onTapDown: (_) {
          setState(() {
            pressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            pressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            pressed = false;
          });
        },
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: pressed ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(6)
              ),
              child: Center(
                child: Text(widget.buttonText)
              ),
            ),
          ),
        ),
      ),
    );
  }
}
