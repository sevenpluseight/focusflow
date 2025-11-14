import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { pending, reviewed, dismissed }
enum ReportType { distractionLog }

class ReportModel {
  final String id;
  final String reportedItemId; // The distractionLogId
  final String reportedUserId; // The user who posted the log
  final String coachId; // The coach who reported it
  final Timestamp createdAt;
  final ReportType type;
  final ReportStatus status;

  ReportModel({
    required this.id,
    required this.reportedItemId,
    required this.reportedUserId,
    required this.coachId,
    required this.createdAt,
    required this.type,
    this.status = ReportStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportedItemId': reportedItemId,
      'reportedUserId': reportedUserId,
      'coachId': coachId,
      'createdAt': createdAt,
      'type': type.toString().split('.').last, // 'distractionLog'
      'status': status.toString().split('.').last, // 'pending'
    };
  }
}