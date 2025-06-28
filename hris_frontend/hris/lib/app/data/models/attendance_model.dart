class AttendanceDashboard {
  final UserInfo userInfo;
  final CurrentStatus currentStatus;
  final MonthlySummary monthlySummary;

  AttendanceDashboard({
    required this.userInfo,
    required this.currentStatus,
    required this.monthlySummary,
  });

  factory AttendanceDashboard.fromJson(Map<String, dynamic> json) {
    return AttendanceDashboard(
      userInfo: UserInfo.fromJson(json['user_info']),
      currentStatus: CurrentStatus.fromJson(json['current_status']),
      monthlySummary: MonthlySummary.fromJson(json['monthly_summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_info': userInfo.toJson(),
      'current_status': currentStatus.toJson(),
      'monthly_summary': monthlySummary.toJson(),
    };
  }
}

class UserInfo {
  final String name;
  final String location;

  UserInfo({
    required this.name,
    required this.location,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
    };
  }
}

class CurrentStatus {
  final bool isCheckedIn;
  final String checkInTime;
  final String checkOutTime;
  final String workingHours;

  CurrentStatus({
    required this.isCheckedIn,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workingHours,
  });

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    return CurrentStatus(
      isCheckedIn: json['is_checked_in'] ?? false,
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      workingHours: json['working_hours'] ?? '00:00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_checked_in': isCheckedIn,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
    };
  }
}

class MonthlySummary {
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int workingDays;

  MonthlySummary({
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.workingDays,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      presentDays: json['present_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      workingDays: json['working_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'working_days': workingDays,
    };
  }
}

class CheckInOutResponse {
  final String action;
  final String? checkInTime;
  final String? checkOutTime;
  final String? workingHours;
  final bool isCheckedIn;
  final String message;

  CheckInOutResponse({
    required this.action,
    this.checkInTime,
    this.checkOutTime,
    this.workingHours,
    required this.isCheckedIn,
    required this.message,
  });

  factory CheckInOutResponse.fromJson(Map<String, dynamic> json) {
    return CheckInOutResponse(
      action: json['action'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      workingHours: json['working_hours'],
      isCheckedIn: json['is_checked_in'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'is_checked_in': isCheckedIn,
      'message': message,
    };
  }
}
