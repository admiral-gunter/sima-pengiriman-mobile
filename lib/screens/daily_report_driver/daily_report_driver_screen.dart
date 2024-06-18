import 'package:flutter/material.dart';
import '../../components/coustom_bottom_nav_bar.dart';
import '../../enums.dart';
import 'components/body.dart';

class DailyReportDriverScreen extends StatelessWidget {
  const DailyReportDriverScreen({super.key});
  static String routeName = '/daily-report-driver-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Daily Report Driver"),
      ),
      body: Body(),
      bottomNavigationBar:
          CustomBottomNavBar(selectedMenu: MenuState.dailyReport),
    );
  }
}
