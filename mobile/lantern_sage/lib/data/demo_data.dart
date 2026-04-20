import '../models/ask_question.dart';
import '../models/important_date_guidance.dart';
import '../models/today_read.dart';

const demoToday = TodayRead(
  dateLabel: 'April 10, 2026 - Friday',
  lunarLabel: 'Lunar March 3  Clear and Bright',
  title: 'Move where the day opens.',
  practicalTip: 'Clear one visible surface near the entrance before noon.',
  goodFor: [
    'Short errands',
    'Light planning',
    'Casual meetings',
  ],
  avoid: [
    'Heavy commitments',
    'Late disputes',
    'Cluttered starts',
  ],
  bestTime: '9:00 AM - 11:00 AM',
  avoidTime: '7:00 PM - 9:00 PM',
  compass: [
    CompassItem(direction: 'N', label: 'Wealth', quality: 'open'),
    CompassItem(direction: 'S', label: 'Blessing', quality: 'steady'),
    CompassItem(direction: 'E', label: 'Movement', quality: 'light'),
    CompassItem(direction: 'W', label: 'Rest', quality: 'quiet'),
  ],
);

const askQuestions = [
  AskQuestion(
    type: 0,
    text: 'Is this a good time to go out?',
    hint: 'Movement, errands, light plans',
  ),
  AskQuestion(
    type: 1,
    text: 'Is this a good time to meet someone?',
    hint: 'Social contact, casual meetings',
  ),
  AskQuestion(
    type: 2,
    text: 'Is this a good time to discuss important matters?',
    hint: 'Conversations that need weight',
  ),
  AskQuestion(
    type: 3,
    text: 'What should I adjust first at home today?',
    hint: 'Light home adjustment guidance',
  ),
];

const demoAnswer = AskAnswer(
  shortAnswer: 'Proceed gently.',
  recommendedTime: 'Late morning',
  caution: 'Keep the plan simple and leave room to pause.',
  reason: 'The day favors small movement and clear surroundings over dense decisions.',
);

const demoImportantDate = ImportantDateGuidance(
  targetDate: '2026-05-08',
  eventType: 'meeting',
  city: 'Shanghai',
  timezone: 'Asia/Shanghai',
  lunarDate: 'Lunar March 22',
  solarTerm: '',
  dayGanzhi: 'Jiwei',
  dayQuality: 'Balanced',
  summary: 'Useful for calm conversation with a short agenda.',
  bestWindow: '9:00 AM - 11:00 AM',
  cautionWindow: '7:00 PM - 9:00 PM',
  goodFor: ['Light planning', 'Casual meetings'],
  avoid: ['Rushing', 'Heavy changes'],
  practicalTip: 'Keep the first conversation practical and save sensitive topics for later.',
);
