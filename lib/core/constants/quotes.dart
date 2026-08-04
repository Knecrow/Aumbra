import 'dart:math';

class DailyQuote {
  final String text;
  final String author;

  const DailyQuote({required this.text, required this.author});
}

const List<DailyQuote> kQuotes = [
  DailyQuote(text: "Your only opponent is the person you were yesterday.", author: "System"),
  DailyQuote(text: "The silence of morning is the system's loading screen.", author: "System"),
  DailyQuote(text: "You are the protagonist of a story only you can finish.", author: "System"),
  DailyQuote(text: "To transcend, you must first accept the ground beneath you.", author: "System"),
  DailyQuote(text: "Awakening begins the moment excuses end.", author: "System"),
  DailyQuote(text: "Some doors open only when you stop knocking.", author: "System"),
  DailyQuote(text: "You are not lost. You are walking a path less traveled.", author: "System"),
  DailyQuote(text: "The stars do not ask permission to burn.", author: "System"),
  DailyQuote(text: "Growth is invisible until you look back.", author: "System"),
  DailyQuote(text: "Leveling up means leaving old versions of yourself behind.", author: "System"),
  DailyQuote(text: "Solitude is where the system quietly upgrades you.", author: "System"),
  DailyQuote(text: "Stillness is not empty. It is full of potential.", author: "System"),
  DailyQuote(text: "The system does not ask if you are ready. It asks if you are willing.", author: "System"),
  DailyQuote(text: "You are not late. You are exactly on your own timeline.", author: "System"),
  DailyQuote(text: "The moon does not compete with the sun. It simply glows.", author: "System"),
  DailyQuote(text: "Loneliness is just the echo of the self you are leaving behind.", author: "System"),
  DailyQuote(text: "Repetition is the crucible where mastery is forged.", author: "System"),
  DailyQuote(text: "Every step forward is a shadow of the self you used to be.", author: "System"),
  DailyQuote(text: "You are the architect of your own renaissance.", author: "System"),
  DailyQuote(text: "Discipline is the art of becoming the person you dreamt of.", author: "System"),
  DailyQuote(text: "The system does not judge your past. It watches your next move.", author: "System"),
  DailyQuote(text: "Some people are waiting for a sign. Others become it.", author: "System"),
  DailyQuote(text: "The only reward for completing a level is the next one.", author: "System"),
  DailyQuote(text: "Your future self is watching you right now. Impress them.", author: "System"),
  DailyQuote(text: "The quiet ones are leveling up in the dark.", author: "System"),
  DailyQuote(text: "If you want the dawn, you must survive the night.", author: "System"),
  DailyQuote(text: "One step outside your comfort zone is infinite steps forward.", author: "System"),
  DailyQuote(text: "The grind is silent. The results are loud.", author: "System"),
  DailyQuote(text: "You don't need to see the whole staircase. Just the next step.", author: "System"),
  DailyQuote(text: "Everything you want is on the other side of discipline.", author: "System"),
  DailyQuote(text: "Your mental palace becomes a fortress brick by brick.", author: "System"),
  DailyQuote(text: "Healing is just walking backward into the light.", author: "System"),
  DailyQuote(text: "If you crave change, you must first endure the process.", author: "System"),
  DailyQuote(text: "Limits are just illusions waiting to be shattered.", author: "System"),
  DailyQuote(text: "The winter of effort births the spring of mastery.", author: "System"),
  DailyQuote(text: "The path to greatness is paved with quiet mornings.", author: "System"),
  DailyQuote(text: "Consistency is the secret magic of the universe.", author: "System"),
  DailyQuote(text: "Your potential is a seed that only your efforts can water.", author: "System"),
  DailyQuote(text: "Every great journey begins with a single, awkward step.", author: "System"),
  DailyQuote(text: "The strongest characters are forged in the coldest fires.", author: "System"),
  DailyQuote(text: "Doubt is the only wall you cannot break with force.", author: "System"),
  DailyQuote(text: "To know yourself is the first and final level.", author: "System"),
  DailyQuote(text: "The system rewards persistence, not perfection.", author: "System"),
  DailyQuote(text: "Your shadow self is not your enemy. It is your teacher.", author: "System"),
  DailyQuote(text: "Do not fear the climb. Fear staying where you are.", author: "System"),
  DailyQuote(text: "The sun does not rush to rise. Yet it always does.", author: "System"),
  DailyQuote(text: "If you don't break your limits, your limits will break you.", author: "System"),
  DailyQuote(text: "Mastery is not a destination. It is a direction.", author: "System"),
  DailyQuote(text: "Your energy is currency. Spend it only on what grows you.", author: "System"),
  DailyQuote(text: "The day you stop improving is the day you start fading.", author: "System"),
  DailyQuote(text: "You are the writer, the editor, and the protagonist of your story.", author: "System"),
  DailyQuote(text: "Momentum is silent, until it becomes unstoppable.", author: "System"),
  DailyQuote(text: "The only guarantee in the system is effort.", author: "System"),
  DailyQuote(text: "Let the pain remind you that you are still alive.", author: "System"),
  DailyQuote(text: "Don't wait for a sign. The system is your sign.", author: "System"),
  DailyQuote(text: "A tear in the canvas is just an opportunity to paint a new sky.", author: "System"),
  DailyQuote(text: "Rest is part of the grind, not the end of it.", author: "System"),
  DailyQuote(text: "You are alone in the grind, but never alone in the result.", author: "System"),
  DailyQuote(text: "The horizon is not a limit. It is an invitation.", author: "System"),
  DailyQuote(text: "The only thing you are destined to become is the effort you put in.", author: "System"),
  DailyQuote(text: "Shadow and light both exist within you. Master both.", author: "System"),
];

DailyQuote getDailyQuote() {
  final now = DateTime.now();
  // Seed based on year + month + day so same quote appears all day
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final rng = Random(seed);
  final index = rng.nextInt(kQuotes.length);
  return kQuotes[index];
}
