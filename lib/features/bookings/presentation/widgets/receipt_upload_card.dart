import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass/glass_container.dart';

class ReceiptFileInfo {
  const ReceiptFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.isImage,
  });

  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final bool isImage;

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class ReceiptUploadCard extends StatefulWidget {
  const ReceiptUploadCard({
    super.key,
    this.initialFile,
    required this.onFileChanged,
    this.enabled = true,
  });

  final ReceiptFileInfo? initialFile;
  final ValueChanged<ReceiptFileInfo?> onFileChanged;
  final bool enabled;

  @override
  State<ReceiptUploadCard> createState() => _ReceiptUploadCardState();
}

class _ReceiptUploadCardState extends State<ReceiptUploadCard> {
  ReceiptFileInfo? _currentFile;
  String? _validationError;

  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  static const int _maxSizeBytes = 10 * 1024 * 1024; // 10 MB

  @override
  void initState() {
    super.initState();
    _currentFile = widget.initialFile;
  }

  @override
  void didUpdateWidget(covariant ReceiptUploadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFile != oldWidget.initialFile) {
      _currentFile = widget.initialFile;
    }
  }

  Future<void> _pickFile() async {
    if (!widget.enabled) return;

    setState(() => _validationError = null);

    try {
      final files = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (files.isEmpty) {
        return;
      }

      final picked = files.first;
      final path = picked.path;

      if (path == null) {
        setState(
          () => _validationError = 'Could not access the selected file.',
        );
        return;
      }

      final ext = (picked.extension ?? path.split('.').last).toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        setState(() {
          _validationError =
              'Unsupported file type ($ext). Please select a PDF, JPG, JPEG, or PNG.';
        });
        return;
      }

      final file = File(path);
      final size = await file.length();
      if (size > _maxSizeBytes) {
        setState(() {
          _validationError =
              'File is too large (${(size / (1024 * 1024)).toStringAsFixed(1)}MB). Max allowed size is 10MB.';
        });
        return;
      }

      final fileName = path.split(RegExp(r'[/\\]')).last;
      final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
      final fileInfo = ReceiptFileInfo(
        filePath: path,
        fileName: fileName,
        fileSizeBytes: size,
        isImage: isImage,
      );

      setState(() {
        _currentFile = fileInfo;
        _validationError = null;
      });

      widget.onFileChanged(fileInfo);
    } catch (e) {
      setState(() {
        _validationError = 'Error picking file: $e';
      });
    }
  }

  void _removeFile() {
    if (!widget.enabled) return;
    setState(() {
      _currentFile = null;
      _validationError = null;
    });
    widget.onFileChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final file = _currentFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (file == null) ...[
          // Empty State Frosted Glass Picker Box
          InkWell(
            onTap: widget.enabled ? _pickFile : null,
            borderRadius: BorderRadius.circular(16),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.md,
              ),
              borderRadius: BorderRadius.circular(16),
              blur: 14,
              backgroundColor: AppColors.glassSurface,
              borderColor: _validationError != null
                  ? AppColors.error
                  : AppColors.glassBorder,
              borderWidth: 1.5,
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Attach Transfer Receipt',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to browse PDF, JPG, JPEG, or PNG (Max 10MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // File Attached Frosted Preview Glass Card
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: BorderRadius.circular(16),
            blur: 16,
            backgroundColor: AppColors.glassSurface,
            borderColor: AppColors.primary.withValues(alpha: 0.4),
            borderWidth: 1.5,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon / Thumbnail
                    if (file.isImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(file.filePath),
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 54,
                                height: 54,
                                color: AppColors.surfaceMuted,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                        ),
                      )
                    else
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFDC2626),
                          size: 30,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.md),
                    // File Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                file.formattedSize,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Text(
                                '•',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successSurface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                  border: Border.all(
                                    color: AppColors.success.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  'Ready to Submit',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 22, color: AppColors.glassBorderSubtle),
                // Action Buttons: Replace & Remove
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: widget.enabled ? _pickFile : null,
                      icon: const Icon(Icons.sync_rounded, size: 16),
                      label: const Text(
                        'Replace File',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: widget.enabled ? _removeFile : null,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text(
                        'Remove',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (_validationError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _validationError!,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
