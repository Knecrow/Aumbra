// Fallback quests served when Gemini API is unavailable
// 50 generic quests organized by category

class FallbackQuest {
  final String title;
  final String description;
  final String category;

  const FallbackQuest({
    required this.title,
    required this.description,
    required this.category,
  });
}

const List<FallbackQuest> kFallbackQuests = [
  // Mind quests
  FallbackQuest(
    title: 'Read for 15 minutes',
    description: 'Pick up a book or article that interests you and read without distractions.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Learn one new thing',
    description: 'Spend 15 minutes learning something you\'ve been curious about. Watch a video, read a post, or explore a new topic.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Practice a skill',
    description: 'Dedicate 20 minutes to practicing a skill you\'re developing. Consistency builds mastery.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Write down 3 things you learned today',
    description: 'At the end of the day, reflect on 3 new pieces of knowledge or insights you gained.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Listen to an educational podcast',
    description: 'Put on a podcast about something you want to grow in and listen for at least 20 minutes.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Solve a puzzle or brain teaser',
    description: 'Challenge your mind with a sudoku, crossword, or logic puzzle for 15 minutes.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Watch a tutorial video',
    description: 'Find a tutorial on a skill relevant to your goals and watch it attentively.',
    category: 'Mind',
  ),
  FallbackQuest(
    title: 'Take a free online course module',
    description: 'Complete one lesson or module from an online course you\'re working through.',
    category: 'Mind',
  ),

  // Body quests
  FallbackQuest(
    title: '20-minute walk',
    description: 'Go for a 20-minute walk outside. Focus on your breath and surroundings.',
    category: 'Body',
  ),
  FallbackQuest(
    title: 'Do 3 sets of push-ups',
    description: 'Complete 3 sets of push-ups at your current level. Rest 60 seconds between sets.',
    category: 'Body',
  ),
  FallbackQuest(
    title: 'Stretch for 10 minutes',
    description: 'Do a full-body stretching routine focusing on tight areas. Hold each stretch for 30 seconds.',
    category: 'Body',
  ),
  FallbackQuest(
    title: 'Drink 8 glasses of water',
    description: 'Stay hydrated throughout the day. Track your water intake and hit 8 glasses.',
    category: 'Body',
  ),
  FallbackQuest(
    title: '10-minute morning yoga',
    description: 'Follow a simple morning yoga routine to wake up your body and set a positive tone.',
    category: 'Body',
  ),
  FallbackQuest(
    title: 'No processed food today',
    description: 'Challenge yourself to eat only whole, unprocessed foods today.',
    category: 'Body',
  ),
  FallbackQuest(
    title: '30 jumping jacks + 20 squats',
    description: 'Quick cardio burst: 30 jumping jacks followed by 20 bodyweight squats.',
    category: 'Body',
  ),
  FallbackQuest(
    title: 'Sleep before midnight',
    description: 'Commit to being in bed with lights off before midnight tonight.',
    category: 'Body',
  ),

  // Soul quests
  FallbackQuest(
    title: 'Create something with your hands',
    description: 'Spend 20 minutes drawing, sketching, cooking, or making anything creative.',
    category: 'Soul',
  ),
  FallbackQuest(
    title: 'Listen to new music',
    description: 'Explore a new artist or genre you\'ve never heard before. Let it move you.',
    category: 'Soul',
  ),
  FallbackQuest(
    title: 'Journal for 10 minutes',
    description: 'Write freely in a journal. No structure needed — just let your thoughts flow.',
    category: 'Soul',
  ),
  FallbackQuest(
    title: 'Watch a film that inspires you',
    description: 'Choose a movie or documentary that aligns with your values or sparks curiosity.',
    category: 'Soul',
  ),
  FallbackQuest(
    title: 'Spend 15 minutes in silence',
    description: 'Sit quietly without your phone. Let your mind wander and observe your thoughts.',
    category: 'Soul',
  ),
  FallbackQuest(
    title: 'Practice gratitude',
    description: 'Write down 5 things you are genuinely grateful for right now.',
    category: 'Soul',
  ),
  FallbackQuest(
    title: 'Do something purely for fun',
    description: 'Spend 30 minutes doing an activity purely for joy, with no productive goal attached.',
    category: 'Soul',
  ),

  // Environment quests
  FallbackQuest(
    title: 'Declutter one area',
    description: 'Pick one small area — a drawer, shelf, or desk — and organize it completely.',
    category: 'Environment',
  ),
  FallbackQuest(
    title: 'Clean your workspace',
    description: 'Wipe down your desk, organize your tools, and create a clean space to work.',
    category: 'Environment',
  ),
  FallbackQuest(
    title: 'Make your bed',
    description: 'Start the day by making your bed perfectly. A small win that sets the tone.',
    category: 'Environment',
  ),
  FallbackQuest(
    title: 'Delete 20 unused files or apps',
    description: 'Declutter your digital life — delete files, uninstall apps, or clean your desktop.',
    category: 'Environment',
  ),
  FallbackQuest(
    title: 'Do the dishes immediately after eating',
    description: 'Don\'t let dishes pile up. Clean up right after your meal today.',
    category: 'Environment',
  ),
  FallbackQuest(
    title: 'Organize one category in your closet',
    description: 'Pick shirts, pants, or shoes and neatly organize that category today.',
    category: 'Environment',
  ),

  // Social quests
  FallbackQuest(
    title: 'Reach out to a friend',
    description: 'Send a genuine message to a friend you haven\'t spoken to recently.',
    category: 'Social',
  ),
  FallbackQuest(
    title: 'Call a family member',
    description: 'Have a real conversation with a family member. No texting — call them.',
    category: 'Social',
  ),
  FallbackQuest(
    title: 'Give someone a genuine compliment',
    description: 'Tell someone something you genuinely appreciate about them today.',
    category: 'Social',
  ),
  FallbackQuest(
    title: 'Ask someone how they\'re really doing',
    description: 'Have a deeper conversation with someone by asking how they\'re truly feeling.',
    category: 'Social',
  ),
  FallbackQuest(
    title: 'Help someone without being asked',
    description: 'Proactively help someone with something today before they have to ask.',
    category: 'Social',
  ),

  // Plan quests
  FallbackQuest(
    title: 'Write tomorrow\'s to-do list tonight',
    description: 'Before bed, write a clear list of the top 3-5 things you want to accomplish tomorrow.',
    category: 'Plan',
  ),
  FallbackQuest(
    title: 'Set one goal for the week',
    description: 'Identify one meaningful goal for this week and write down your plan to achieve it.',
    category: 'Plan',
  ),
  FallbackQuest(
    title: 'Review your progress this month',
    description: 'Spend 15 minutes reviewing what you\'ve accomplished this month and what needs attention.',
    category: 'Plan',
  ),
  FallbackQuest(
    title: 'Block time for deep work',
    description: 'Schedule at least one 90-minute deep work block in your calendar for this week.',
    category: 'Plan',
  ),
  FallbackQuest(
    title: 'Identify your biggest priority',
    description: 'Write down the one task that, if completed today, would make everything else easier.',
    category: 'Plan',
  ),

  // Reflect quests
  FallbackQuest(
    title: 'Write about your proudest moment this week',
    description: 'Reflect on one thing you did this week that you\'re genuinely proud of and why.',
    category: 'Reflect',
  ),
  FallbackQuest(
    title: 'Identify a limiting belief',
    description: 'Write about one belief you hold that might be holding you back, and challenge it.',
    category: 'Reflect',
  ),
  FallbackQuest(
    title: 'What did you avoid today?',
    description: 'Honestly reflect on what you avoided doing today and why. No judgment — just awareness.',
    category: 'Reflect',
  ),
  FallbackQuest(
    title: 'Write a letter to your future self',
    description: 'Write a short letter to yourself 1 year from now. What do you hope they will have achieved?',
    category: 'Reflect',
  ),
  FallbackQuest(
    title: 'Describe your ideal day',
    description: 'Write a detailed description of what your perfect day would look like in 5 years.',
    category: 'Reflect',
  ),

  // Custom fallbacks (for Absolute rank)
  FallbackQuest(
    title: 'Define your personal mission',
    description: 'Write a one-sentence personal mission statement that captures your purpose.',
    category: 'Custom',
  ),
  FallbackQuest(
    title: 'Create something to share',
    description: 'Build, write, or design something you would be proud to share with the world.',
    category: 'Custom',
  ),
  FallbackQuest(
    title: 'Teach someone something you know',
    description: 'Find an opportunity to share your knowledge by teaching something to someone else.',
    category: 'Custom',
  ),
];

List<FallbackQuest> getFallbackQuestsForCategories(List<String> categories) {
  final result = <FallbackQuest>[];
  for (final category in categories) {
    if (category == 'Oath') continue; // Oath is handled separately
    final matching = kFallbackQuests
        .where((q) => q.category.toLowerCase() == category.toLowerCase())
        .toList();
    if (matching.isNotEmpty) {
      matching.shuffle();
      result.add(matching.first);
    }
  }
  return result;
}
