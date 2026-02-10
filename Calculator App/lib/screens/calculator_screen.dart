import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = "0";
  double? firstNum;
  double? secondNum;
  String? operator;
  bool isResultShown = false;

  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        displayText = "0";
        firstNum = null;
        secondNum = null;
        operator = null;
        isResultShown = false;
      } else if (value == "⌫") {
        if (displayText.length > 1) {
          displayText = displayText.substring(0, displayText.length - 1);
        } else {
          displayText = "0";
        }
      } else if (value == "+" || value == "-" || value == "×" || value == "÷") {
        if (operator != null && !isResultShown) {
          secondNum = double.tryParse(displayText);
          _calculate();
        } else {
          firstNum = double.tryParse(displayText);
        }
        operator = value;
        isResultShown = true;
      } else if (value == "=") {
        if (operator != null) {
          secondNum = double.tryParse(displayText);
          _calculate();
          operator = null;
        }
      } else if (value == "%") {
        double? current = double.tryParse(displayText);
        if (current != null) {
          displayText = (current / 100).toString();
          firstNum = double.tryParse(displayText);
          isResultShown = true;
        }
      } else if (value == ".") {
        if (!displayText.contains(".")) {
          displayText += ".";
          isResultShown = false;
        }
      } else {
        if (displayText == "0" || isResultShown) {
          displayText = value;
          isResultShown = false;
        } else {
          displayText += value;
        }
      }
    });
  }

  void _calculate() {
    if (firstNum == null || operator == null) return;
    secondNum ??= firstNum;

    double result = 0;
    switch (operator) {
      case "+":
        result = firstNum! + secondNum!;
        break;
      case "-":
        result = firstNum! - secondNum!;
        break;
      case "×":
        result = firstNum! * secondNum!;
        break;
      case "÷":
        result = secondNum == 0 ? double.nan : firstNum! / secondNum!;
        break;
    }

    displayText =
        result.isNaN ? "Error" : result.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
    firstNum = result;
    secondNum = null;
    isResultShown = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Buttons
              _buildButtonGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    List<List<String>> buttons = [
      ["C", "⌫", "%", "÷"],
      ["7", "8", "9", "×"],
      ["4", "5", "6", "-"],
      ["1", "2", "3", "+"],
      ["0", ".", "="],
    ];

    return Column(
      children: buttons.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((label) {
              Color bgColor;
              if ("÷×-+=%".contains(label)) {
                bgColor = Colors.orangeAccent;
              } else if (label == "C" || label == "⌫") {
                bgColor = Colors.lightBlueAccent;
              } else {
                bgColor = Colors.white.withOpacity(0.2);
              }

              double width = label == "0" ? 160 : 70;
              return GestureDetector(
                onTap: () => buttonPressed(label),
                child: Container(
                  width: width,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
