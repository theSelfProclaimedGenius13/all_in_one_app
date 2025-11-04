import 'package:all_in_one_app/features/auth/domain/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:all_in_one_app/features/profile/bloc/profile_bloc.dart';
import 'package:all_in_one_app/features/profile/domain/profile.dart';
import 'package:all_in_one_app/features/profile/domain/repositories/profile_repository.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(profileRepository: context.read<ProfileRepository>())
            ..add(LoadProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView>
    with WidgetsBindingObserver {
  bool _isEditing = false;
  late final TextEditingController _usernameController;
  late final TextEditingController _fullNameController;
  DateTime? _selectedDob;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();

    // Ensure we have the freshest user (e.g., after tapping the verify link)
    _refreshAuthSilently();
  }

  Future<void> _refreshAuthSilently() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (_) {
      // ignore — just a best-effort refresh
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If user returns from email app after verification, pull latest auth again
    if (state == AppLifecycleState.resumed) {
      _refreshAuthSilently();
    }
  }

  void _populateControllers(Profile profile) {
    _usernameController.text = profile.username ?? '';
    _fullNameController.text = profile.fullName ?? '';
    _selectedDob = profile.dob;
    _selectedCountry = profile.country;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final UserEntity? authUser = authState is AuthAuthenticated
        ? authState.user
        : null;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == ProfileStatus.success && _isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.success &&
              _usernameController.text.isEmpty) {
            _populateControllers(state.profile!);
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                if (state.status == ProfileStatus.loading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_isEditing)
                  TextButton(
                    onPressed: () {
                      final updatedProfile = state.profile!.copyWith(
                        username: _usernameController.text,
                        fullName: _fullNameController.text,
                        country: _selectedCountry,
                        dob: _selectedDob,
                      );
                      context.read<ProfileBloc>().add(
                        UpdateProfile(updatedProfile),
                      );
                    },
                    child: const Text('Save'),
                  )
                else
                  TextButton(
                    onPressed: () {
                      _populateControllers(state.profile!);
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: const Text('Edit'),
                  ),
              ],
            ),
            body: _buildBody(context, state, authUser),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileState state,
    UserEntity? authUser,
  ) {
    if (state.status == ProfileStatus.loading && state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.profile == null) {
      return const Center(child: Text('Could not load profile.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            child: const Icon(Icons.person, size: 50),
          ),
        ),
        const SizedBox(height: 24),
        _buildProfileTextField(
          controller: _usernameController,
          label: 'Username',
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildProfileTextField(
          controller: _fullNameController,
          label: 'Full Name',
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildCountryPicker(context),
        const SizedBox(height: 16),
        _buildDobPicker(context),
        const Divider(height: 40),

        // Email row — safe for null, and will update after refreshSession
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('Email'),
          subtitle: Text(authUser?.email ?? '—'),
          trailing: const Icon(Icons.edit, size: 18),
          onTap: authUser == null
              ? null
              : () => _showChangeEmailDialog(context, authUser.email),
        ),
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: const Text('Phone'),
          subtitle: Text(
            authUser?.phone != null ? authUser!.phone! : 'No phone provided',
          ),
          trailing: const Icon(Icons.edit, size: 18),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
    );
  }

  Widget _buildCountryPicker(BuildContext context) {
    final bool hasCountry =
        _selectedCountry != null && _selectedCountry!.isNotEmpty;
    final displayCountry = hasCountry ? _selectedCountry! : 'Country';
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      tileColor: !_isEditing ? Colors.grey[100] : null,
      title: Text(displayCountry),
      trailing: _isEditing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasCountry)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedCountry = null;
                      });
                    },
                  ),
                const Icon(Icons.arrow_drop_down),
              ],
            )
          : null,
      onTap: !_isEditing
          ? null
          : () {
              showCountryPicker(
                context: context,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountry = country.name;
                  });
                },
              );
            },
    );
  }

  Widget _buildDobPicker(BuildContext context) {
    final displayDate = _selectedDob != null
        ? DateFormat.yMMMd().format(_selectedDob!)
        : 'Date of Birth';

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      tileColor: !_isEditing ? Colors.grey[100] : null,
      title: Text(displayDate),
      trailing: _isEditing ? const Icon(Icons.calendar_today) : null,
      onTap: !_isEditing
          ? null
          : () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDob ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDob = pickedDate;
                });
              }
            },
    );
  }

  void _showChangeEmailDialog(BuildContext context, String currentEmail) {
    final emailController = TextEditingController();
    bool isSending = false;

    final ProfileBloc profileBloc = context.read<ProfileBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: profileBloc,
          child: StatefulBuilder(
            builder: (setStateContext, setState) {
              return AlertDialog(
                title: const Text('Change Email'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current email: $currentEmail'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'New Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(isSending ? '' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            if (emailController.text.isNotEmpty) {
                              setState(() {
                                isSending = true;
                              });

                              profileBloc.add(
                                ChangeEmailRequested(emailController.text),
                              );

                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Verification link sent! Please check your new email inbox.',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          },
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Verification Link'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
