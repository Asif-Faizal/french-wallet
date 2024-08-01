import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/account_info/account_repo.dart';
import '../../../data/account_info/acoount_model.dart';
import '../../bloc/account_info/account_bloc.dart';
import '../../bloc/account_info/account_event.dart';
import '../../bloc/account_info/account_state.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: 'Account'),
      body: BlocProvider(
        create: (context) => UserProfileBloc(UserProfileRepository())
          ..add(UserProfileLoadEvent()),
        child: UserProfileView(),
      ),
    );
  }
}

class UserProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileInitial) {
          return Center(child: Text('Press the button to fetch data'));
        } else if (state is UserProfileLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is UserProfileLoaded) {
          return UserProfileDisplay(userProfile: state.userProfile);
        } else if (state is UserProfileError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Session TimedOut Login again'),
                backgroundColor: Colors.red,
              ),
            );
          });
          return Center(child: Text('Failed to load user profile'));
        }
        return Container();
      },
    );
  }
}

class UserProfileDisplay extends StatelessWidget {
  final UserProfile userProfile;

  UserProfileDisplay({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 30),
          Text(
            '${userProfile.fullName}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text('Mobile No'),
            subtitle: Text('${userProfile.mobileNo}'),
          ),
          ListTile(
            title: Text('Customer ID'),
            subtitle: Text('${userProfile.customerId}'),
          ),
          ListTile(
            title: Text('Status'),
            subtitle: Text('${userProfile.approved}'),
          ),
          ListTile(
            title: Text('Nationality'),
            subtitle: Text('${userProfile.nationality}'),
          ),
        ],
      ),
    );
  }
}
