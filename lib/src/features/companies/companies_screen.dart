import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../data/companies.dart';
import '../../models/company.dart';
import 'company_details_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entreprises partenaires')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CompanyCard(
              company: company,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CompanyDetailsScreen(companyId: company.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onTap});

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF3FB),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      company.name.characters.first,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(company.location,
                          style: const TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                company.description,
                style: const TextStyle(color: AppColors.grayDark, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _Meta(icon: Icons.apartment, text: company.industry),
                  _Meta(
                      icon: Icons.people,
                      text: '${company.employees} collaborateurs'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.work, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${company.openRoles} offre${company.openRoles > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Voir les offres',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.textLight)),
      ],
    );
  }
}
