import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

const List<String> hijriMonths = [
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Awwal',
  'Jumada al-Thani',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  'Dhu al-Qidah',
  'Dhu al-Hijjah',
];

const List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const int minHijriYear = 1356;
const int maxHijriYear = 1500;

class HijriDatePicker extends StatefulWidget {
  final HijriCalendar initialDate;
  final Function(HijriCalendar) onDateSelected;

  const HijriDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  static Future<HijriCalendar?> show({
    required BuildContext context,
    HijriCalendar? initialDate,
  }) async {
    return await showDialog<HijriCalendar>(
      context: context,
      builder: (BuildContext context) {
        return HijriDatePicker(
          initialDate: initialDate ?? HijriCalendar.now(),
          onDateSelected: (date) {},
        );
      },
    );
  }

  @override
  State<HijriDatePicker> createState() => _HijriDatePickerState();
}

class _HijriDatePickerState extends State<HijriDatePicker> {
  late HijriCalendar _selectedDate;
  late int _selectedYear;
  late int _selectedMonth;
  late int _firstDayOfWeek;
  bool _showYearPicker = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedYear = _selectedDate.hYear;
    _selectedMonth = _selectedDate.hMonth;
    _updateFirstDayOfWeek();
  }

  void _updateFirstDayOfWeek() {
    final firstGreg = HijriCalendar().hijriToGregorian(_selectedYear, _selectedMonth, 1);
    _firstDayOfWeek = firstGreg.weekday % 7;
  }

  void _previousMonth() {
    if (_selectedYear <= minHijriYear && _selectedMonth == 1) return;
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _updateFirstDayOfWeek();
    });
  }

  void _nextMonth() {
    if (_selectedYear >= maxHijriYear && _selectedMonth == 12) return;
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
      _updateFirstDayOfWeek();
    });
  }

  void _toggleYearPicker() {
    setState(() {
      _showYearPicker = !_showYearPicker;
    });
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _showYearPicker = false;
      _updateFirstDayOfWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth();
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: SizedBox(
        width: screenSize.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showYearPicker)
                _buildYearPicker(context, colorScheme)
              else
                _buildCalendarView(context, colorScheme, daysInMonth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearPicker(BuildContext context, ColorScheme colorScheme) {
    final currentYear = _selectedYear;
    final startYear = (currentYear - 20 < minHijriYear) ? minHijriYear : currentYear - 20;
    final canGoPrevious = startYear > minHijriYear;
    final canGoNext = currentYear + 20 < maxHijriYear;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoPrevious ? () => setState(() => _selectedYear -= 41) : null,
            ),
            Text(
              '$startYear - ${startYear + 40}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext ? () => setState(() => _selectedYear += 41) : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 318,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.6,
            ),
            itemCount: 41,
            itemBuilder: (context, index) {
              final year = startYear + index;
              if (year < minHijriYear || year > maxHijriYear) {
                return const SizedBox();
              }
              final isSelected = year == _selectedYear;

              return InkWell(
                onTap: () => _selectYear(year),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$year',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _toggleYearPicker,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _toggleYearPicker,
              child: const Text('OK'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarView(BuildContext context, ColorScheme colorScheme, int daysInMonth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
            ),
            GestureDetector(
              onTap: _toggleYearPicker,
              child: Row(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hijriMonths[_selectedMonth - 1]} $_selectedYear',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => SizedBox(
            width: 36,
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 290,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: _firstDayOfWeek + daysInMonth,
            itemBuilder: (context, index) {
              if (index < _firstDayOfWeek) {
                return const SizedBox();
              }
              final day = index - _firstDayOfWeek + 1;
              final isSelected = day == _selectedDate.hDay &&
                  _selectedMonth == _selectedDate.hMonth &&
                  _selectedYear == _selectedDate.hYear;
              final isToday = _isToday(day);

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = HijriCalendar()
                      ..hYear = _selectedYear
                      ..hMonth = _selectedMonth
                      ..hDay = day;
                  });
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: isSelected || isToday ? FontWeight.bold : null,
                        decoration: isToday && !isSelected
                            ? TextDecoration.underline
                            : null,
                        decorationColor: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                widget.onDateSelected(_selectedDate);
                Navigator.of(context).pop(_selectedDate);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ],
    );
  }

  bool _isToday(int day) {
    final today = HijriCalendar.now();
    return day == today.hDay &&
        _selectedMonth == today.hMonth &&
        _selectedYear == today.hYear;
  }

  int _getDaysInMonth() {
    final temp = HijriCalendar()
      ..hYear = _selectedYear
      ..hMonth = _selectedMonth
      ..hDay = 1;
    return temp.getDaysInMonth(_selectedYear, _selectedMonth);
  }
}
