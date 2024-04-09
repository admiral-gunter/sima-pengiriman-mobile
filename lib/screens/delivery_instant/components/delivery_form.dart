import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sima_pengiriman/screens/map_picker/map_picker.dart';

import '../../looking_for_courier/looking_for_courier.dart';

class DeliveryForm extends StatefulWidget {
  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final _formKey = GlobalKey<FormState>();

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
      height:
          WidgetsBinding.instance.window.viewInsets.bottom > 0.0 ? 500 : 800,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, MapPicker.routeName);
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          children: [
                            Text('Lokasi Jemput',
                                style: TextStyle(fontSize: 10)),
                            Text('Adress...'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, MapPicker.routeName);
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          children: [
                            Text('Lokasi Tujuan',
                                style: TextStyle(fontSize: 10)),
                            Text('Adress...'),
                          ],
                        )
                      ],
                    ),
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
                    FilledButton(
                      onPressed: () => _selectDate(context),
                      child:
                          Text(' ${selectedDate.toString().substring(0, 10)}'),
                    ),
                    SizedBox(width: 10),
                    FilledButton(
                      onPressed: () => _selectTime(context),
                      child:
                          Text(' ${selectedTime.toString().substring(10, 15)}'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Input package weight',
                    labelText: 'Weight (kg)',
                  ),
                ),
                SizedBox(
                  height: 20,
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
                  scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 5 * 4),
                  decoration: InputDecoration(
                    hintText: 'No. Telp',
                    labelText: 'nomor telepon',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.camera),
                      label: Text('Foto Package (optional)')),
                )
              ]),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                child: Row(
                  children: [
                    Text('Total Bil :'),
                    SizedBox(width: 5),
                    Text('20.000,00')
                  ],
                ),
              ),
              SizedBox(height: 70),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, LookingForCourier.routeName);
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
