import 'package:math_expressions/math_expressions.dart';

class Calculator {
  String amount;

  Calculator(this.amount);

  String onInput(String input) {
    List<String> amountParts = amount.split(' ');
    String firstOperand = amountParts.length >= 2 ? amountParts[0] : "";
    String operator = amountParts.length >= 2 ? " ${amountParts[1]} " : "";
    String lastOperand = amountParts.length == 3 ? amountParts[2] : amountParts.length == 1 ? amountParts[0] : "";

    if (input == ".") {
      if (lastOperand == ""){
        lastOperand = "0$input";
      }

      else if (!lastOperand.contains(".")) {
        lastOperand += input;
      }

      return firstOperand + operator + lastOperand;
    }

    else if (num.tryParse(input) != null) {
      if (!lastOperand.contains(".") && num.tryParse(input) != null) {
        lastOperand = _addValue(lastOperand, input);
      }

      else if (lastOperand.contains(".") && num.tryParse(input) != null && lastOperand.substring(lastOperand.indexOf(".")).length <= 2) {
        lastOperand = _addValue(lastOperand, input);
      }

      return firstOperand + operator + lastOperand;
    }

    else if (["+", "-"].contains(input) && lastOperand != "") {
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

    else if (input == "=") {

      // Exp: 100 + 200
      if (firstOperand != "" && operator != "" && lastOperand != "") {
        return _calculate(firstOperand, operator, lastOperand);
      }
    }

    else if (input == "Del") {

      // Exp: 100 or 100 + 200
      if ((firstOperand == "" && operator == "")
          || (firstOperand != "" && operator != "" && lastOperand != "")
      ) {
        amount = amount.length > 1 ? amount.substring(0, amount.length - 1) : "0";
        return amount;
      }

      // Exp: 100 +
      else if (firstOperand != "" && operator != "" && lastOperand == "") {
        return firstOperand;
      }
    }

    else {
      // Date
    }

    return amount;
  }

  String _addValue(String lastOperand, String input) {
    if (lastOperand == "0" && input != ".") {
      return input;
    }

    else {
      return lastOperand + input;
    }
  }

  String _calculate(String firstOperand, String operator, String lastOperand) {
    firstOperand = firstOperand.endsWith(".") ? firstOperand.substring(0, firstOperand.length - 1) : firstOperand;
    lastOperand = lastOperand.endsWith(".") ? lastOperand.substring(0, lastOperand.length - 1) : lastOperand;
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