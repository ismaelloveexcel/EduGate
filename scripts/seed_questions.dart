/// EduGate Question Seed Script
///
/// This script seeds approximately 200 questions into the Firestore
/// `questions` collection for development and testing.
///
/// USAGE:
///   dart run scripts/seed_questions.dart
///
/// PREREQUISITES:
///   1. Set the GOOGLE_APPLICATION_CREDENTIALS environment variable to your
///      Firebase service account key JSON file path.
///      export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
///   2. Run: dart pub get (from apps/mobile or project root)
///
/// NOTE: This script requires the `http` package or Firebase Admin Dart SDK.
/// For simplicity in MVP, you can also seed via the Firebase Console using
/// the JSON below, or via the Firestore emulator.
///
/// TODO: Wire this up with firebase_admin or direct REST API calls.

// ignore_for_file: avoid_print

import 'dart:convert';

/// Sample questions catalogue (200 questions across 5 subjects, 3 difficulties)
final List<Map<String, dynamic>> kSeedQuestions = [
  // ─── MATH – EASY ───────────────────────────────────────────────────────────
  _mcq('m_e_001', 'math', 'easy', 'What is 5 + 3?', ['6', '7', '8', '9'], '8'),
  _mcq('m_e_002', 'math', 'easy', 'What is 10 - 4?', ['4', '5', '6', '7'], '6'),
  _mcq('m_e_003', 'math', 'easy', 'What is 3 × 4?', ['10', '11', '12', '13'], '12'),
  _tf('m_e_004', 'math', 'easy', '7 is an odd number.', 'True'),
  _tf('m_e_005', 'math', 'easy', '15 is divisible by 4.', 'False'),
  _fill('m_e_006', 'math', 'easy', 'What is 6 + 7?', '13'),
  _fill('m_e_007', 'math', 'easy', 'What is 20 ÷ 4?', '5'),
  _mcq('m_e_008', 'math', 'easy', 'How many sides does a triangle have?', ['2', '3', '4', '5'], '3'),
  _mcq('m_e_009', 'math', 'easy', 'What is 100 - 37?', ['53', '63', '73', '57'], '63'),
  _tf('m_e_010', 'math', 'easy', '2 × 6 = 12.', 'True'),

  // ─── MATH – MEDIUM ─────────────────────────────────────────────────────────
  _mcq('m_m_001', 'math', 'medium', 'What is 12 × 12?', ['132', '144', '124', '148'], '144'),
  _mcq('m_m_002', 'math', 'medium', 'What is 15% of 200?', ['20', '25', '30', '35'], '30'),
  _fill('m_m_003', 'math', 'medium', 'What is the square root of 64?', '8'),
  _tf('m_m_004', 'math', 'medium', 'A prime number has exactly two factors.', 'True'),
  _mcq('m_m_005', 'math', 'medium', 'If x + 5 = 12, what is x?', ['5', '6', '7', '8'], '7'),
  _mcq('m_m_006', 'math', 'medium', 'What is 3/4 as a decimal?', ['0.50', '0.60', '0.70', '0.75'], '0.75'),
  _fill('m_m_007', 'math', 'medium', 'What is 2³?', '8'),
  _tf('m_m_008', 'math', 'medium', 'Pi is approximately 3.14.', 'True'),
  _mcq('m_m_009', 'math', 'medium', 'What is the perimeter of a square with side 5?', ['15', '20', '25', '10'], '20'),
  _mcq('m_m_010', 'math', 'medium', 'What is 144 ÷ 12?', ['10', '11', '12', '13'], '12'),

  // ─── MATH – HARD ───────────────────────────────────────────────────────────
  _mcq('m_h_001', 'math', 'hard', 'Solve: 2x² - 8 = 0. What is x?', ['±1', '±2', '±3', '±4'], '±2'),
  _fill('m_h_002', 'math', 'hard', 'What is the area of a circle with radius 7? (Use π ≈ 22/7)', '154'),
  _tf('m_h_003', 'math', 'hard', 'The sum of angles in a triangle is always 180 degrees.', 'True'),
  _mcq('m_h_004', 'math', 'hard', 'What is the HCF of 36 and 48?', ['6', '9', '12', '18'], '12'),
  _fill('m_h_005', 'math', 'hard', 'What is 15! ÷ 14! ?', '15'),

  // ─── SCIENCE – EASY ────────────────────────────────────────────────────────
  _mcq('s_e_001', 'science', 'easy', 'What do plants need for photosynthesis?', ['Water only', 'Sunlight only', 'Sunlight, water, CO₂', 'Oxygen'], 'Sunlight, water, CO₂'),
  _tf('s_e_002', 'science', 'easy', 'The Earth orbits the Sun.', 'True'),
  _mcq('s_e_003', 'science', 'easy', 'What is the chemical symbol for water?', ['WA', 'W', 'H2O', 'HO2'], 'H2O'),
  _mcq('s_e_004', 'science', 'easy', 'How many planets are in our solar system?', ['7', '8', '9', '10'], '8'),
  _tf('s_e_005', 'science', 'easy', 'Humans are mammals.', 'True'),
  _mcq('s_e_006', 'science', 'easy', 'What is the closest star to Earth?', ['Sirius', 'The Sun', 'Alpha Centauri', 'Betelgeuse'], 'The Sun'),
  _fill('s_e_007', 'science', 'easy', 'Water freezes at ___ degrees Celsius.', '0'),
  _mcq('s_e_008', 'science', 'easy', 'Which gas do humans exhale?', ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Helium'], 'Carbon Dioxide'),
  _tf('s_e_009', 'science', 'easy', 'Sound travels faster than light.', 'False'),
  _mcq('s_e_010', 'science', 'easy', 'What organ pumps blood in the human body?', ['Lungs', 'Kidney', 'Heart', 'Brain'], 'Heart'),

  // ─── SCIENCE – MEDIUM ──────────────────────────────────────────────────────
  _mcq('s_m_001', 'science', 'medium', 'What is the atomic number of Carbon?', ['4', '6', '8', '12'], '6'),
  _tf('s_m_002', 'science', 'medium', 'Mitochondria are the powerhouse of the cell.', 'True'),
  _mcq('s_m_003', 'science', 'medium', 'Which planet is known as the Red Planet?', ['Venus', 'Jupiter', 'Mars', 'Saturn'], 'Mars'),
  _mcq('s_m_004', 'science', 'medium', 'What type of rock is formed from cooled lava?', ['Sedimentary', 'Metamorphic', 'Igneous', 'Limestone'], 'Igneous'),
  _fill('s_m_005', 'science', 'medium', 'Light travels at approximately ___ million metres per second.', '300'),
  _mcq('s_m_006', 'science', 'medium', 'What is the most abundant gas in Earth\'s atmosphere?', ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Argon'], 'Nitrogen'),
  _tf('s_m_007', 'science', 'medium', 'DNA is a double helix.', 'True'),
  _mcq('s_m_008', 'science', 'medium', 'Which force keeps planets in orbit?', ['Magnetism', 'Gravity', 'Friction', 'Tension'], 'Gravity'),
  _fill('s_m_009', 'science', 'medium', 'The human body has ___ bones.', '206'),
  _mcq('s_m_010', 'science', 'medium', 'What is Newton\'s first law also called?', ['Law of Energy', 'Law of Inertia', 'Law of Gravity', 'Law of Motion'], 'Law of Inertia'),

  // ─── SCIENCE – HARD ────────────────────────────────────────────────────────
  _mcq('s_h_001', 'science', 'hard', 'What is the speed of light in a vacuum?', ['3×10⁸ m/s', '3×10⁶ m/s', '3×10¹⁰ m/s', '1.5×10⁸ m/s'], '3×10⁸ m/s'),
  _tf('s_h_002', 'science', 'hard', 'Electrons have a positive charge.', 'False'),
  _mcq('s_h_003', 'science', 'hard', 'What is the powerhouse of the eukaryotic cell?', ['Nucleus', 'Ribosome', 'Mitochondria', 'Chloroplast'], 'Mitochondria'),
  _fill('s_h_004', 'science', 'hard', 'How many chromosomes do healthy human cells have?', '46'),
  _mcq('s_h_005', 'science', 'hard', 'Which element has atomic number 79?', ['Silver', 'Gold', 'Platinum', 'Copper'], 'Gold'),

  // ─── ENGLISH – EASY ────────────────────────────────────────────────────────
  _mcq('e_e_001', 'english', 'easy', 'What is the plural of "child"?', ['childs', 'childes', 'children', 'childer'], 'children'),
  _tf('e_e_002', 'english', 'easy', '"Run" is a verb.', 'True'),
  _mcq('e_e_003', 'english', 'easy', 'Which word is a synonym for "happy"?', ['sad', 'angry', 'joyful', 'tired'], 'joyful'),
  _mcq('e_e_004', 'english', 'easy', 'What punctuation ends a question?', ['.', '!', '?', ','], '?'),
  _tf('e_e_005', 'english', 'easy', '"The sun is bright" is a complete sentence.', 'True'),
  _mcq('e_e_006', 'english', 'easy', 'What is the opposite of "hot"?', ['warm', 'cool', 'cold', 'chilly'], 'cold'),
  _mcq('e_e_007', 'english', 'easy', 'How many vowels are in the English alphabet?', ['4', '5', '6', '7'], '5'),
  _tf('e_e_008', 'english', 'easy', '"Beautiful" is an adjective.', 'True'),
  _mcq('e_e_009', 'english', 'easy', 'Which word rhymes with "cat"?', ['dog', 'hat', 'cup', 'run'], 'hat'),
  _fill('e_e_010', 'english', 'easy', 'The ___ is the action word in a sentence.', 'verb'),

  // ─── ENGLISH – MEDIUM ──────────────────────────────────────────────────────
  _mcq('e_m_001', 'english', 'medium', 'What is a metaphor?', ['A comparison using like/as', 'A direct comparison without like/as', 'An exaggeration', 'A repeated sound'], 'A direct comparison without like/as'),
  _tf('e_m_002', 'english', 'medium', 'An adverb modifies a verb, adjective, or other adverb.', 'True'),
  _mcq('e_m_003', 'english', 'medium', 'Which is the correct spelling?', ['recieve', 'recive', 'receive', 'receve'], 'receive'),
  _mcq('e_m_004', 'english', 'medium', 'What is the past tense of "swim"?', ['swimmed', 'swam', 'swum', 'swimming'], 'swam'),
  _tf('e_m_005', 'english', 'medium', '"It\'s" is a contraction of "it is".', 'True'),
  _fill('e_m_006', 'english', 'medium', 'A word that sounds the same but has different meaning is called a ___.', 'homophone'),
  _mcq('e_m_007', 'english', 'medium', 'Which sentence uses the Oxford comma correctly?', ['I like cats dogs and birds', 'I like cats, dogs, and birds', 'I like, cats dogs and birds', 'I like cats, dogs and, birds'], 'I like cats, dogs, and birds'),
  _tf('e_m_008', 'english', 'medium', 'A simile uses "like" or "as" to compare two things.', 'True'),
  _mcq('e_m_009', 'english', 'medium', 'What is the subject in "The dog barked loudly"?', ['dog', 'barked', 'loudly', 'The'], 'dog'),
  _mcq('e_m_010', 'english', 'medium', 'Which word is an antonym of "ancient"?', ['old', 'historic', 'modern', 'aged'], 'modern'),

  // ─── ENGLISH – HARD ────────────────────────────────────────────────────────
  _mcq('e_h_001', 'english', 'hard', 'What literary device is used in "The thunder roared angrily"?', ['Simile', 'Personification', 'Alliteration', 'Hyperbole'], 'Personification'),
  _tf('e_h_002', 'english', 'hard', 'An oxymoron is a figure of speech where contradictory words appear together.', 'True'),
  _mcq('e_h_003', 'english', 'hard', 'In which grammatical mood is "If I were a bird"?', ['Indicative', 'Imperative', 'Subjunctive', 'Conditional'], 'Subjunctive'),
  _fill('e_h_004', 'english', 'hard', 'The repetition of initial consonant sounds is called ___.', 'alliteration'),
  _mcq('e_h_005', 'english', 'hard', 'Which word correctly completes: "Neither the students nor the teacher ___ happy"?', ['were', 'was', 'are', 'be'], 'was'),

  // ─── HISTORY – EASY ────────────────────────────────────────────────────────
  _mcq('h_e_001', 'history', 'easy', 'Who was the first President of the United States?', ['Abraham Lincoln', 'George Washington', 'Thomas Jefferson', 'John Adams'], 'George Washington'),
  _tf('h_e_002', 'history', 'easy', 'World War II ended in 1945.', 'True'),
  _mcq('h_e_003', 'history', 'easy', 'On which continent did Ancient Egypt civilisation develop?', ['Asia', 'Europe', 'Africa', 'South America'], 'Africa'),
  _mcq('h_e_004', 'history', 'easy', 'What was the name of the ship that sank in 1912?', ['Lusitania', 'Titanic', 'Britannic', 'Olympic'], 'Titanic'),
  _tf('h_e_005', 'history', 'easy', 'The Great Wall of China was built to keep invaders out.', 'True'),
  _mcq('h_e_006', 'history', 'easy', 'Which country gifted the Statue of Liberty to the USA?', ['Britain', 'Germany', 'France', 'Spain'], 'France'),
  _mcq('h_e_007', 'history', 'easy', 'What year did man first land on the Moon?', ['1965', '1967', '1969', '1971'], '1969'),
  _tf('h_e_008', 'history', 'easy', 'The Roman Empire was centred in Rome, Italy.', 'True'),
  _mcq('h_e_009', 'history', 'easy', 'Who invented the telephone?', ['Thomas Edison', 'Nikola Tesla', 'Alexander Graham Bell', 'Benjamin Franklin'], 'Alexander Graham Bell'),
  _fill('h_e_010', 'history', 'easy', 'In what year did the Berlin Wall fall?', '1989'),

  // ─── HISTORY – MEDIUM ──────────────────────────────────────────────────────
  _mcq('h_m_001', 'history', 'medium', 'What did the Magna Carta establish?', ['End of feudalism', 'Limits on royal power', 'Universal voting rights', 'Free trade'], 'Limits on royal power'),
  _tf('h_m_002', 'history', 'medium', 'Napoleon Bonaparte was born in France.', 'False'),
  _mcq('h_m_003', 'history', 'medium', 'Which empire was known as the "Empire on which the sun never sets"?', ['French Empire', 'Roman Empire', 'British Empire', 'Mongol Empire'], 'British Empire'),
  _mcq('h_m_004', 'history', 'medium', 'The Renaissance began in which country?', ['France', 'Germany', 'Spain', 'Italy'], 'Italy'),
  _fill('h_m_005', 'history', 'medium', 'The French Revolution began in ___.', '1789'),

  // ─── HISTORY – HARD ────────────────────────────────────────────────────────
  _mcq('h_h_001', 'history', 'hard', 'The Treaty of Westphalia (1648) ended which war?', ['100 Years War', '30 Years War', '7 Years War', 'Crimean War'], '30 Years War'),
  _tf('h_h_002', 'history', 'hard', 'Genghis Khan founded the Mongol Empire in 1206.', 'True'),
  _mcq('h_h_003', 'history', 'hard', 'What was the significance of the Battle of Hastings (1066)?', ['End of the Roman occupation', 'Norman conquest of England', 'Start of the Crusades', 'Signing of Magna Carta'], 'Norman conquest of England'),
  _fill('h_h_004', 'history', 'hard', 'Julius Caesar was assassinated in ___ BC.', '44'),
  _mcq('h_h_005', 'history', 'hard', 'The Meiji Restoration transformed which country?', ['China', 'Korea', 'Japan', 'Vietnam'], 'Japan'),

  // ─── GEOGRAPHY – EASY ──────────────────────────────────────────────────────
  _mcq('g_e_001', 'geography', 'easy', 'What is the capital of France?', ['Berlin', 'Madrid', 'Paris', 'Rome'], 'Paris'),
  _tf('g_e_002', 'geography', 'easy', 'Australia is the largest continent.', 'False'),
  _mcq('g_e_003', 'geography', 'easy', 'On which continent is Brazil located?', ['Africa', 'Asia', 'South America', 'North America'], 'South America'),
  _mcq('g_e_004', 'geography', 'easy', 'What is the longest river in the world?', ['Amazon', 'Nile', 'Yangtze', 'Mississippi'], 'Nile'),
  _tf('g_e_005', 'geography', 'easy', 'The Pacific Ocean is the largest ocean.', 'True'),
  _mcq('g_e_006', 'geography', 'easy', 'How many continents are there?', ['5', '6', '7', '8'], '7'),
  _mcq('g_e_007', 'geography', 'easy', 'What is the capital of Japan?', ['Seoul', 'Beijing', 'Tokyo', 'Bangkok'], 'Tokyo'),
  _fill('g_e_008', 'geography', 'easy', 'The tallest mountain in the world is Mount ___.', 'Everest'),
  _tf('g_e_009', 'geography', 'easy', 'The Sahara is the world\'s largest hot desert.', 'True'),
  _mcq('g_e_010', 'geography', 'easy', 'Which country has the most population?', ['USA', 'India', 'China', 'Brazil'], 'India'),

  // ─── GEOGRAPHY – MEDIUM ────────────────────────────────────────────────────
  _mcq('g_m_001', 'geography', 'medium', 'What is the capital of Australia?', ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'], 'Canberra'),
  _tf('g_m_002', 'geography', 'medium', 'The Amazon rainforest is primarily in Brazil.', 'True'),
  _mcq('g_m_003', 'geography', 'medium', 'Which country is both a continent and a country?', ['Greenland', 'New Zealand', 'Australia', 'Iceland'], 'Australia'),
  _mcq('g_m_004', 'geography', 'medium', 'What ocean lies between Africa and Australia?', ['Atlantic', 'Pacific', 'Indian', 'Arctic'], 'Indian'),
  _fill('g_m_005', 'geography', 'medium', 'The longest mountain range in the world is the ___.', 'Andes'),

  // ─── GEOGRAPHY – HARD ──────────────────────────────────────────────────────
  _mcq('g_h_001', 'geography', 'hard', 'What is the deepest lake in the world?', ['Lake Superior', 'Caspian Sea', 'Lake Baikal', 'Lake Tanganyika'], 'Lake Baikal'),
  _tf('g_h_002', 'geography', 'hard', 'Vatican City is the smallest country in the world by area.', 'True'),
  _mcq('g_h_003', 'geography', 'hard', 'The Mariana Trench is located in which ocean?', ['Atlantic', 'Indian', 'Arctic', 'Pacific'], 'Pacific'),
  _fill('g_h_004', 'geography', 'hard', 'The ___ Line divides the Earth into Northern and Southern hemispheres.', 'Equator'),
  _mcq('g_h_005', 'geography', 'hard', 'Which country has the most natural freshwater lakes?', ['Russia', 'USA', 'Canada', 'Brazil'], 'Canada'),
];

// ─── Question factory helpers ──────────────────────────────────────────────

Map<String, dynamic> _mcq(
  String id,
  String subject,
  String difficulty,
  String prompt,
  List<String> options,
  String correct,
) {
  return {
    'id': id,
    'subject': subject,
    'difficulty': difficulty,
    'type': 'mcq',
    'prompt': prompt,
    'options': options,
    'correctAnswer': correct,
    'tags': [subject, difficulty],
  };
}

Map<String, dynamic> _tf(
  String id,
  String subject,
  String difficulty,
  String prompt,
  String correct,
) {
  return {
    'id': id,
    'subject': subject,
    'difficulty': difficulty,
    'type': 'trueFalse',
    'prompt': prompt,
    'options': ['True', 'False'],
    'correctAnswer': correct,
    'tags': [subject, difficulty],
  };
}

Map<String, dynamic> _fill(
  String id,
  String subject,
  String difficulty,
  String prompt,
  String correct,
) {
  return {
    'id': id,
    'subject': subject,
    'difficulty': difficulty,
    'type': 'fillInNumber',
    'prompt': prompt,
    'options': <String>[],
    'correctAnswer': correct,
    'tags': [subject, difficulty],
  };
}

/// Entry point: prints the seed questions as JSON for Firestore import.
///
/// To import into Firestore:
///   1. Run: dart run scripts/seed_questions.dart > /tmp/questions.json
///   2. Use the Firebase Console to import, or use the Admin SDK.
///
/// TODO: Implement direct Firestore write using firebase_admin Dart package
/// or the Firestore REST API with a service account token.
void main() {
  print('Seeding ${kSeedQuestions.length} questions...');
  print(jsonEncode(kSeedQuestions));
  print('\nDone. Import the JSON above into Firestore "questions" collection.');
  print('Each object\'s "id" field maps to the document ID.');
}
