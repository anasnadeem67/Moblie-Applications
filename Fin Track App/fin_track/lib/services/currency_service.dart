import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for debugPrint $cite: 10.1$
import 'package:http/http.dart' as http; // Package for making REST API calls $cite: 7.1$

class CurrencyService {
  
  // --- 1. Fetch Live Exchange Rates from External API ---
  // Retrieves real-time rates with PKR as the base currency $cite: 7.1$
  static Future<double> getLiveRate(String targetCurrency) async {
    // If the selected currency is PKR, no conversion is necessary
    if (targetCurrency == "PKR") return 1.0;

    try {
      // Fetching the latest forex market data from ExchangeRate-API $cite: 7.1$
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/PKR')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extracting the conversion rate for the requested target currency (USD, INR, AED)
        if (data['rates'] != null && data['rates'][targetCurrency] != null) {
          return (data['rates'][targetCurrency] as num).toDouble();
        }
      }
      
      // Fallback to hardcoded rates if the API response is unsuccessful
      return _getFallbackRate(targetCurrency);
    } catch (e) {
      // Using debugPrint instead of print for better production logging $cite: 10.1$
      debugPrint("Currency API Error: $e");
      return _getFallbackRate(targetCurrency);
    }
  }

  // --- 2. Currency Symbol Logic ---
  // Maps ISO currency codes to their respective visual symbols $cite: 5.1, 7.1$
  static String getSymbol(String code) {
    switch (code) {
      case "USD":
        return "\$"; // United States Dollar
      case "INR":
        return "₹"; // Indian Rupee
      case "AED":
        return "د.إ"; // United Arab Emirates Dirham
      case "PKR":
      default:
        return "Rs"; // Pakistani Rupee
    }
  }

  // --- 3. Offline Fallback Strategy ---
  // Provides estimated rates in case of network unavailability $cite: 7.1$
  static double _getFallbackRate(String code) {
    Map<String, double> rates = {
      "USD": 0.0036, // Approximate conversion: 1 PKR to USD
      "INR": 0.30,   // Approximate conversion: 1 PKR to INR
      "AED": 0.013,  // Approximate conversion: 1 PKR to AED
    };
    return rates[code] ?? 1.0;
  }
}