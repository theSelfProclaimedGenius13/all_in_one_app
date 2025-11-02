import 'package:all_in_one_app/features/auth/domain/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:all_in_one_app/features/profile/bloc/profile_bloc.dart';
import 'package:all_in_one_app/features/profile/domain/profile.dart';
import 'package:all_in_one_app/features/profile/domain/repositories/profile_repository.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';

/// 1. This widget now provides the new ProfileBloc
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        // Ask for the repository from our provider tree
        profileRepository: context.read<ProfileRepository>(),
      )..add(LoadProfile()), // <-- Immediately load the profile
      child: const _ProfileView(),
    );
  }
}

/// 2. The UI is now a StatefulWidget
class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  // 3. A local variable to track if we are in "edit mode"
  bool _isEditing = false;

  // 4. Controllers for our text fields
  late final TextEditingController _usernameController;
  late final TextEditingController _fullNameController;
  DateTime? _selectedDob;
  String? _selectedCountry;

  // We'll also need a controller for DOB, but that's more complex (DatePicker)

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up controllers
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  /// 5. Helper to populate controllers from the BLoC state
  void _populateControllers(Profile profile) {
    _usernameController.text = profile.username ?? '';
    _fullNameController.text = profile.fullName ?? '';
    _selectedDob = profile.dob;
    _selectedCountry = profile.country;
  }

  @override
  Widget build(BuildContext context) {
    // Get the user's *login info* (Email/Phone) from the AuthBloc
    final authUser =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // 6. Show SnackBars for success/failure on updates
        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == ProfileStatus.success && _isEditing) {
          // If we successfully saved, exit edit mode
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
          // 7. On first successful load, populate controllers
          if (state.status == ProfileStatus.success &&
              _usernameController.text.isEmpty) {
            _populateControllers(state.profile!);
          }

          return Scaffold(
            // --- 8. THE NEW APP BAR ---
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // The "Edit" / "Save" button
              actions: [
                // Show a loading spinner if BLoC is busy
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
                  // --- SAVE BUTTON ---
                  TextButton(
                    onPressed: () {
                      // Send the 'UpdateProfile' event
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
                  // --- EDIT BUTTON ---
                  TextButton(
                    onPressed: () {
                      // Populate controllers and enter edit mode
                      _populateControllers(state.profile!);
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: const Text('Edit'),
                  ),

                // --- LOGOUT MENU BUTTON (three dots) ---
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(LogoutRequested());
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            body: _buildBody(context, state, authUser),
          );
        },
      ),
    );
  }

  // --- 9. THE MAIN BODY UI ---
  Widget _buildBody(
    BuildContext context,
    ProfileState state,
    UserEntity authUser,
  ) {
    if (state.status == ProfileStatus.loading && state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.profile == null) {
      return const Center(child: Text('Could not load profile.'));
    }

    // The main profile content
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- AVATAR ---
        Center(
          child: CircleAvatar(
            radius: 50,
            child: const Icon(Icons.person, size: 50),
          ),
        ),
        const SizedBox(height: 24),

        // --- EDITABLE FIELDS ---
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
        _buildCountryPicker(context), // <-- The new Country Picker
        const SizedBox(height: 16),
        _buildDobPicker(context),

        const Divider(height: 40),

        // --- NON-EDITABLE FIELDS ---
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('Email'),
          // 'email' is non-nullable, so we can use it directly.
          subtitle: Text(authUser.email),
          trailing: const Icon(Icons.edit, size: 18),
          onTap: () {
            _showChangeEmailDialog(context, authUser.email);
          },
        ),
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: const Text('Phone'),
          // 'phone' IS nullable, so we check it explicitly.
          // This makes the analyzer happy and removes the warning.
          subtitle: Text(
            authUser.phone != null ? authUser.phone! : 'No phone provided',
          ),
          trailing: const Icon(Icons.edit, size: 18),
          onTap: () {
            // TODO: Add phone dialog
          },
        ),
      ],
    );
  }

  // --- 10. A HELPER for our TextFields ---
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
        // Show a "filled" look when not editing
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
                // This is your "None" option
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
          ? null // Disable tap if not editing
          : () {
              // This shows the country picker
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

  // --- ADD THIS NEW HELPER FOR DOB ---
  Widget _buildDobPicker(BuildContext context) {
    // Use intl package to format the date
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
          ? null // Disable tap if not editing
          : () async {
              // This shows the date picker
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

    // --- 1. GET THE BLOC *BEFORE* THE DIALOG ---
    // We use the 'context' from the main page, which CAN find the BLoC.
    final ProfileBloc profileBloc = context.read<ProfileBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        // --- 2. WRAP THE DIALOG IN A BlocProvider.value ---
        // This "passes" the BLoC we found into the dialog's widget tree.
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

                              // --- 3. THIS WILL NOW WORK ---
                              // We can safely read the BLoC from
                              // the context or just use our variable.
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
