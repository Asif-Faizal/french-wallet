import 'package:bloc/bloc.dart';
import '../../../data/account_info/account_repo.dart';
import 'account_event.dart';
import 'account_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository userProfileRepository;

  UserProfileBloc(this.userProfileRepository) : super(UserProfileInitial()) {
    on<UserProfileLoadEvent>((event, emit) async {
      emit(UserProfileLoading());
      try {
        final response = await userProfileRepository.fetchUserProfile();
        if (response.status == 'Success') {
          emit(UserProfileLoaded(userProfile: response.data));
        } else {
          emit(UserProfileError(message: 'Failed to load user profile'));
        }
      } catch (error) {
        emit(UserProfileError(message: error.toString()));
      }
    });
  }
}
