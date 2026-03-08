import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../data/job_offers.dart';
import '../../models/job_offer.dart';
import '../../models/user.dart';
import '../../state/auth_controller.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/job_card.dart';
import '../jobs/job_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.alertId});

  final String? alertId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum _SortOption { recent, salaryDesc, company }

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _locationController = TextEditingController();
  final Set<String> _contractFilters = {};
  String _remoteFilter = 'Tous';
  String _salaryFilter = 'Tous';
  _SortOption _sort = _SortOption.recent;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    UserAlert? alert;
    if (widget.alertId != null) {
      for (final item in auth.user?.alerts ?? []) {
        if (item.id == widget.alertId) {
          alert = item;
          break;
        }
      }
    }
    if (alert != null) {
      _queryController.text = alert.title;
      _keywordsController.text = alert.keywords.join(', ');
      _locationController.text = alert.location;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _keywordsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  List<String> get _keywordList => _keywordsController.text
      .split(',')
      .map((keyword) => keyword.trim())
      .where((keyword) => keyword.isNotEmpty)
      .toList();

  Iterable<JobOffer> get _filteredJobs {
    final keywords = _keywordList;
    final location = _locationController.text.toLowerCase();
    final query = _queryController.text.toLowerCase();
    final minSalary = _salaryFilter == 'Tous'
        ? 0
        : int.tryParse(_salaryFilter.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final jobs = jobOffers.where((job) {
      final locationMatch =
          location.isEmpty || job.location.toLowerCase().contains(location);
      final queryMatch = query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query);
      final keywordMatch = keywords.isEmpty ||
          keywords.every((keyword) {
            final normalized = keyword.toLowerCase();
            return job.tags.any((tag) => tag.toLowerCase().contains(normalized)) ||
                job.description.toLowerCase().contains(normalized) ||
                job.title.toLowerCase().contains(normalized);
          });
      final contractMatch = _contractFilters.isEmpty ||
          _contractFilters.contains(job.contract);
      final remoteMatch =
          _remoteFilter == 'Tous' || job.remoteType == _remoteFilter;
      final salaryValue = _extractMinSalary(job.salary);
      final salaryMatch = salaryValue >= minSalary;

      return locationMatch &&
          queryMatch &&
          keywordMatch &&
          contractMatch &&
          remoteMatch &&
          salaryMatch;
    }).toList();

    jobs.sort((a, b) {
      switch (_sort) {
        case _SortOption.salaryDesc:
          return _extractMinSalary(b.salary) - _extractMinSalary(a.salary);
        case _SortOption.company:
          return a.company.compareTo(b.company);
        case _SortOption.recent:
          return 0;
      }
    });

    return jobs;
  }

  int _extractMinSalary(String salary) {
    final match = RegExp(r'(\d+[\s\u00A0]?\d*)').firstMatch(salary);
    if (match == null) {
      return 0;
    }
    return int.parse(match.group(1)!.replaceAll(RegExp(r'[\s\u00A0]'), ''));
  }

  void _saveSearch() {
    final auth = context.read<AuthController>();
    final title = _queryController.text.trim().isEmpty
        ? (_keywordList.isEmpty ? 'Nouvelle alerte' : _keywordList.join(', '))
        : _queryController.text.trim();
    final keywords = _keywordList.isEmpty
        ? title.split(' ').where((element) => element.isNotEmpty).toList()
        : _keywordList;
    final location = _locationController.text.trim().isEmpty
        ? 'Télétravail'
        : _locationController.text.trim();

    if (widget.alertId != null) {
      auth.updateAlert(
        widget.alertId!,
        title: title,
        keywords: keywords,
        location: location,
      );
      AppSnackbar.show('Alerte mise à jour avec vos filtres.', success: true);
    } else {
      final id = auth.createAlert(
        title: title,
        keywords: keywords,
        location: location,
        frequency: AlertFrequency.daily,
      );
      AppSnackbar.show('Alerte créée. Nous vous préviendrons dès qu’une offre correspond.', success: true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SearchScreen(alertId: id)),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche d’offres')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _LabeledField(
                  label: 'Poste recherché',
                  controller: _queryController,
                  hintText: 'Titre du poste, mots-clés...',
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Mots-clés',
                  controller: _keywordsController,
                  hintText: 'UX, Produit, ...',
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Localisation',
                  controller: _locationController,
                  hintText: 'Ville, région...',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _keywordList
                      .map((keyword) => Chip(label: Text(keyword)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _FilterSection(
                  title: 'Type de contrat',
                  options: const ['CDI', 'CDD', 'Freelance', 'Stage'],
                  isActive: (value) => _contractFilters.contains(value),
                  onSelected: (value) {
                    setState(() {
                      if (_contractFilters.contains(value)) {
                        _contractFilters.remove(value);
                      } else {
                        _contractFilters.add(value);
                      }
                    });
                  },
                ),
                _FilterSection(
                  title: 'Mode de travail',
                  options: const ['Tous', 'Télétravail', 'Hybride', 'Présentiel'],
                  singleSelection: true,
                  isActive: (value) => _remoteFilter == value,
                  onSelected: (value) => setState(() => _remoteFilter = value),
                ),
                _FilterSection(
                  title: 'Rémunération',
                  options: const ['Tous', '≥ 50 k€', '≥ 60 k€', '≥ 70 k€'],
                  singleSelection: true,
                  isActive: (value) => _salaryFilter == value,
                  onSelected: (value) => setState(() => _salaryFilter = value),
                ),
                _FilterSection(
                  title: 'Trier par',
                  options: const ['Plus récentes', 'Salaire décroissant', 'A → Z entreprise'],
                  singleSelection: true,
                  isActive: (value) {
                    switch (value) {
                      case 'Plus récentes':
                        return _sort == _SortOption.recent;
                      case 'Salaire décroissant':
                        return _sort == _SortOption.salaryDesc;
                      default:
                        return _sort == _SortOption.company;
                    }
                  },
                  onSelected: (value) {
                    setState(() {
                      switch (value) {
                        case 'Plus récentes':
                          _sort = _SortOption.recent;
                          break;
                        case 'Salaire décroissant':
                          _sort = _SortOption.salaryDesc;
                          break;
                        default:
                          _sort = _SortOption.company;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredJobs.length} offre${_filteredJobs.length > 1 ? 's' : ''} trouvée${_filteredJobs.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _saveSearch,
                      icon: const Icon(Icons.bookmark),
                      label: Text(widget.alertId != null
                          ? 'Mettre à jour mon alerte'
                          : 'Sauvegarder en alerte'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._filteredJobs.map((job) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: JobCard(
                        job: job,
                        isFavorite: user.favorites.contains(job.id),
                        onToggleFavorite: () =>
                            context.read<AuthController>().toggleFavorite(job.id),
                        onApply: () => AppSnackbar.show(
                            'Votre candidature pour "${job.title}" a bien été envoyée.'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => JobDetailsScreen(jobId: job.id),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.isActive,
    required this.onSelected,
    this.singleSelection = false,
  });

  final String title;
  final List<String> options;
  final bool Function(String value) isActive;
  final void Function(String value) onSelected;
  final bool singleSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final active = isActive(option);
            return ChoiceChip(
              label: Text(option),
              selected: active,
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}
