import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../model/workout_record.dart';
import '../model/exercise.dart';
import '../model/workout_set.dart';

class AddWorkoutRecordScreen extends StatefulWidget {
  const AddWorkoutRecordScreen({Key? key}) : super(key: key);

  @override
  _AddWorkoutRecordScreenState createState() => _AddWorkoutRecordScreenState();
}

class _AddWorkoutRecordScreenState extends State<AddWorkoutRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late Exercise _selectedExercise;
  List<WorkoutSet> _sets = [];
  bool _showSearchField = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedExercise =
        Provider.of<ExerciseModel>(context, listen: false).exercises.first;
    _sets.add(WorkoutSet());
  }

  void _addSet() {
    setState(() {
      _sets.add(WorkoutSet());
    });
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseModel = Provider.of<ExerciseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록 추가'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: Text(
                            '${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 3,
                      child: _showSearchField
                          ? TypeAheadFormField<Exercise>(
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(labelText: '운동 선택'),
                              ),
                              suggestionsCallback: (pattern) {
                                return exerciseModel.exercises.where(
                                    (exercise) => exercise.name
                                        .toLowerCase()
                                        .contains(pattern.toLowerCase()));
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion.name),
                                );
                              },
                              transitionBuilder:
                                  (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                setState(() {
                                  _selectedExercise = suggestion;
                                  _showSearchField = false;
                                });
                              },
                            )
                          : Row(
                              children: [
                                Spacer(),
                                Text(_selectedExercise.name),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    setState(() {
                                      _showSearchField = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sets.length,
                  itemBuilder: (context, index) {
                    return _buildSetWidget(index);
                  },
                ),
                ElevatedButton(
                  onPressed: _addSet,
                  child: const Text('세트 추가'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newRecord = WorkoutRecord(
                        id: const Uuid().v4(),
                        exercise: _selectedExercise,
                        date: _selectedDate,
                        sets: _sets,
                      );
                      Provider.of<WorkoutRecordModel>(context, listen: false)
                          .addWorkoutRecord(newRecord);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetWidget(int index) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('${index + 1}'),
        ),
        Expanded(
          child: TextFormField(
            initialValue: _sets[index].weight?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '무게 (kg)',
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].weight = double.tryParse(value);
                _calculate1RM(index);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '무게를 입력하세요.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextFormField(
            initialValue: _sets[index].reps?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '횟수',
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].reps = int.tryParse(value);
                _calculate1RM(index);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '횟수를 입력하세요.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _sets[index].oneRM != null
                      ? '${_sets[index].oneRM!.toStringAsFixed(1)} kg'
                      : '-- kg',
                ),
                IconButton(
                  icon: const Icon(Icons.info, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('1RM이란?'),
                        content: const Text('1RM은 1회 최대 반복 가능 무게를 의미합니다.\n\n'
                            '이 값은 Brzycki 공식을 사용하여 계산된 예상 값이며,\n'
                            '실제 1RM과는 다를 수 있습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('닫기'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle),
          onPressed: () => _removeSet(index),
        ),
      ],
    );
  }

  void _calculate1RM(int index) {
    double? weight = _sets[index].weight;
    int? reps = _sets[index].reps;
    if (weight != null && reps != null && reps > 0) {
      double oneRM = weight / (1.0278 - 0.0278 * reps);
      _sets[index].oneRM = oneRM;
    } else {
      _sets[index].oneRM = null;
    }
  }
}
