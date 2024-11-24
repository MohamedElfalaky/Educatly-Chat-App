import 'package:chat_test/utils/globals.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email can not be empty';
    }
    // Regular expression for validating email
    final emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\\.,;:\s@\"]+\.)+[^<>()[\]\\.,;:\s@\"]{2,})$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    // Check for lowercase letters
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    // Check for digits
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character (e.g., !@#\$%^&*).';
    }
    return null;
  }

  static String? validateReEnterPasswordField(
      String? value, String firstPassword) {
    if (value != firstPassword || value!.isEmpty) {
      return "passwords_not_matching";
    }

    return null;
  }

  static String? validateNotEmptyField(value, String errorMsg) {
    if (value == null || value.isEmpty) {
      return errorMsg;
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "user name can not be field empty";
    } else if (value.length < 3) {
      return "user name must be more that 3 characters";
    }

    return null;
  }

  static String? validateMedicationDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'duration_empty';
    }
    try {
      num? duration = num.tryParse(value);
      if (duration != null) {
        if (duration > 365 || duration < 1) {
          return 'duration_range';
        }
      } else {
        return 'duration_number';
      }
    } catch (e) {
      return 'duration_number';
    }

    return null;
  }

  static String? validateMedicationFrequancy(String? value) {
    if (value == null || value.isEmpty) {
      return 'frequency_empty';
    }
    try {
      num? duration = num.tryParse(value);
      if (duration != null) {
        if (duration > 10 || duration < 1) {
          return 'frequency_range';
        }
      } else {
        return 'frequency_number';
      }
    } catch (e) {
      return 'frequency_number';
    }

    return null;
  }
}
