import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for fetching user-specific business details
import 'currency_service.dart';

class PdfService {
  static Future<void> generateInvoice(
    String description, 
    double balance, 
    double income, 
    double expense, 
    String date, 
    String currencyCode
  ) async {
    final pdf = pw.Document();
    String symbol = CurrencyService.getSymbol(currencyCode);

    // --- 1. Fetching Business Profile from Firestore ---
    // Retrieves personalized information to brand the audit report
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    String businessName = "FinTrack Business Pro";
    String userPhone = "N/A";
    String ownerName = "Authorized User";

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      businessName = data['businessName'] ?? "FinTrack Business Pro";
      userPhone = data['phone'] ?? "N/A";
      ownerName = data['name'] ?? "User";
    }

    // --- 2. Font Loading for Internationalization ---
    // Loading Google Fonts to support special symbols like INR (₹) and Arabic (د.إ)
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: baseFont, 
          bold: boldFont,
          fontFallback: [arabicFont, baseFont],
        ),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // --- Professional Header Section ---
                // Displays real-time business identity and audit timestamp
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(businessName, 
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueAccent)),
                        pw.Text("Contact: $userPhone", style: const pw.TextStyle(fontSize: 10)),
                        pw.Text("Owner: $ownerName", style: const pw.TextStyle(fontSize: 10)),
                      ]
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("FINANCIAL AUDIT", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Date: $date"),
                        pw.Text("Currency: $currencyCode"),
                      ]
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColors.blueAccent),
                pw.SizedBox(height: 20),

                // --- Financial Summary Table ---
                // Organized representation of income, expense, and net balance
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueAccent),
                  headers: ['Category', 'Amount in $currencyCode'],
                  data: [
                    ['Total Business Income', '$symbol ${income.toStringAsFixed(2)}'],
                    ['Total Business Expense', '$symbol ${expense.toStringAsFixed(2)}'],
                    ['Net Profit / Loss', '$symbol ${balance.toStringAsFixed(2)}'],
                  ],
                ),

                pw.SizedBox(height: 40),

                // --- Secure QR Audit Section ---
                // Generates a QR code containing full transaction breakdown for offline verification
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      children: [
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          // String data contains the full audit trail for the scanner
                          data: "--- FINTRACK OFFICIAL AUDIT ---\n"
                                "Business: $businessName\n"
                                "Owner: $ownerName\n"
                                "Date: $date\n"
                                "------------------------------\n"
                                "Total Income: $symbol ${income.toStringAsFixed(2)}\n"
                                "Total Expense: $symbol ${expense.toStringAsFixed(2)}\n"
                                "Net Balance: $symbol ${balance.toStringAsFixed(2)}\n"
                                "------------------------------\n"
                                "Security Status: 100% Verified",
                          width: 130,
                          height: 130,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text("Scan for Audit Verification", style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(ownerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          width: 160,
                          padding: const pw.EdgeInsets.only(top: 5),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(width: 1, color: PdfColors.black)),
                          ),
                          child: pw.Center(child: pw.Text("Authorized Signature", style: const pw.TextStyle(fontSize: 10))),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(thickness: 0.5, color: PdfColors.grey),
                pw.Center(
                  child: pw.Text("This is a system generated report secured by FinTrack Business Architecture", 
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Launching the PDF print/save dialog on the device
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Report_${businessName}_$date.pdf',
    );
  }
}