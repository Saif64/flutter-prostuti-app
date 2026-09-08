import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/common/widgets/long_button.dart';
import 'package:prostuti/core/services/file_helper.dart';
import 'package:prostuti/features/course/materials/assignment/viewmodel/assignment_details_viewmodel.dart';
import 'package:prostuti/features/course/materials/assignment/viewmodel/assignment_file_name.dart';
import 'package:prostuti/features/course/materials/assignment/viewmodel/get_assignment_by_id.dart';
import 'package:prostuti/features/course/materials/assignment/viewmodel/get_file_path.dart';
import 'package:prostuti/features/course/materials/assignment/widgets/assignment_widgets.dart';

import '../../../../../core/services/debouncer.dart';
import '../../../enrolled_course_landing/repository/enrolled_course_landing_repo.dart';
import '../../record_class/viewmodel/change_btn_state.dart';
import '../repository/assignment_repo.dart';
import '../widgets/assignment_skeleton.dart';

class AssignmentDetailsView extends ConsumerStatefulWidget {
  final bool isCompleted;

  const AssignmentDetailsView({super.key, required this.isCompleted});

  @override
  AssignmentDetailsViewState createState() => AssignmentDetailsViewState();
}

class AssignmentDetailsViewState extends ConsumerState<AssignmentDetailsView>
    with CommonWidgets, AssignmentWidgets {
  final fileHelper = FileHelper();
  final _debouncer = Debouncer(milliseconds: 120);
  final _loadingProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final assignmentDetailsAsync =
        ref.watch(assignmentDetailsViewmodelProvider);

    final isLoading = ref.watch(_loadingProvider);

    return Scaffold(
      appBar: commonAppbar("এসাইনমেন্ট"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: assignmentDetailsAsync.when(
            data: (assignment) {
              String filePath = ref.watch(getFilePathProvider);
              String fileName = ref.watch(assignmentFileNameProvider);
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'এসাইনমেন্ট গাইডলাইন',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Gap(24),
                    Text(
                      'এসাইনমেন্ট মার্কস',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Gap(6),
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                          hintText: assignment.data!.marks.toString()),
                    ),
                    const Gap(24),
                    Text(
                      'সাবমিশনের ডিটেইলস',
                      style: theme.textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(6),
                    Text(
                      textAlign: TextAlign.justify,
                      assignment.data!.details ?? "No details",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Gap(24),
                    for (var file in assignment.data!.uploadFileResources!)
                      InkWell(
                          onTap: () async {
                            Fluttertoast.showToast(msg: "Starting download...");
                            String? filePath = await fileHelper.downloadFile(
                                file.path!, file.originalName!);

                            if (filePath != null) {
                              await fileHelper.openFile(filePath);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Failed to download the file.");
                            }
                          },
                          child: fileBox(theme, file.originalName!)),
                    const Gap(24),
                    Text(
                      'সাবমিট করুন',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Gap(24),
                    filePath != "" ||
                            ref.watch(changeBtnStateProvider) ||
                            widget.isCompleted
                        ? Row(
                            children: [
                              // Expanded to make the fileBox take available space
                              Expanded(child: fileBox(theme, fileName)),
                              const Gap(8),
                              // Add some space between the box and the button
                              // This is the cross/delete button
                              IconButton(
                                onPressed: () {
                                  // Clear the file path and name from the providers
                                  ref
                                      .read(getFilePathProvider.notifier)
                                      .setFilePath("");
                                  ref
                                      .read(assignmentFileNameProvider.notifier)
                                      .setFileName("");
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors
                                      .red, // Making the icon red for better UX
                                ),
                              )
                            ],
                          )
                        : InkWell(
                            onTap: () async {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );

                              if (result != null) {
                                File file = File(result.files.single.path!);
                                ref
                                    .read(getFilePathProvider.notifier)
                                    .setFilePath(file.path);

                                ref
                                    .read(assignmentFileNameProvider.notifier)
                                    .setFileName(file.path.split('/').last);
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: submitBox(theme)),
                    const Gap(24),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : LongButton(
                            onPressed: ref.watch(changeBtnStateProvider) ||
                                    widget.isCompleted
                                ? () {}
                                : () {
                                    _debouncer.run(
                                        action: () async {
                                          final filePath =
                                              ref.read(getFilePathProvider);
                                          if (filePath == "") {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "You must submit the file");
                                            return;
                                          }

                                          ref
                                              .read(_loadingProvider.notifier)
                                              .state = true;

                                          // Get assignment details
                                          final assignmentDetails = ref
                                              .read(
                                                  assignmentDetailsViewmodelProvider)
                                              .value;
                                          if (assignmentDetails == null) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Error: Could not get assignment details");
                                            ref
                                                .read(_loadingProvider.notifier)
                                                .state = false;
                                            return;
                                          }

                                          // Get assignment ID and course ID
                                          final assignmentId = ref
                                              .read(getAssignmentByIdProvider);
                                          final courseId = assignmentDetails
                                              .data!
                                              .courseId; // Adjust based on your model structure

                                          // Submit the assignment
                                          final result = await ref
                                              .read(assignmentRepoProvider)
                                              .submitAssignment(
                                                courseId: courseId!,
                                                assignmentId: assignmentId,
                                                filePath: filePath,
                                              );

                                          result.fold((error) {
                                            Fluttertoast.showToast(
                                                msg: "Error: ${error.message}");
                                            ref
                                                .read(_loadingProvider.notifier)
                                                .state = false;
                                          }, (data) async {
                                            // If submission is successful, mark as complete
                                            final markCompleteResponse = await ref
                                                .read(
                                                    enrolledCourseLandingRepoProvider)
                                                .markAsComplete({
                                              "materialType": "assignment",
                                              "material_id": assignmentId
                                            });

                                            if (markCompleteResponse) {
                                              ref
                                                  .read(changeBtnStateProvider
                                                      .notifier)
                                                  .setBtnState();
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Assignment submitted successfully");
                                              Navigator.pop(context, true);
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Failed to mark assignment as complete");
                                            }

                                            ref
                                                .read(_loadingProvider.notifier)
                                                .state = false;
                                          });
                                        },
                                        loadingController: ref
                                            .read(_loadingProvider.notifier));
                                  },
                            text: ref.watch(changeBtnStateProvider) ||
                                    widget.isCompleted
                                ? "এসাইনমেন্ট সাবমিট হয়েছে"
                                : 'সাবমিট করুন')
                  ],
                ),
              );
            },
            error: (error, stackTrace) => Text("$error"),
            loading: () => AssignmentSkeleton(),
          ),
        ),
      ),
    );
  }
}
