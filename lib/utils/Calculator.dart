import 'package:math_expressions/math_expressions.dart';

class Calculator {
  static const String zero = "0";
  static const String one = "1";
  static const String two = "2";
  static const String three = "3";
  static const String four = "4";
  static const String five = "5";
  static const String six = "6";
  static const String seven = "7";
  static const String eight = "8";
  static const String nine = "9";

  static const String plus = "+";
  static const String minus = "-";
  static const String dot = ".";

  static const String delete = "Del";

  static const List<String> numbers = [
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine
  ];

  static const List<String> operators = [
    plus,
    minus
  ];

  String amount;

  Calculator(this.amount);
  
  String onInput(bool isInitialInput, String input) {
    String firstOperand = _getFirstOperand(amount);
    String operator = _getOperator(amount);
    String lastOperand = _getLastOperand(amount);

    if (isInitialInput) {
      if (input == delete) {
        return zero;
      }

      else if (operators.contains(input)) {
        return "$amount $input";
      }

      return input;
    }

    if (input == dot) {
      if (lastOperand == ""){
        lastOperand = "$zero$input";
      }

      else if (!lastOperand.contains(dot)) {
        lastOperand += input;
      }

      return firstOperand + operator + lastOperand;
    }

    else if (num.tryParse(input) != null) {
      if (!lastOperand.contains(dot) && num.tryParse(input) != null) {
        lastOperand = _addValue(lastOperand, input);
      }

      else if (lastOperand.contains(dot) && num.tryParse(input) != null && lastOperand.substring(lastOperand.indexOf(dot)).length <= 2) {
        lastOperand = _addValue(lastOperand, input);
      }

      return firstOperand + operator + lastOperand;
    }

    else if (operators.contains(input) && lastOperand != "") {
      input = " $input ";

      // Exp: 100
      if (firstOperand == "" && operator == "") {
        return lastOperand + input;
      }

      // Exp: 100 +
      else if (firstOperand != "" && operator != "" && lastOperand == "") {
        return firstOperand + input;
      }

      // Exp: 100 + 200
      else if (firstOperand != "" && operator != "" && lastOperand != "") {
        String result = _calculate(firstOperand, operator, lastOperand);
        return result + input;
      }
    }

    else if (input == delete) {

      // Exp: 100 or 100 + 200
      if ((firstOperand == "" && operator == "")
          || (firstOperand != "" && operator != "" && lastOperand != "")
      ) {
        amount = amount.length > 1 ? amount.substring(0, amount.length - 1) : zero;
        return amount;
      }

      // Exp: 100 +
      else if (firstOperand != "" && operator != "" && lastOperand == "") {
        return firstOperand;
      }
    }

    return amount;
  }

  String onCalculate() {
    String firstOperand = _getFirstOperand(amount);
    String operator = _getOperator(amount);
    String lastOperand = _getLastOperand(amount);

    if (firstOperand != "" && operator != "" && lastOperand != "") {
      return _calculate(firstOperand, operator, lastOperand);
    }

    return amount;
  }

  String _getFirstOperand(String amount) {
    List<String> amountParts = amount.split(' ');
    return amountParts.length >= 2 ? amountParts[0] : "";
  }

  String _getOperator(String amount) {
    List<String> amountParts = amount.split(' ');
    return amountParts.length >= 2 ? " ${amountParts[1]} " : "";
  }

  String _getLastOperand(String amoutn) {
    List<String> amountParts = amoutn.split(' ');
    return amountParts.length == 3 ? amountParts[2] : amountParts.length == 1 ? amountParts[0] : "";
  }

  String _addValue(String lastOperand, String input) {
    if (lastOperand == zero && input != dot) {
      return input;
    }

    else {
      return lastOperand + input;
    }
  }

  String _calculate(String firstOperand, String operator, String lastOperand) {
    firstOperand = firstOperand.endsWith(dot) ? firstOperand.substring(0, firstOperand.length - 1) : firstOperand;
    lastOperand = lastOperand.endsWith(dot) ? lastOperand.substring(0, lastOperand.length - 1) : lastOperand;
    String expressionString = firstOperand + operator + lastOperand;
    ExpressionParser parser = GrammarParser();
    Expression expression = parser.parse(expressionString);
    ContextModel contextModel = ContextModel();

    double result = expression.evaluate(EvaluationType.REAL, contextModel);

    if (result * 100 % 100 == 0) {
      return result.toStringAsFixed(0);
    }

    else {
      return result.toStringAsFixed(2);
    }
  }
}