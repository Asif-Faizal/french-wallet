import 'package:ewallet2/presentation/screens/services/merchant/add_store_screen.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/store/store_model.dart';
import '../../../widgets/merchant/store_card.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Future<List<Store>>? stores;
  late SharedPreferences prefs;
  String? jwtToken;
  String? refreshToken;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    jwtToken = prefs.getString('jwt_token');
    refreshToken = prefs.getString('refresh_token');
    if (jwtToken != null) {
      setState(() {
        stores = fetchStores();
      });
    }
  }

  Future<void> _refreshToken() async {
    final response = await http.post(
      Uri.parse('https://api-innovitegra.online/login/refresh_token'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var newToken = jsonData['jwt_token'];
      await prefs.setString('jwt_token', newToken);
      jwtToken = newToken;
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  Future<List<Store>> fetchStores() async {
    if (jwtToken == null) {
      throw Exception('No JWT token found');
    }

    final response = await http.post(
      Uri.parse('https://api-innovitegra.online/merchant/store/List'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'Fail') {
        await _refreshToken();
        return fetchStores();
      } else {
        var storesJson = jsonData['store_array'] as List;
        List<Store> storeList =
            storesJson.map((store) => Store.fromJson(store)).toList();
        return storeList;
      }
    } else {
      throw Exception('Failed to load stores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: 'Stores'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<Store>>(
          future: stores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No stores available'));
            } else {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Store store = snapshot.data![index];
                  return StoreCard(store: store);
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        child: NormalButton(
            size: MediaQuery.of(context).size,
            title: 'Add Store',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddStoreScreen()));
            }),
      ),
    );
  }
}
