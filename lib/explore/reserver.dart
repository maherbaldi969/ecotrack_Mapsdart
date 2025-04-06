import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? selectedDate;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController participantsController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Réservation",
            style: GoogleFonts.merriweather(fontSize: 18 , color: Colors.white,)),
        backgroundColor: Color(0xFF80C000),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Sélectionner une date", style: _sectionTitleStyle()),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF80C000)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Choisir une date"
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    style: TextStyle(color: Color(0xFF80C000), fontSize: 16),
                  ),
                ),
                SizedBox(height: 24),
                Text("Informations personnelles", style: _sectionTitleStyle()),
                _buildTextField("Nom", nameController),
                _buildTextField("Contact", contactController),
                _buildTextField("Nombre de participants", participantsController),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80C000),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text("Suivant", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration().copyWith(labelText: label),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: 'Merriweather',
    );
  }
}


class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = "Carte bancaire"; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paiement",
            style: GoogleFonts.merriweather(fontSize: 18 , color: Colors.white,)),
        backgroundColor: Color(0xFF80C000),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choisir un mode de paiement",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Merriweather'),
              ),
              SizedBox(height: 10),
              _buildRadioButton("Carte bancaire"),
              _buildRadioButton("PayPal"),
              _buildRadioButton("D17 (La Poste Tunisienne)"),
              _buildRadioButton("Virement bancaire"),
              _buildRadioButton("Orange Money"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfirmationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80C000),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text("Payer et confirmer", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String paymentMethod) {
    return ListTile(
      title: Text(paymentMethod),
      leading: Radio<String>(
        value: paymentMethod,
        groupValue: selectedPaymentMethod,
        activeColor: Color(0xFF80C000),
        onChanged: (String? value) {
          setState(() {
            selectedPaymentMethod = value!;
          });
        },
      ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmation",
            style: GoogleFonts.merriweather(fontSize: 18 , color: Colors.white,)),
        backgroundColor: Color(0xFF80C000),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Réservation Confirmée !", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Merriweather')),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Implement download function
                },
                icon: Icon(Icons.download),
                label: Text("Télécharger la carte"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80C000),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
