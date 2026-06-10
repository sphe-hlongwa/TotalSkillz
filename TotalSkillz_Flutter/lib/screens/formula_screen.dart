import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Data model for a formula entry
class FormulaEntry {
  final String id;
  final String category;
  final String title;
  final String latex;

  const FormulaEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.latex,
  });
}

/// All Grade 12 formulas — ported from formula.html & NSC Information Sheet
const _formulas = [
  // ── Algebra, Sequences & Series ─────────────────────────────────────
  FormulaEntry(id: 'quad', category: 'Algebra', title: 'Quadratic Formula',
      latex: r'x = \dfrac{-b \pm \sqrt{b^2 - 4ac}}{2a}'),
  FormulaEntry(id: 'sigma1', category: 'Sequences', title: 'Constant Sequence Sum',
      latex: r'\sum_{i=1}^{n} 1 = n'),
  FormulaEntry(id: 'sigma_n', category: 'Sequences', title: 'Sum of First n Integers',
      latex: r'\sum_{i=1}^{n} i = \dfrac{n(n+1)}{2}'),
  FormulaEntry(id: 'arith_n', category: 'Sequences', title: 'Arithmetic Sequence (nth term)',
      latex: r'T_n = a + (n-1)d'),
  FormulaEntry(id: 'arith_s', category: 'Sequences', title: 'Arithmetic Series Sum',
      latex: r'S_n = \dfrac{n}{2}[2a + (n-1)d] = \sum_{i=1}^{n} T_i'),
  FormulaEntry(id: 'geom_n', category: 'Sequences', title: 'Geometric Sequence (nth term)',
      latex: r'T_n = ar^{n-1}'),
  FormulaEntry(id: 'geom_s', category: 'Sequences', title: 'Geometric Series Sum',
      latex: r'S_n = \dfrac{a(r^n - 1)}{r - 1} = \sum_{i=1}^{n} T_i, \quad r \neq 1'),
  FormulaEntry(id: 'geom_inf', category: 'Sequences', title: 'Sum to Infinity',
      latex: r'S_\infty = \dfrac{a}{1-r}, \quad |r| < 1'),

  // ── Functions & Logs ───────────────────────────────────────────────
  FormulaEntry(id: 'disc', category: 'Functions', title: 'Discriminant',
      latex: r'\Delta = b^2 - 4ac'),
  FormulaEntry(id: 'log_base', category: 'Functions', title: 'Logarithm Change of Base',
      latex: r'\log_a b = \dfrac{\log b}{\log a}'),
  FormulaEntry(id: 'log_prod', category: 'Functions', title: 'Log Laws (Product)',
      latex: r'\log_a(xy) = \log_a x + \log_a y'),
  FormulaEntry(id: 'log_quot', category: 'Functions', title: 'Log Laws (Quotient)',
      latex: r'\log_a\left(\dfrac{x}{y}\right) = \log_a x - \log_a y'),
  FormulaEntry(id: 'log_pow', category: 'Functions', title: 'Log Laws (Power)',
      latex: r'\log_a(x^n) = n \log_a x'),

  // ── Finance, Growth & Decay ────────────────────────────────────────
  FormulaEntry(id: 'simp_int', category: 'Finance', title: 'Simple Interest',
      latex: r'A = P(1 + in)'),
  FormulaEntry(id: 'comp_int', category: 'Finance', title: 'Compound Interest',
      latex: r'A = P(1 + i)^n'),
  FormulaEntry(id: 'simp_dec', category: 'Finance', title: 'Simple Depreciation',
      latex: r'A = P(1 - in)'),
  FormulaEntry(id: 'comp_dec', category: 'Finance', title: 'Compound Depreciation',
      latex: r'A = P(1 - i)^n'),
  FormulaEntry(id: 'fut_ann', category: 'Finance', title: 'Future Value (Annuity)',
      latex: r'F = x \left[\dfrac{(1+i)^n - 1}{i}\right]'),
  FormulaEntry(id: 'pres_ann', category: 'Finance', title: 'Present Value (Annuity)',
      latex: r'P = x \left[\dfrac{1 - (1+i)^{-n}}{i}\right]'),

  // ── Calculus ─────────────────────────────────────────────────────────
  FormulaEntry(id: 'calc_prin', category: 'Calculus', title: 'First Principles',
      latex: r"f'(x) = \lim_{h \to 0} \dfrac{f(x+h) - f(x)}{h}"),
  FormulaEntry(id: 'calc_pow', category: 'Calculus', title: 'Power Rule',
      latex: r'\dfrac{d}{dx}[x^n] = nx^{n-1}'),

  // ── Analytical Geometry ──────────────────────────────────────────────
  FormulaEntry(id: 'geo_dist', category: 'Analytical', title: 'Distance Formula',
      latex: r'd = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}'),
  FormulaEntry(id: 'geo_mid', category: 'Analytical', title: 'Midpoint',
      latex: r'M \left(\dfrac{x_1 + x_2}{2} ; \dfrac{y_1 + y_2}{2}\right)'),
  FormulaEntry(id: 'geo_grad', category: 'Analytical', title: 'Gradient',
      latex: r'm = \dfrac{y_2 - y_1}{x_2 - x_1}'),
  FormulaEntry(id: 'geo_incl', category: 'Analytical', title: 'Angle of Inclination',
      latex: r'm = \tan \theta'),
  FormulaEntry(id: 'geo_line1', category: 'Analytical', title: 'Straight Line (m, c)',
      latex: r'y = mx + c'),
  FormulaEntry(id: 'geo_line2', category: 'Analytical', title: 'Straight Line (pt-grad)',
      latex: r'y - y_1 = m(x - x_1)'),
  FormulaEntry(id: 'geo_circ', category: 'Analytical', title: 'Circle Equation',
      latex: r'(x - a)^2 + (y - b)^2 = r^2'),

  // ── Trigonometry ─────────────────────────────────────────────────────
  FormulaEntry(id: 'trig_sin_rule', category: 'Trigonometry', title: 'Sine Rule',
      latex: r'\dfrac{a}{\sin A} = \dfrac{b}{\sin B} = \dfrac{c}{\sin C}'),
  FormulaEntry(id: 'trig_cos_rule', category: 'Trigonometry', title: 'Cosine Rule',
      latex: r'a^2 = b^2 + c^2 - 2bc \cos A'),
  FormulaEntry(id: 'trig_area', category: 'Trigonometry', title: 'Area Rule',
      latex: r'\text{Area} = \tfrac{1}{2}ab \sin C'),
  FormulaEntry(id: 'trig_comp_sin_plus', category: 'Trigonometry', title: 'Compound Angle (sin+)',
      latex: r'\sin(\alpha + \beta) = \sin \alpha \cos \beta + \cos \alpha \sin \beta'),
  FormulaEntry(id: 'trig_comp_sin_minus', category: 'Trigonometry', title: 'Compound Angle (sin-)',
      latex: r'\sin(\alpha - \beta) = \sin \alpha \cos \beta - \cos \alpha \sin \beta'),
  FormulaEntry(id: 'trig_comp_cos_plus', category: 'Trigonometry', title: 'Compound Angle (cos+)',
      latex: r'\cos(\alpha + \beta) = \cos \alpha \cos \beta - \sin \alpha \sin \beta'),
  FormulaEntry(id: 'trig_comp_cos_minus', category: 'Trigonometry', title: 'Compound Angle (cos-)',
      latex: r'\cos(\alpha - \beta) = \cos \alpha \cos \beta + \sin \alpha \sin \beta'),
  FormulaEntry(id: 'trig_double_sin', category: 'Trigonometry', title: 'Double Angle (sin)',
      latex: r'\sin 2\alpha = 2 \sin \alpha \cos \alpha'),
  FormulaEntry(id: 'trig_double_cos1', category: 'Trigonometry', title: 'Double Angle (cos: v1)',
      latex: r'\cos 2\alpha = \cos^2 \alpha - \sin^2 \alpha'),
  FormulaEntry(id: 'trig_double_cos2', category: 'Trigonometry', title: 'Double Angle (cos: v2)',
      latex: r'\cos 2\alpha = 1 - 2\sin^2 \alpha'),
  FormulaEntry(id: 'trig_double_cos3', category: 'Trigonometry', title: 'Double Angle (cos: v3)',
      latex: r'\cos 2\alpha = 2\cos^2 \alpha - 1'),

  // ── Euclidean Geometry ───────────────────────────────────────────────
  FormulaEntry(id: 'euc_angles_tri', category: 'Euclidean', title: 'Angles in a Triangle',
      latex: r'\hat{A} + \hat{B} + \hat{C} = 180^\circ'),
  FormulaEntry(id: 'euc_ext_angle', category: 'Euclidean', title: 'Exterior Angle of Triangle',
      latex: r'\text{Ext } \hat{A} = \hat{B} + \hat{C}'),
  FormulaEntry(id: 'euc_center_circ', category: 'Euclidean', title: 'Angle at Center',
      latex: r'\text{Angle at center} = 2 \times \text{Angle at circle}'),
  FormulaEntry(id: 'euc_semi_circ', category: 'Euclidean', title: 'Angle in Semi-circle',
      latex: r'\text{Angle in semi-circle} = 90^\circ'),
  FormulaEntry(id: 'euc_cyclic_quad', category: 'Euclidean', title: 'Cyclic Quad (Opp Angles)',
      latex: r'\hat{A} + \hat{C} = 180^\circ'),
  FormulaEntry(id: 'euc_tan_chord', category: 'Euclidean', title: 'Tan-chord Theorem',
      latex: r'\text{Angle btwn tan \& chord} = \text{Angle in opp segment}'),
  FormulaEntry(id: 'euc_prop_tri', category: 'Euclidean', title: 'Proportionality Theorem',
      latex: r'\text{Line } \parallel \text{ to side divides other sides proportionally}'),
  FormulaEntry(id: 'euc_sim_tri', category: 'Euclidean', title: 'Similarity Theorem',
      latex: r'\Delta ABC \sim \Delta DEF \implies \dfrac{AB}{DE} = \dfrac{BC}{EF} = \dfrac{AC}{DF}'),

  // ── Statistics & Probability ───────────────────────────────────────
  FormulaEntry(id: 'stat_mean', category: 'Statistics', title: 'Mean',
      latex: r'\bar{x} = \dfrac{\sum x}{n}'),
  FormulaEntry(id: 'stat_var', category: 'Statistics', title: 'Variance',
      latex: r'\sigma^2 = \dfrac{\sum(x - \bar{x})^2}{n}'),
  FormulaEntry(id: 'stat_sd', category: 'Statistics', title: 'Standard Deviation',
      latex: r'\sigma = \sqrt{\dfrac{\sum(x - \bar{x})^2}{n}}'),
  FormulaEntry(id: 'stat_reg_b', category: 'Statistics', title: 'Regression Slope (b)',
      latex: r'b = \dfrac{\sum(x - \bar{x})(y - \bar{y})}{\sum(x - \bar{x})^2}'),
  FormulaEntry(id: 'stat_reg', category: 'Statistics', title: 'Least Squares Regression',
      latex: r'\hat{y} = a + bx'),
  FormulaEntry(id: 'prob_basic', category: 'Probability', title: 'Basic Probability',
      latex: r'P(A) = \dfrac{n(A)}{n(S)}'),
  FormulaEntry(id: 'prob_add', category: 'Probability', title: 'Addition Rule',
      latex: r'P(A \cup B) = P(A) + P(B) - P(A \cap B)'),
  FormulaEntry(id: 'prob_indep', category: 'Probability', title: 'Independent Events',
      latex: r'P(A \cap B) = P(A) \times P(B)'),
  FormulaEntry(id: 'prob_mut_excl', category: 'Probability', title: 'Mutually Exclusive',
      latex: r'P(A \cap B) = 0'),
  FormulaEntry(id: 'prob_iden', category: 'Probability', title: 'Identical Items',
      latex: r'n = \dfrac{n!}{n_1! n_2! \dots n_k!}'),
];

class FormulaScreen extends StatefulWidget {
  const FormulaScreen({super.key});

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}

class _FormulaScreenState extends State<FormulaScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<String> _favorites = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorite_formulas') ?? [];
    setState(() {
      _favorites.addAll(favList);
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    await prefs.setStringList('favorite_formulas', _favorites.toList());
  }

  List<String> get _categories {
    final cats = _formulas.map((f) => f.category).toSet().toList()..sort();
    return ['All', '⭐ Favorites', ...cats];
  }

  List<FormulaEntry> get _filtered {
    Iterable<FormulaEntry> list = _formulas;

    if (_selectedCategory == '⭐ Favorites') {
      list = list.where((f) => _favorites.contains(f.id));
    } else if (_selectedCategory != 'All') {
      list = list.where((f) => f.category == _selectedCategory);
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((f) =>
          f.title.toLowerCase().contains(q) ||
          f.category.toLowerCase().contains(q));
    }

    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Information Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: const Text('Grade 12 Information Sheet'),
                  content: const Text(
                    'These formulas are provided in the official NSC Mathematics Paper 1 and Paper 2 exams.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search formulas...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      fillColor: AppTheme.surface,
                    ),
                  ),
                ),

                // Category filter chips
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surface2,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: selected ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Formula list
                Expanded(
                  child: _filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final f = _filtered[i];
                            final isFav = _favorites.contains(f.id);

                            return _FormulaCard(
                              formula: f,
                              isFavorite: isFav,
                              onFavoriteToggle: () => _toggleFavorite(f.id),
                              delay: i * 50,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            _selectedCategory == '⭐ Favorites'
                ? 'No favorite formulas yet.'
                : 'No formulas found matching "$_searchQuery"',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  final FormulaEntry formula;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final int delay;

  const _FormulaCard({
    required this.formula,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    formula.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFavorite ? Colors.amber : AppTheme.textMuted,
                    size: 20,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formula.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Math.tex(
                  formula.latex,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: AppTheme.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
