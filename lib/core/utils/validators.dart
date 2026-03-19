/// Custom validators for form validation across the app
class Validators {
  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate phone number (Cameroon format: +237XXXXXXXXX)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Cameroon format: +237 followed by 9 digits
    final phoneRegex = RegExp(r'^\+237[26]\d{8}$');

    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid Cameroon phone number (+237XXXXXXXXX)';
    }

    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must not exceed $max characters';
    }

    return null;
  }

  /// Validate number
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    return null;
  }

  /// Validate file size
  static String? fileSize(int bytes, int maxMB) {
    final maxBytes = maxMB * 1024 * 1024;
    if (bytes > maxBytes) {
      return 'File size must be less than ${maxMB}MB';
    }
    return null;
  }

  /// Validate file type
  static String? fileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Only ${allowedExtensions.join(', ')} files are allowed';
    }
    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate date is in the future
  static String? futureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    if (value.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }

    return null;
  }

  /// Validate date is in the past
  static String? pastDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    if (value.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
