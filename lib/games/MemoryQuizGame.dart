import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';

class QuizManagementPage extends StatefulWidget {
  const QuizManagementPage({Key? key}) : super(key: key);

  @override
  State<QuizManagementPage> createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends State<QuizManagementPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? patientId;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;

  // Custom color scheme
  final Color primaryColor = const Color(0xFF1E3A8A);
  final Color backgroundColor = const Color.fromARGB(255, 242, 241, 241);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPatientId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatientId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'User not authenticated';
          isLoading = false;
        });
        return;
      }

      final patientQuery =
          await _firestore
              .collection('patients')
              .where('assistantId', isEqualTo: user.uid)
              .limit(1)
              .get();

      if (patientQuery.docs.isEmpty) {
        setState(() {
          errorMessage = 'No patient assigned';
          isLoading = false;
        });
        return;
      }

      setState(() {
        patientId = patientQuery.docs.first.id;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading patient: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: primaryColor.withOpacity(0.8),
          surface: backgroundColor,
          background: backgroundColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: Colors.white),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Quiz Management'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Create Quiz'),
              Tab(
                icon: Icon(Icons.manage_search_outlined),
                text: 'Manage Quizzes',
              ),
            ],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : patientId == null
                ? const Center(child: Text('No patient assigned'))
                : TabBarView(
                  controller: _tabController,
                  children: [
                    AddQuizTab(
                      patientId: patientId!,
                      primaryColor: primaryColor,
                    ),
                    ManageQuizzesTab(
                      patientId: patientId!,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
      ),
    );
  }
}

class AddQuizTab extends StatefulWidget {
  final String patientId;
  final Color primaryColor;

  const AddQuizTab({
    Key? key,
    required this.patientId,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<AddQuizTab> createState() => _AddQuizTabState();
}

class _AddQuizTabState extends State<AddQuizTab>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<QuizQuestion> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int? _correctIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    if (_formKey.currentState == null) return;

    if (_formKey.currentState!.validate() && _correctIndex != null) {
      setState(() {
        _questions.add(
          QuizQuestion(
            question: _questionController.text,
            answers: _answerControllers.map((c) => c.text).toList(),
            correctIndex: _correctIndex!,
          ),
        );

        // Reset form
        _questionController.clear();
        for (var controller in _answerControllers) {
          controller.clear();
        }
        _correctIndex = null;
        _formKey.currentState!.reset();
      });

      // Play animation
      _animationController.reset();
      _animationController.forward();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill all fields and select correct answer',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _submitAllQuestions() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No questions to submit'),
          backgroundColor: widget.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      final quizzesRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .collection('quizzes');

      for (var question in _questions) {
        batch.set(quizzesRef.doc(), {
          'question': question.question,
          'answers': question.answers,
          'correctIndex': question.correctIndex,
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_questions.length} questions added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      setState(() {
        _questions.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding questions: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Create New Question',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          labelText: 'Question',
                          prefixIcon: Icon(
                            Icons.help_outline,
                            color: widget.primaryColor,
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter a question'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Answers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _answerControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Option ${index + 1}',
                                    prefixIcon: Icon(
                                      Icons.circle_outlined,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'Enter option ${index + 1}'
                                              : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: Icon(
                                  _correctIndex == index
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color:
                                      _correctIndex == index
                                          ? widget.primaryColor
                                          : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() => _correctIndex = index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _addQuestion,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add to Batch',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Batch Preview Section
            if (_questions.isNotEmpty) ...[
              Text(
                'Questions Batch (${_questions.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ..._questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return Dismissible(
                          key: Key('question-$index'),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Remove Question?'),
                                    content: const Text(
                                      'Are you sure you want to remove this question from the batch?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          onDismissed: (direction) {
                            setState(() => _questions.removeAt(index));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: widget.primaryColor
                                    .withOpacity(0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: widget.primaryColor),
                                ),
                              ),
                              title: Text(
                                question.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Correct: ${question.answers[question.correctIndex]}',
                                style: TextStyle(color: widget.primaryColor),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submitAllQuestions,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Submit All Questions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ManageQuizzesTab extends StatelessWidget {
  final String patientId;
  final Color primaryColor;

  const ManageQuizzesTab({
    Key? key,
    required this.patientId,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .collection('quizzes')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading quizzes: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 48,
                  color: primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No quizzes found',
                  style: TextStyle(color: primaryColor.withOpacity(0.7)),
                ),
              ],
            ),
          );
        }

        final quizzes = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final data = quiz.data() as Map<String, dynamic>;
            final question = data['question'] ?? 'No question text';
            final answers = List<String>.from(data['answers'] ?? []);
            final correctIndex = data['correctIndex'] as int? ?? 0;
            final isActive = data['active'] as bool? ?? true;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...answers.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final answer = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          idx == correctIndex
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color:
                                              idx == correctIndex
                                                  ? Colors.green
                                                  : primaryColor.withOpacity(
                                                    0.5,
                                                  ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            answer,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: isActive,
                            activeColor: primaryColor,
                            onChanged: (value) {
                              quiz.reference.update({'active': value});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              'Correct: ${answers.length > correctIndex ? answers[correctIndex] : 'N/A'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: primaryColor,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Delete Quiz?'),
                                      content: const Text(
                                        'This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed:
                                              () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onPressed: () {
                                            quiz.reference.delete();
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Quiz deleted',
                                                ),
                                                backgroundColor: primaryColor,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctIndex,
  });
}
