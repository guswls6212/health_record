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
  Exercise? _selectedExercise; // nullable로 변경
  List<WorkoutSet> _sets = [];
  bool _showSearchField = true;
  bool _showSetBtnField = false;
  final FocusNode _exerciseFocusNode = FocusNode(); // FocusNode 추가

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // FocusNode 초기화 및 리스너 추가
    _exerciseFocusNode.addListener(() {
      if (!_exerciseFocusNode.hasFocus) {
        // TypeAheadFormField의 포커스를 잃었을 때
        setState(() {
          _showSearchField = false; // 검색 필드 숨김
        });
      }
    });
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _exerciseFocusNode.dispose();
    super.dispose();
  }

  void _addSet() {
    FocusScope.of(context).unfocus(); // TextFormField의 포커스 해제

    setState(() {
      _sets.add(WorkoutSet());
    });
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  // 운동 변경 확인 다이얼로그 표시 함수
  Future<bool> _showExerciseChangeConfirmationDialog(
      BuildContext context) async {
    if (_selectedExercise == null ||
        _sets.every((set) => set.weight == null && set.reps == null)) {
      // 모든 세트의 무게와 횟수가 null이면 확인 없이 변경
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('경고'),
              content: Text('입력하신 내용이 초기화됩니다. 진행하시겠습니까?',
                  style: TextStyle(color: Colors.black)),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // false 반환 (취소)
                  },
                ),
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // true 반환 (확인)
                  },
                ),
              ],
            );
          },
        ) ??
        false; // 다이얼로그가 닫히면 false 반환 (취소)
  }

  @override
  Widget build(BuildContext context) {
    final exerciseModel = Provider.of<ExerciseModel>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('운동 기록 추가'),
      ),
      body: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Form(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
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
                              '${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        flex: 3,
                        child: _showSearchField
                            ? TypeAheadFormField<Exercise>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  focusNode: _exerciseFocusNode,
                                  decoration: InputDecoration(
                                    labelText: '운동 선택',
                                    labelStyle:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
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
                                onSuggestionSelected: (suggestion) async {
                                  if (await _showExerciseChangeConfirmationDialog(
                                      context)) {
                                    // 확인을 누르면 운동 변경
                                    setState(() {
                                      _selectedExercise = suggestion;
                                      // 선택된 운동 표시 및 돋보기 아이콘 표시
                                      _showSearchField = false;
                                      // 세트입력란, 세트추가, 저장 버튼 표시
                                      _showSetBtnField = true;
                                      // 세트입력란 값 초기화
                                      _formKey.currentState!.reset();
                                      // 1세트 추가
                                      _sets = [WorkoutSet()]; // 1세트만 남기고 초기화
                                    });
                                  }
                                  // 취소를 누르면 아무 동작 안함
                                },
                              )
                            : Row(
                                children: [
                                  Spacer(),
                                  Text(_selectedExercise?.name ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall), // _selectedExercise가 null일 경우 빈 문자열 표시
                                  Spacer(),
                                  IconButton(
                                      icon: const Icon(Icons.search,
                                          color: Colors.white),
                                      onPressed: () async {
                                        // 빌드 완료 후 setState() 호출
                                        // 확인을 누르면 운동 변경
                                        setState(() {
                                          _showSearchField = true;
                                          _exerciseFocusNode.requestFocus();
                                          // _sets = [WorkoutSet()];
                                        });
                                        // 취소를 누르면 아무 동작 안함
                                      }),
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
                  // 운동선택이후에 버튼 나오게 조건식추가
                  if (_showSetBtnField) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        // Theme.of(context).primaryColor,
                      ),
                      onPressed: _addSet,
                      child: Text('세트 추가',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedExercise == null) {
                            // 운동을 선택하지 않은 경우 경고 메시지 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('운동을 선택하세요.')),
                            );
                            _exerciseFocusNode.requestFocus(); // 운동 선택란에 포커스 이동
                            return;
                          }

                          final newRecord = WorkoutRecord(
                            id: const Uuid().v4(),
                            exerciseName: _selectedExercise!
                                .name, // _selectedExercise가 null이 아님을 보장
                            date: _selectedDate,
                            sets: _sets,
                          );
                          Provider.of<WorkoutRecordModel>(context,
                                  listen: false)
                              .addWorkoutRecord(newRecord);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('저장',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... _buildSetWidget, _calculate1RM 함수는 이전 코드와 동일

  Widget _buildSetWidget(int index) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: TextFormField(
            style: Theme.of(context).textTheme.displaySmall,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '무게 (kg)',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              // enabledBorder: const UnderlineInputBorder(
              //   borderSide: BorderSide(color: Color(0xFF4CAF50)),
              // ),
              errorStyle: const TextStyle(color: Colors.yellow),
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].set = index + 1;
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
            style: Theme.of(context).textTheme.displaySmall,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '횟수',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              // enabledBorder: const UnderlineInputBorder(
              //   borderSide: BorderSide(color: Color(0xFF4CAF50)),
              // ),
              errorStyle: const TextStyle(color: Colors.yellow),
            ),
            onChanged: (value) {
              setState(() {
                _sets[index].set = index + 1;
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
                Expanded(
                  child: Text(
                    _sets[index].oneRM != null
                        ? '${_sets[index].oneRM!.toStringAsFixed(1)} kg'
                        : '-- kg',
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(
                      Icons.info,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('1RM이란?'),
                          content: const Text(
                            '1RM은 1회 최대 반복 가능 무게를 의미합니다.\n\n'
                            '이 값은 O\'Conner 공식 (1RM = weight * (1 + 0.025 * reps)) 을 사용하여 계산된 예상 값이며,\n'
                            '실제 1RM과는 다를 수 있습니다.',
                            style: TextStyle(color: Colors.black),
                          ),
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
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.remove_circle,
            color: Colors.red,
          ),
          onPressed: () => _removeSet(index),
        ),
      ],
    );
  }

  void _calculate1RM(int index) {
    double? weight = _sets[index].weight;
    int? reps = _sets[index].reps;
    if (weight != null && reps != null && reps > 0) {
      double oneRM = weight * (1 + 0.025 * reps); // O'Conner 공식 적용
      _sets[index].oneRM = oneRM;
    } else {
      _sets[index].oneRM = null;
    }
  }
}
