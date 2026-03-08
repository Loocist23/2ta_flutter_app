import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/job_offer.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onApply,
    this.onTap,
  });

  final JobOffer job;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onApply;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF3FB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                job.company.characters.first,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job.company} • ${job.location}',
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: isFavorite ? AppColors.primary : AppColors.gray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _MetaPill(icon: Icons.work, label: job.contract),
            _MetaPill(icon: Icons.public, label: job.remoteType),
            _MetaPill(icon: Icons.schedule, label: job.postedAt),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          job.description,
          style: const TextStyle(color: AppColors.grayDark, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: job.tags
              .map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  job.salary,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Postuler'),
              onPressed: onApply,
            ),
          ],
        ),
      ],
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: content,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
