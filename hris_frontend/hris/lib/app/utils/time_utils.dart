import 'package:intl/intl.dart';

class TimeUtils {
  // Format DateTime ke string dengan format yang diinginkan
  static String formatTime12Hour(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatTime24Hour(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // Parse string waktu dari backend ke DateTime
  static DateTime? parseTimeString(String timeString) {
    if (timeString.isEmpty) return null;
    
    try {
      // Jika format sudah lengkap dengan tanggal
      if (timeString.contains('-') || timeString.contains('/')) {
        return DateTime.parse(timeString);
      }
      
      // Jika hanya waktu (contoh: "03:30 PM" atau "15:30")
      final now = DateTime.now();
      
      if (timeString.contains('AM') || timeString.contains('PM')) {
        // Format 12 jam dengan AM/PM
        final format = DateFormat('hh:mm a');
        final parsedTime = format.parse(timeString);
        return DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } else {
        // Format 24 jam
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final second = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
          
          return DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
            second,
          );
        }
      }
    } catch (e) {
      print('Error parsing time string: $timeString, error: $e');
    }
    
    return null;
  }

  // Konversi durasi ke format jam:menit:detik
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  // Parse string durasi (contoh: "08:30:45") ke Duration
  static Duration? parseDuration(String durationString) {
    if (durationString.isEmpty) return null;
    
    try {
      final parts = durationString.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
        
        return Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
        );
      }
    } catch (e) {
      print('Error parsing duration string: $durationString, error: $e');
    }
    
    return null;
  }

  // Mendapatkan waktu saat ini dalam format yang konsisten
  static String getCurrentTime12Hour() {
    return formatTime12Hour(DateTime.now());
  }

  static String getCurrentTime24Hour() {
    return formatTime24Hour(DateTime.now());
  }

  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }

  // Cek apakah waktu sudah lewat dari jam tertentu
  static bool isTimeAfter(String timeString, int hour, int minute) {
    final parsedTime = parseTimeString(timeString);
    if (parsedTime == null) return false;
    
    final targetTime = DateTime(
      parsedTime.year,
      parsedTime.month,
      parsedTime.day,
      hour,
      minute,
    );
    
    return parsedTime.isAfter(targetTime);
  }

  // Cek apakah terlambat (misal setelah jam 9:00)
  static bool isLate(String checkInTime) {
    return isTimeAfter(checkInTime, 9, 0); // Terlambat jika setelah jam 9:00
  }

  // Hitung waktu kerja antara check-in dan check-out
  static Duration calculateWorkingHours(String checkInTime, String checkOutTime) {
    final checkIn = parseTimeString(checkInTime);
    final checkOut = parseTimeString(checkOutTime);
    
    if (checkIn == null || checkOut == null) {
      return Duration.zero;
    }
    
    return checkOut.difference(checkIn);
  }

  // Format nama bulan dalam bahasa Indonesia
  static String getMonthNameIndonesian(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    if (month >= 1 && month <= 12) {
      return months[month];
    }
    return '';
  }

  // Format tanggal dalam bahasa Indonesia
  static String formatDateIndonesian(DateTime dateTime) {
    return '${dateTime.day} ${getMonthNameIndonesian(dateTime.month)} ${dateTime.year}';
  }
}

// Extension untuk DateTime
extension DateTimeExtension on DateTime {
  String toTime12Hour() => TimeUtils.formatTime12Hour(this);
  String toTime24Hour() => TimeUtils.formatTime24Hour(this);
  String toDateString() => TimeUtils.formatDate(this);
  String toDateTimeString() => TimeUtils.formatDateTime(this);
  String toDateIndonesian() => TimeUtils.formatDateIndonesian(this);
}
