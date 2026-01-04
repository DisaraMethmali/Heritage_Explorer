// lib/screens/memory_test_screen.dart
import 'package:flutter/material.dart';
import 'test_results_screen.dart';

class MemoryTestScreen extends StatefulWidget {
  const MemoryTestScreen({super.key});

  @override
  State<MemoryTestScreen> createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  // Hardcoded 10 questions
  final List<Map<String, dynamic>> _questions = [
    {
      "id": 1,
      "question": "What is Sri Dalada Maligawa?",
      "options": [
        "A royal palace in Kandy",
        "Temple of the Sacred Tooth Relic",
        "A Buddhist monastery",
        "An ancient library"
      ],
      "correct_answer": 1
    },
    {
      "id": 2,
      "question": "When was Sri Dalada Maligawa designated as a UNESCO World Heritage Site?",
      "options": ["1978", "1988", "1998", "2008"],
      "correct_answer": 1
    },
    {
      "id": 3,
      "question": "What sacred relic does Sri Dalada Maligawa house?",
      "options": [
        "Buddha's robe",
        "Buddha's begging bowl",
        "Buddha's left canine tooth",
        "Buddha's walking stick"
      ],
      "correct_answer": 2
    },
    {
      "id": 4,
      "question": "Where is the Temple of the Sacred Tooth Relic located?",
      "options": ["Colombo", "Anuradhapura", "Kandy", "Polonnaruwa"],
      "correct_answer": 2
    },
    {
      "id": 5,
      "question": "What is located to the south of Sri Dalada Maligawa?",
      "options": [
        "Royal Palace",
        "Kandy Lake (Kiri Muhuda)",
        "Udawaththa Kelaya forest",
        "Natha Devala"
      ],
      "correct_answer": 1
    },
    {
      "id": 6,
      "question": "What architectural style does Sri Dalada Maligawa feature?",
      "options": [
        "Colonial architecture",
        "Modern Buddhist style",
        "Kandyan architectural style",
        "South Indian temple style"
      ],
      "correct_answer": 2
    },
    {
      "id": 7,
      "question": "What does 'Kiri Muhuda' mean?",
      "options": ["Holy Water", "Milky Ocean", "Sacred Lake", "Divine Pool"],
      "correct_answer": 1
    },
    {
      "id": 8,
      "question": "What materials are used in the temple's intricate carvings?",
      "options": [
        "Wood and stone only",
        "Gold, silver, bronze, and ivory",
        "Marble and granite",
        "Clay and terracotta"
      ],
      "correct_answer": 1
    },
    {
      "id": 9,
      "question": "What is located to the north of Sri Dalada Maligawa?",
      "options": [
        "Kandy Lake",
        "The Royal Palace",
        "Udawaththa Kelaya forest",
        "Paththini Devala"
      ],
      "correct_answer": 1
    },
    {
      "id": 10,
      "question": "Who primarily visits Sri Dalada Maligawa?",
      "options": [
        "Only monks",
        "Only Sri Lankan citizens",
        "Local and foreign devotees and tourists",
        "Only during festivals"
      ],
      "correct_answer": 2
    },
  ];

  Map<String, int> _answers = {};
  bool _isSubmitting = false;
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();

  void _selectAnswer(int questionId, int optionIndex) {
    setState(() {
      _answers[questionId.toString()] = optionIndex;
    });
  }

  void _submitTest() {
    if (_answers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Calculate results locally
    int correct = 0;
    List<Map<String, dynamic>> results = [];
    for (var q in _questions) {
      final userAnswer = _answers[q['id'].toString()];
      final isCorrect = userAnswer == q['correct_answer'];
      if (isCorrect) correct++;
      results.add({
        "question_id": q['id'],
        "question": q['question'],
        "user_answer": userAnswer,
        "correct_answer": q['correct_answer'],
        "is_correct": isCorrect,
      });
    }

    final score = (correct / _questions.length) * 100;

    setState(() => _isSubmitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(
          results: {
            "score": score,
            "correct": correct,
            "total": _questions.length,
            "results": results
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Test'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_answers.length}/${_questions.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _answers.length / _questions.length,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              onPageChanged: (index) => setState(() => _currentQuestionIndex = index),
              itemBuilder: (context, index) => _buildQuestionCard(_questions[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentQuestionIndex < _questions.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _submitTest();
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentQuestionIndex < _questions.length - 1
                            ? 'Next'
                            : 'Submit Test'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final questionId = question['id'];
    final selectedAnswer = _answers[questionId.toString()];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${question['id']} of ${_questions.length}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                question['question'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ...List.generate(
                question['options'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _selectAnswer(questionId, index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedAnswer == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: selectedAnswer == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: selectedAnswer == index
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedAnswer == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: selectedAnswer == index
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            child: selectedAnswer == index
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question['options'][index],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
