import 'package:flutter/material.dart';

class ServiceListBottomSheet extends StatelessWidget {
  const ServiceListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(20),
      height: size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'All Services',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Mobile Recharge'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.electrical_services_outlined),
                  title: Text('Electricity Bill'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.tv),
                  title: Text('DTH Recharge'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.water),
                  title: Text('Water Bill'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.satellite_alt),
                  title: Text('Broadband Bill'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.car_crash),
                  title: Text('Vehicle Insurance'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.healing),
                  title: Text('Health Insurance'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
