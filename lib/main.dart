import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'hijri_date_picker.dart';

enum CalendarType { gregorian, hijri }

class CalendarSelector extends StatefulWidget {
  const CalendarSelector({super.key});

  @override
  State<CalendarSelector> createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  CalendarType _selectedCalendarType = CalendarType.gregorian;
  DateTime _selectedGregorianDate = DateTime.now();
  HijriCalendarConfig _selectedHijriDate = HijriCalendarConfig.now();

  String _formatGregorianDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatHijriDate(HijriCalendarConfig date) {
    final monthName = hijriMonths[date.hMonth - 1];
    return '${date.hDay} $monthName ${date.hYear}';
  }

  Future<void> _selectDate() async {
    if (_selectedCalendarType == CalendarType.gregorian) {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedGregorianDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          _selectedGregorianDate = picked;
          _selectedHijriDate = HijriCalendarConfig.bridgeFromDate(picked);
        });
      }
    } else {
      final HijriCalendarConfig? picked = await HijriDatePicker.show(
        context: context,
        initialDate: _selectedHijriDate,
      );
      if (picked != null) {
        setState(() {
          _selectedHijriDate = picked;
          _selectedGregorianDate = HijriCalendarConfig().hijriToGregorian(
            picked.hYear,
            picked.hMonth,
            picked.hDay,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Calendar Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<CalendarType>(
            segments: const [
              ButtonSegment<CalendarType>(
                value: CalendarType.gregorian,
                label: Text('Gregorian'),
                icon: Icon(Icons.calendar_today),
              ),
              ButtonSegment<CalendarType>(
                value: CalendarType.hijri,
                label: Text('Hijri'),
                icon: Icon(Icons.calendar_month),
              ),
            ],
            selected: {_selectedCalendarType},
            onSelectionChanged: (Set<CalendarType> newSelection) {
              setState(() {
                _selectedCalendarType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Select Date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCalendarType == CalendarType.gregorian
                        ? _formatGregorianDate(_selectedGregorianDate)
                        : _formatHijriDate(_selectedHijriDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gregorian: ${_formatGregorianDate(_selectedGregorianDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hijri: ${_formatHijriDate(HijriCalendarConfig.bridgeFromDate(_selectedGregorianDate))}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Selector Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar Selector'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const CalendarSelector(),
      ),
    );
  }
}
