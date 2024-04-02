import 'package:flutter/material.dart';

class DeliveryForm extends StatefulWidget {
  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate)
      setState(() {
        selectedDate = pickedDate;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime)
      setState(() {
        selectedTime = pickedTime;
      });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 800,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.location_on),
                  hintText: 'Adress..',
                  labelText: 'From',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.location_on),
                  hintText: 'Adress..',
                  labelText: 'To',
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Date & Time Pickup')),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(' ${selectedDate.toString().substring(0, 10)}'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child:
                        Text(' ${selectedTime.toString().substring(10, 15)}'),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 100,
                child: TextFormField(
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Enter package details',
                    labelText: 'Package Details',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Penerima',
                  labelText: 'nama penerima',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'No. Telp',
                  labelText: 'nomor telepon',
                ),
              ),
            ]),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Submit',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    )))
          ],
        ),
      ),
    );
  }
}
