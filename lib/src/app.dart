import 'dart:async';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'camera_panel.dart';
import 'interview_engine.dart';
import 'models.dart';
import 'question_bank.dart';
import 'session_store.dart';
import 'voice_biometrics.dart';

const navy = Color(0xff10233f);
const mint = Color(0xff19b394);
const electricBlue = Color(0xff1769ff);
const canvas = Color(0xfff4f7fb);

class InterviewCoachApp extends StatelessWidget {
  const InterviewCoachApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'IntervAI Offline',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        primary: navy,
        secondary: mint,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: canvas,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xffdce5f2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: electricBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: navy.withValues(alpha: .10),
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: mint.withValues(alpha: .18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xffdce5f2)),
      ),
    ),
    home: const StartupGate(),
  );
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Object?>>(
    future: Future.wait([
      SessionStore().isSignedIn(),
      SessionStore().loadUser(),
    ]),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final signedIn = snapshot.data![0] as bool;
      final name = snapshot.data![1] as String?;
      return signedIn && name != null
          ? DashboardPage(name: name)
          : const AuthPage();
    },
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final store = SessionStore();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool signIn = true;
  bool hidePassword = true;
  String? error;

  Future<void> submit() async {
    if (email.text.trim().isEmpty ||
        password.text.length < 4 ||
        (!signIn && name.text.trim().isEmpty)) {
      setState(
        () => error =
            'Enter all details. Password must have at least 4 characters.',
      );
      return;
    }
    String? candidate;
    if (signIn) {
      candidate = await store.signIn(email.text, password.text);
      if (candidate == null) {
        setState(
          () => error =
              'Email or password is incorrect. Create an account first.',
        );
        return;
      }
    } else {
      await store.createAccount(name.text.trim(), email.text, password.text);
      candidate = name.text.trim();
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage(name: candidate!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: navy,
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/intervai_logo.png', height: 150),
                  const SizedBox(height: 16),
                  Text(
                    'IntervAI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const Text(
                    'Private offline interview preparation',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Sign in')),
                      ButtonSegment(
                        value: false,
                        label: Text('Create account'),
                      ),
                    ],
                    selected: {signIn},
                    onSelectionChanged: (v) => setState(() {
                      signIn = v.first;
                      error = null;
                    }),
                  ),
                  const SizedBox(height: 18),
                  if (!signIn) ...[
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: hidePassword,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: submit,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(signIn ? 'Sign in' : 'Create account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your account and interview data stay only on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = TextEditingController();
  final store = SessionStore();

  @override
  void initState() {
    super.initState();
    store.loadUser().then((name) {
      if (mounted && name != null) controller.text = name;
    });
  }

  void login() {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    store.saveUser(name);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/intervai_logo.png', height: 150),
                  const SizedBox(height: 20),
                  Text(
                    'IntervAI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const Text(
                    'Your private, fully offline interview coach',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => login(),
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: login,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Continue offline'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: mint),
                      SizedBox(width: 6),
                      Text('No account or internet required'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.name});
  final String name;
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final store = SessionStore();
  List<Map<String, dynamic>> history = [];
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final data = await store.loadHistory();
    if (mounted) setState(() => history = data);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/intervai_logo.png',
              width: 38,
              height: 38,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text('IntervAI'),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Center(child: Text(widget.name)),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () async {
            await store.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (_) => false,
              );
            }
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Ready to practice, ${widget.name}?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Run realistic interviews and receive instant, private feedback.',
            ),
            const SizedBox(height: 24),
            Card(
              color: navy,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 18,
                  children: [
                    const SizedBox(
                      width: 560,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start a new mock interview',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose your role and difficulty. Answers are evaluated locally on this device.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: mint),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SetupPage()),
                        );
                        refresh();
                      },
                      icon: const Icon(Icons.mic),
                      label: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text('Start interview'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What you can practise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _Feature(
                  icon: Icons.description_outlined,
                  title: 'Resume-based',
                  detail: '60 project questions',
                ),
                _Feature(
                  icon: Icons.code,
                  title: 'Technical',
                  detail: '60 role-specific questions',
                ),
                _Feature(
                  icon: Icons.smart_toy_outlined,
                  title: 'AI',
                  detail: '60 artificial intelligence questions',
                ),
                _Feature(
                  icon: Icons.people_alt_outlined,
                  title: 'HR & behavioural',
                  detail: '60 STAR-based questions',
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent interviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text('${history.length} saved locally'),
              ],
            ),
            const SizedBox(height: 10),
            if (history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(26),
                  child: Center(
                    child: Text('Your completed interviews will appear here.'),
                  ),
                ),
              )
            else
              ...history
                  .take(5)
                  .map(
                    (item) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: mint.withValues(alpha: .12),
                          child: Text('${(item['score'] as num).round()}'),
                        ),
                        title: Text('${item['domain']} · ${item['type']}'),
                        subtitle: Text(
                          '${item['questions']} questions · ${DateTime.parse(item['date']).toLocal().toString().split(' ').first}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 245,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: mint.withValues(alpha: .12),
              child: Icon(icon, color: mint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(detail, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  InterviewType type = InterviewType.technical;
  Difficulty difficulty = Difficulty.intermediate;
  String domain = domains.first;
  int count = 10;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Configure interview')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _StepTitle(number: '1', title: 'Select interview type'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: InterviewType.values
                  .map(
                    (item) => ChoiceChip(
                      label: Text('${item.label} · 60 questions'),
                      selected: type == item,
                      onSelected: (_) => setState(() => type = item),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 26),
            const _StepTitle(number: '2', title: 'Choose domain / job role'),
            SearchableDomainField(
              value: domain,
              onChanged: (value) => setState(() => domain = value),
            ),
            const SizedBox(height: 26),
            const _StepTitle(number: '3', title: 'Set difficulty'),
            Wrap(
              spacing: 10,
              children: Difficulty.values
                  .map(
                    (e) => ChoiceChip(
                      label: Text(e.label),
                      selected: difficulty == e,
                      onSelected: (_) => setState(() => difficulty = e),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 26),
            const _StepTitle(number: '4', title: 'Number of questions'),
            Slider(
              value: count.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$count',
              onChanged: (v) => setState(() => count = v.round()),
            ),
            Text('$count questions · approximately ${count * 2} minutes'),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                final config = InterviewConfig(
                  type: type,
                  domain: domain,
                  difficulty: difficulty,
                  questionCount: count,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadinessPage(config: config),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Begin interview'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SearchableDomainField extends StatelessWidget {
  const SearchableDomainField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  Future<void> openPicker(BuildContext context) async {
    final search = TextEditingController();
    var filtered = List<String>.of(domains);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => FractionallySizedBox(
          heightFactor: .86,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.work_outline),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose domain / job role',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${domains.length} professional fields available',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: search,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search role, field, or specialization…',
                    suffixIcon: Icon(Icons.tune),
                  ),
                  onChanged: (query) => setModalState(() {
                    final normalized = query.trim().toLowerCase();
                    filtered = domains
                        .where(
                          (item) => item.toLowerCase().contains(normalized),
                        )
                        .toList();
                  }),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 44,
                                color: Colors.black38,
                              ),
                              SizedBox(height: 8),
                              Text('No matching field found'),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final active = item == value;
                            return Material(
                              color: active
                                  ? mint.withValues(alpha: .14)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: active
                                      ? mint
                                      : const Color(0xffedf3fb),
                                  foregroundColor: active ? Colors.white : navy,
                                  child: Icon(_domainIcon(item)),
                                ),
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: active
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                                trailing: active
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: mint,
                                      )
                                    : const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pop(context, item),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // The modal route can still be finishing its reverse animation when the
    // result future completes. Disposing its controller or updating an
    // already-removed setup page here causes framework dependent-lifecycle
    // assertions on some Android builds.
    if (selected != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) onChanged(selected);
      });
    }
  }

  IconData _domainIcon(String item) {
    final value = item.toLowerCase();
    if (value.contains('ai') ||
        value.contains('machine') ||
        value.contains('data')) {
      return Icons.smart_toy_outlined;
    }
    if (value.contains('software') ||
        value.contains('development') ||
        value.contains('devops')) {
      return Icons.code;
    }
    if (value.contains('security') || value.contains('network')) {
      return Icons.security;
    }
    if (value.contains('design') || value.contains('architecture')) {
      return Icons.design_services_outlined;
    }
    if (value.contains('health') || value.contains('pharmacy')) {
      return Icons.medical_services_outlined;
    }
    if (value.contains('finance') || value.contains('banking')) {
      return Icons.account_balance_outlined;
    }
    if (value.contains('engineering')) {
      return Icons.engineering_outlined;
    }
    if (value.contains('education') || value.contains('teaching')) {
      return Icons.school_outlined;
    }
    return Icons.work_outline;
  }

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => openPicker(context),
    child: InputDecorator(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        labelText: 'Search and select a field',
        suffixIcon: Icon(Icons.expand_more),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title});
  final String number, title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: navy,
          foregroundColor: Colors.white,
          child: Text(number, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    ),
  );
}

class ReadinessPage extends StatefulWidget {
  const ReadinessPage({super.key, required this.config});
  final InterviewConfig config;
  @override
  State<ReadinessPage> createState() => _ReadinessPageState();
}

class _ReadinessPageState extends State<ReadinessPage>
    with WidgetsBindingObserver {
  static const deviceSettings = MethodChannel('ai_interview/device_settings');
  final voiceBiometrics = OfflineVoiceBiometrics();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  bool checkingDevices = true;
  bool offlineConfirmed = false;
  bool cameraConfirmed = false;
  bool internetChecked = false;
  bool cameraChecked = false;
  bool rulesAccepted = false;
  bool enrollingVoice = false;
  bool voiceEnrollmentBusy = false;
  VoiceProfile? voiceProfile;
  String voiceStatus = 'Voice profile not recorded';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkDeviceStatus();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      updateConnectivity,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) checkDeviceStatus();
  }

  Future<void> checkDeviceStatus() async {
    final connections = await Connectivity().checkConnectivity();
    List<CameraDescription> cameras = const [];
    try {
      cameras = await availableCameras();
    } catch (_) {
      cameras = const [];
    }
    if (!mounted) return;
    setState(() {
      offlineConfirmed =
          connections.isEmpty ||
          connections.every((item) => item == ConnectivityResult.none);
      internetChecked = offlineConfirmed;
      cameraConfirmed = cameras.isNotEmpty;
      checkingDevices = false;
    });
  }

  void updateConnectivity(List<ConnectivityResult> connections) {
    if (!mounted) return;
    final isOffline =
        connections.isEmpty ||
        connections.every((item) => item == ConnectivityResult.none);
    setState(() {
      offlineConfirmed = isOffline;
      internetChecked = isOffline;
    });
  }

  Future<void> openInternetSettings() async {
    if (offlineConfirmed) {
      setState(() => internetChecked = true);
      return;
    }
    try {
      await deviceSettings.invokeMethod<void>('openInternetSettings');
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to open settings.')),
      );
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open device settings and turn off Wi-Fi and mobile data.',
          ),
        ),
      );
    }
  }

  Future<void> toggleVoiceEnrollment() async {
    if (voiceEnrollmentBusy) return;
    setState(() => voiceEnrollmentBusy = true);
    if (!enrollingVoice) {
      final allowed = await voiceBiometrics.startCapture();
      if (!mounted) return;
      if (!allowed) {
        setState(() {
          voiceEnrollmentBusy = false;
          voiceStatus =
              voiceBiometrics.lastError ?? 'Microphone permission is required.';
        });
        return;
      }
      setState(() {
        voiceEnrollmentBusy = false;
        enrollingVoice = true;
        voiceStatus = 'Recording… read the phrase clearly, then tap Finish.';
      });
    } else {
      final profile = await voiceBiometrics.stopAndCreateProfile();
      if (!mounted) return;
      setState(() {
        voiceEnrollmentBusy = false;
        enrollingVoice = false;
        voiceProfile = profile;
        voiceStatus = profile == null
            ? '${voiceBiometrics.lastError ?? 'Not enough clear speech was captured.'} Please record again.'
            : 'Voice enrolled successfully on this device.';
      });
    }
  }

  void startInterview() {
    final missing = <String>[
      if (!offlineConfirmed) 'turn off Wi-Fi and mobile data',
      if (!cameraConfirmed) 'allow camera access',
      if (!internetChecked) 'check the Internet confirmation box',
      if (!cameraChecked) 'check the Camera confirmation box',
      if (voiceProfile == null) 'enroll your voice',
      if (!rulesAccepted) 'accept the interview rules',
    ];
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Before starting, please ${missing.join(', ')}.'),
          ),
        );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InterviewPage(config: widget.config, voiceProfile: voiceProfile!),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivitySubscription?.cancel();
    voiceBiometrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Interview readiness')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Before you begin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The interview works without internet. Prepare your device for a distraction-free session.',
            ),
            const SizedBox(height: 22),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Checkbox(
                      value: internetChecked,
                      onChanged: (_) => openInternetSettings(),
                      activeColor: Colors.green,
                    ),
                    title: Text(
                      offlineConfirmed
                          ? 'Device is offline'
                          : 'Internet connection detected',
                    ),
                    subtitle: Text(
                      offlineConfirmed
                          ? 'Verified automatically. No network connection is active.'
                          : 'Turn off both Wi-Fi and mobile data in device settings, then return here.',
                    ),
                    trailing: checkingDevices
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Checkbox(
                      value: cameraChecked,
                      onChanged: (value) =>
                          setState(() => cameraChecked = value ?? false),
                      activeColor: Colors.green,
                    ),
                    title: Text(
                      cameraConfirmed
                          ? 'Camera detected automatically'
                          : 'No camera detected',
                    ),
                    subtitle: Text(
                      cameraConfirmed
                          ? 'The front camera will remain active throughout the interview.'
                          : 'Use a physical device with a camera and grant camera permission in system settings.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Card(
              child: ListTile(
                leading: Icon(Icons.record_voice_over, color: mint),
                title: Text('Meet your AI voice interviewer'),
                subtitle: Text(
                  'Your private on-device assistant introduces the session and reads every question aloud using the device’s offline voice.',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enroll your voice',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Read this sentence in your normal interview voice:',
                    ),
                    const SizedBox(height: 8),
                    const SelectableText(
                      '“My voice confirms that I am ready for this interview.”',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: voiceEnrollmentBusy
                          ? null
                          : toggleVoiceEnrollment,
                      icon: Icon(
                        voiceEnrollmentBusy
                            ? Icons.hourglass_top
                            : enrollingVoice
                            ? Icons.stop_circle
                            : Icons.mic,
                      ),
                      label: Text(
                        voiceEnrollmentBusy
                            ? 'Please wait…'
                            : enrollingVoice
                            ? 'Finish voice recording'
                            : 'Record voice profile',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      voiceStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: voiceProfile == null
                            ? Colors.orange.shade800
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important interview instructions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Sit alone in a quiet, well-lit room.'),
                    const Text(
                      '2. Keep your face fully visible in the camera frame.',
                    ),
                    const Text('3. No other person may enter or speak.'),
                    const Text(
                      '4. Do not minimize, leave, or switch away from the app.',
                    ),
                    const Text('5. Keep mobile data and Wi-Fi switched off.'),
                    const Text(
                      '6. Person, voice, camera, and app-switch events count as violations.',
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Three-warning policy: the third violation automatically ends the interview.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.redAccent,
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: rulesAccepted,
                      onChanged: (value) =>
                          setState(() => rulesAccepted = value ?? false),
                      title: const Text('I understand and accept these rules.'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed:
                  internetChecked &&
                      cameraChecked &&
                      rulesAccepted &&
                      voiceProfile != null
                  ? startInterview
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Padding(
                padding: EdgeInsets.all(15),
                child: Text('Accept rules & start interview'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class InterviewPage extends StatefulWidget {
  const InterviewPage({
    super.key,
    required this.config,
    required this.voiceProfile,
  });
  final InterviewConfig config;
  final VoiceProfile voiceProfile;
  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage>
    with WidgetsBindingObserver {
  final engine = InterviewEngine();
  final voice = FlutterTts();
  final voiceBiometrics = OfflineVoiceBiometrics();
  final answer = TextEditingController();
  late final List<InterviewQuestion> questions;
  final results = <AnswerResult>[];
  int index = 0;
  bool recording = false;
  AnswerScore? preview;
  int violations = 0;
  bool monitoringStarted = false;
  bool pendingAppSwitchViolation = false;
  bool terminating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    questions = engine.questionsFor(widget.config);
    introduce();
    Future.delayed(const Duration(seconds: 2), () => monitoringStarted = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!monitoringStarted || violations >= 3) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      pendingAppSwitchViolation = true;
    } else if (state == AppLifecycleState.resumed &&
        pendingAppSwitchViolation) {
      pendingAppSwitchViolation = false;
      terminateInterview(
        'The candidate left or minimized the interview application.',
      );
    }
  }

  Future<void> terminateInterview(String reason) async {
    if (!mounted || terminating) return;
    terminating = true;
    await voice.stop();
    await voice.speak(
      'The interview application was left. This interview is now terminated.',
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TerminatedInterviewPage(reason: reason),
        ),
      );
    }
  }

  Future<void> reportViolation(String reason) async {
    if (!mounted || violations >= 3) return;
    setState(() => violations++);
    await voice.stop();
    if (violations >= 3) {
      await voice.speak(
        'Third violation detected. This interview is now terminated.',
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TerminatedInterviewPage(reason: reason),
          ),
        );
      }
      return;
    }
    await voice.speak('Warning $violations of 3. $reason');
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 40,
        ),
        title: Text('Warning $violations of 3'),
        content: Text(
          '$reason\n\nThe third violation will automatically end the interview.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
    await speakQuestion();
  }

  Future<void> introduce() async {
    await voice.setLanguage('en-US');
    await voice.setSpeechRate(.46);
    await voice.awaitSpeakCompletion(true);
    await voice.speak(
      'Hello. I am your offline AI interview assistant. Welcome to your ${widget.config.domain} interview. I will ask ${widget.config.questionCount} questions. Take your time, and answer clearly. Here is question one. ${questions.first.text}',
    );
    await startAutomaticVoiceCheck();
  }

  Future<void> speakQuestion() async {
    await voice.stop();
    await voice.speak(questions[index].text);
    await startAutomaticVoiceCheck();
  }

  Future<void> startAutomaticVoiceCheck() async {
    if (!mounted || recording || terminating) return;
    final allowed = await voiceBiometrics.startCapture();
    if (!mounted) return;
    if (allowed) setState(() => recording = true);
  }

  Future<void> toggleRecording() async {
    if (!recording) {
      await startAutomaticVoiceCheck();
      if (!recording) {
        await reportViolation(
          'Microphone access was unavailable for voice verification.',
        );
      }
      return;
    }
    final match = await voiceBiometrics.stopAndCompare(widget.voiceProfile);
    if (!mounted) return;
    setState(() => recording = false);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Not enough clear speech. Please record the answer again.',
          ),
        ),
      );
    } else if (!match.matches) {
      await reportViolation(
        'Voice is not matching the enrolled candidate voice.',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voice matched · ${(match.similarity * 100).round()}% similarity',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    voice.stop();
    voiceBiometrics.dispose();
    answer.dispose();
    super.dispose();
  }

  void evaluate() {
    if (answer.text.trim().isEmpty) return;
    setState(() => preview = engine.evaluate(questions[index], answer.text));
  }

  Future<void> next() async {
    if (preview == null) return;
    results.add(
      AnswerResult(
        question: questions[index],
        answer: answer.text.trim(),
        score: preview!,
      ),
    );
    if (index == questions.length - 1) {
      final session = InterviewSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        config: widget.config,
        results: List.of(results),
      );
      await SessionStore().saveSession(session);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ReportPage(session: session)),
        );
      }
    } else {
      setState(() {
        index++;
        preview = null;
        recording = false;
        answer.clear();
      });
      await speakQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          terminateInterview(
            'The candidate attempted to leave the interview using the Back action.',
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          title: Text('${widget.config.domain} interview'),
          actions: [
            Center(
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18),
                  const SizedBox(width: 5),
                  Text('$violations / 3'),
                ],
              ),
            ),
            Center(child: Text('${index + 1} / ${questions.length}  ')),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                LinearProgressIndicator(
                  value: (index + 1) / questions.length,
                  color: mint,
                ),
                const SizedBox(height: 24),
                InterviewCameraPanel(onViolation: reportViolation),
                const SizedBox(height: 8),
                Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.green,
                    ),
                    title: const Text('Offline proctoring active'),
                    subtitle: Text(
                      'Single-person and enrolled-voice rule · ${3 - violations} warnings remaining',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'QUESTION ${index + 1}',
                  style: const TextStyle(
                    color: mint,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: speakQuestion,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Ask question aloud again'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(label: Text(q.difficulty.label)),
                    if (q.starRecommended) ...[
                      const SizedBox(width: 8),
                      const Chip(
                        avatar: Icon(Icons.auto_awesome, size: 16),
                        label: Text('STAR recommended'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: answer,
                  minLines: 7,
                  maxLines: 12,
                  onChanged: (_) {
                    if (preview != null) setState(() => preview = null);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Candidate answer / offline transcript',
                    alignLabelWithHint: true,
                    hintText:
                        'Speak your answer or type the transcript here...',
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: toggleRecording,
                      icon: Icon(recording ? Icons.stop_circle : Icons.mic),
                      label: Text(
                        recording
                            ? 'Stop recording'
                            : 'Record answer & verify voice',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        answer.clear();
                        preview = null;
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry answer'),
                    ),
                    FilledButton.icon(
                      onPressed: recording ? null : evaluate,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Analyse answer'),
                    ),
                  ],
                ),
                if (recording)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      '● Recording answer and comparing the speaker with the enrolled offline voice profile…',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                if (preview != null) ...[
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Instant AI answer analysis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${preview!.overall.round()} / 100',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: mint,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _Metric(
                            label: 'Relevance',
                            value: preview!.relevance,
                          ),
                          _Metric(label: 'Keywords', value: preview!.keywords),
                          _Metric(label: 'Clarity', value: preview!.clarity),
                          _Metric(label: 'Fluency', value: preview!.fluency),
                          const SizedBox(height: 10),
                          Text(
                            '${preview!.wordCount} words · ${preview!.fillerWords} filler words · matched: ${preview!.matchedKeywords.isEmpty ? 'none' : preview!.matchedKeywords.join(', ')}',
                          ),
                          const SizedBox(height: 10),
                          Text(
                            preview!.feedback.first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: next,
                    icon: Icon(
                      index == questions.length - 1
                          ? Icons.assessment
                          : Icons.arrow_forward,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        index == questions.length - 1
                            ? 'Finish & view report'
                            : 'Save & next question',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(width: 85, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: value >= 70 ? mint : Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 30, child: Text('${value.round()}')),
      ],
    ),
  );
}

class TerminatedInterviewPage extends StatelessWidget {
  const TerminatedInterviewPage({super.key, required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.gpp_bad_outlined,
                    color: Colors.red,
                    size: 68,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Interview terminated',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Three proctoring violations were recorded. Answers from this attempt were not added to interview history.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    color: Colors.red.shade50,
                    child: Text(
                      'Final event: $reason',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Return to dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.session});
  final InterviewSession session;
  @override
  Widget build(BuildContext context) {
    final average = session.score;
    final allFeedback = session.results
        .expand((e) => e.score.feedback)
        .toSet()
        .take(4)
        .toList();
    final weakest = List<AnswerResult>.of(session.results)
      ..sort((a, b) => a.score.overall.compareTo(b.score.overall));
    return Scaffold(
      appBar: AppBar(title: const Text('Interview report')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                color: navy,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INTERVIEW COMPLETE',
                            style: TextStyle(
                              color: mint,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            session.config.domain,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${session.config.type.label} · ${session.config.difficulty.label}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 47,
                        backgroundColor: Colors.white,
                        child: Text(
                          '${average.round()}',
                          style: const TextStyle(
                            fontSize: 32,
                            color: navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Personalized improvement plan',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...allFeedback.asMap().entries.map(
                (e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: mint.withValues(alpha: .14),
                      foregroundColor: mint,
                      child: Text('${e.key + 1}'),
                    ),
                    title: Text(e.value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Question breakdown',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...session.results.asMap().entries.map(
                (e) => Card(
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      child: Text('${e.value.score.overall.round()}'),
                    ),
                    title: Text(e.value.question.text),
                    subtitle: Text(
                      '${e.value.score.wordCount} words · ${e.value.score.matchedKeywords.length} key ideas',
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ideal answer approach\n${e.value.question.idealAnswer}\n\nYour answer\n${e.value.answer}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (weakest.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Card(
                    color: Colors.orange.shade50,
                    child: ListTile(
                      leading: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange,
                      ),
                      title: const Text('Weak topic to revisit'),
                      subtitle: Text(weakest.first.question.text),
                    ),
                  ),
                ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text('Back to dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
