import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prostuti/common/widgets/common_widgets/common_widgets.dart';
import 'package:prostuti/core/services/file_helper.dart';
import 'package:prostuti/core/services/size_config.dart';
import 'package:prostuti/features/course/materials/resources/viewmodel/get_resource_by_id.dart';
import 'package:prostuti/features/course/materials/resources/viewmodel/resource_details_viewmodel.dart';
import 'package:prostuti/features/course/materials/resources/widgets/resource_skeleton.dart';

import '../../../../../core/services/debouncer.dart';
import '../../../enrolled_course_landing/repository/enrolled_course_landing_repo.dart';
import '../../record_class/viewmodel/change_btn_state.dart';

class ResourceDetailsView extends ConsumerStatefulWidget {
  final bool isCompleted;

  const ResourceDetailsView({
    super.key,
    required this.isCompleted,
  });

  @override
  ResourceDetailsViewState createState() => ResourceDetailsViewState();
}

class ResourceDetailsViewState extends ConsumerState<ResourceDetailsView>
    with CommonWidgets {
  FileHelper fileHelper = FileHelper();
  final _debouncer = Debouncer(milliseconds: 120);
  final _loadingProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    final resourceDetailsAsync = ref.watch(resourceDetailsViewmodelProvider);
    final isLoading = ref.watch(_loadingProvider);

    return Scaffold(
      appBar: commonAppbar("রিসোর্স"),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            height: SizeConfig.h(54),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: ref.watch(changeBtnStateProvider) ||
                            widget.isCompleted
                        ? () {}
                        : () {
                            _debouncer.run(
                                action: () async {
                                  final response = await ref
                                      .read(enrolledCourseLandingRepoProvider)
                                      .markAsComplete({
                                    "materialType": "resource",
                                    "material_id":
                                        ref.read(getResourceByIdProvider)
                                  });

                                  if (response) {
                                    ref
                                        .watch(changeBtnStateProvider.notifier)
                                        .setBtnState();

                                    Navigator.pop(context, true);
                                  }
                                },
                                loadingController:
                                    ref.read(_loadingProvider.notifier));
                          },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        backgroundColor: const Color(0xff2970FF),
                        fixedSize: Size(SizeConfig.w(356), SizeConfig.h(54))),
                    child: Text(
                      ref.watch(changeBtnStateProvider) || widget.isCompleted
                          ? "সম্পন্ন হয়েছে"
                          : 'রিসোর্স সম্পন্ন করুন',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  )),
      ),
      body: resourceDetailsAsync.when(
        data: (resource) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16)),
              child: ListView.builder(
                itemCount: resource.data!.uploadFileResources!.length,
                itemBuilder: (context, index) {
                  final uploadItem = resource.data!.uploadFileResources![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: SizeConfig.h(64),
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: ListTile(
                                onTap: () async {
                                  Fluttertoast.showToast(
                                      msg: "Starting download...");
                                  String? filePath =
                                      await fileHelper.downloadFile(
                                          uploadItem.path!,
                                          uploadItem.originalName!);

                                  if (filePath != null) {
                                    await fileHelper.openFile(filePath);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Failed to download the file.");
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                        color: Colors.grey.shade300)),
                                leading: Stack(
                                  children: [
                                    Image.asset("assets/icons/file_icon.png"),
                                    Positioned(
                                      top: 15,
                                      child: Container(
                                        height: SizeConfig.h(12),
                                        width: SizeConfig.w(28),
                                        decoration: BoxDecoration(
                                            color: const Color(0xffE86E35),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Center(
                                          child: Text(
                                            'PDF',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                title: Text(
                                  uploadItem.originalName!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                trailing:
                                    const Icon(Icons.file_download_outlined),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text("$error")),
        loading: () => const ResourceSkeleton(),
      ),
    );
  }
}
