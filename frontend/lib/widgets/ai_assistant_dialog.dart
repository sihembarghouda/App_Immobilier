import 'package:flutter/material.dart';

class AIAssistantDialog extends StatefulWidget {
  const AIAssistantDialog({Key? key}) : super(key: key);

  @override
  State<AIAssistantDialog> createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends State<AIAssistantDialog> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, dynamic>> _conversation = [];
  bool _isLoading = false;

  final List<Map<String, String>> _suggestedQuestions = [
    {
      'category': 'Recherche',
      'question': 'Je cherche une maison familiale',
      'icon': '🏠',
    },
    {
      'category': 'Budget',
      'question': 'Quel est mon budget réaliste?',
      'icon': '💰',
    },
    {
      'category': 'Conseils',
      'question': 'Dois-je acheter ou louer?',
      'icon': '💡',
    },
    {
      'category': 'Location',
      'question': 'Meilleurs quartiers pour familles?',
      'icon': '📍',
    },
  ];

  @override
  void initState() {
    super.initState();
    _showWelcomeMessage();
  }

  void _showWelcomeMessage() {
    setState(() {
      _conversation.add({
        'isUser': false,
        'message': '''Bonjour! 👋 Je suis votre assistant immobilier.

Je peux vous aider à:
🏠 Trouver la propriété idéale
💰 Calculer votre budget
📍 Choisir le bon quartier
💡 Prendre la meilleure décision

Comment puis-je vous aider aujourd'hui?''',
        'timestamp': DateTime.now(),
      });
    });
  }

  void _askQuestion(String question) {
    if (question.trim().isEmpty) return;

    setState(() {
      _conversation.add({
        'isUser': true,
        'message': question,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _questionController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      final answer = _getAnswer(question);
      setState(() {
        _conversation.add({
          'isUser': false,
          'message': answer,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    });
  }

  String _getAnswer(String question) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('budget') || lowerQuestion.contains('prix')) {
      return '''💰 **Calcul de Budget**

**Formule simple:**
Revenus × 33% = Mensualité max

**Exemple:**
2000 DT/mois → 660 DT/mois
Sur 20 ans: ~130,000-160,000 DT

**Frais additionnels:**
• Apport: 10-20%
• Notaire: 2-3%
• Agence: 2-5%

💡 **Conseil:** Gardez une épargne de sécurité!''';
    }

    if (lowerQuestion.contains('acheter') || lowerQuestion.contains('louer')) {
      return '''🏠 **Acheter vs Louer**

**Achetez si:**
✓ Stabilité professionnelle
✓ Rester > 5 ans
✓ Constitution patrimoine

**Louez si:**
✓ Mobilité professionnelle
✓ Budget limité court terme
✓ Flexibilité géographique

💡 **Mon conseil:** Évaluez vos projets à 5-10 ans!''';
    }

    if (lowerQuestion.contains('quartier') || lowerQuestion.contains('zone')) {
      return '''📍 **Meilleurs Quartiers**

**Familles:**
🏡 Jardins de Carthage
🏡 El Menzah
🏡 Soukra

**Jeunes Actifs:**
🏙️ Centre-Ville
🏙️ Lac 1 & 2
🏙️ Marsa

**Critères clés:**
• Proximité travail
• Écoles
• Transports''';
    }

    if (lowerQuestion.contains('document') ||
        lowerQuestion.contains('papier')) {
      return '''📋 **Documents Nécessaires**

**Acheteur:**
• Carte d'identité
• Justificatifs revenus (3 mois)
• Relevés bancaires

**Prêt bancaire:**
• Attestation travail
• Bulletins salaire
• Épargne

**Délais:**
⏱️ Accord: 48h-1 semaine
⏱️ Offre: 2-4 semaines
⏱️ Signature: 3-4 mois''';
    }

    if (lowerQuestion.contains('cherche') ||
        lowerQuestion.contains('maison') ||
        lowerQuestion.contains('appartement') ||
        lowerQuestion.contains('villa')) {
      return '''🔍 **Recherche de Propriété**

**Étapes essentielles:**
1. Définir critères précis
2. Visiter 5-10 propriétés
3. Comparer quartiers
4. Négocier le prix (5-15%)

**Checklist visite:**
✓ État général
✓ Travaux nécessaires
✓ Charges copropriété
✓ Quartier jour/nuit

💡 Utilisez nos filtres de recherche!''';
    }

    return '''Merci pour votre question! 😊

Pour vous aider au mieux, pouvez-vous préciser:

• Quel type de bien cherchez-vous?
• Quel est votre budget approximatif?
• Dans quelle zone souhaitez-vous?
• Achat ou location?

Je suis là pour vous guider! 🏠''';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assistant IA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'En ligne',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Suggested questions
            if (_conversation.length == 1)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Questions suggérées:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedQuestions.map((q) {
                        return ActionChip(
                          avatar: Text(q['icon']!),
                          label: Text(q['question']!),
                          onPressed: () => _askQuestion(q['question']!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Conversation
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _conversation.length,
                itemBuilder: (context, index) {
                  final message = _conversation[index];
                  final isUser = message['isUser'] as bool;

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['message'] as String,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('L\'assistant réfléchit...'),
                  ],
                ),
              ),

            // Input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        hintText: 'Posez votre question...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      maxLines: null,
                      onSubmitted: _askQuestion,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _askQuestion(_questionController.text),
                    icon: const Icon(Icons.send, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
