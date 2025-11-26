import 'package:artrit/api/api_questionnaire.dart';
import 'package:artrit/widgets/checkbox_group_widget.dart';
import 'package:flutter/material.dart';
import '../data/data_questionnaire.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/animated_color_scale_widget.dart';
import '../widget_another/form_header_widget.dart';
import '../widget_another/label_join_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text.dart';
import '../widgets/radio_group_widget.dart';
import '../widgets/show_message.dart';

class PageQuestionnaireEdit extends StatefulWidget {
  final String title;
  final DataQuestionnaire? thisData;
  final bool isEditForm;
  final bool isAnonymous;

  const PageQuestionnaireEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
    required this.isAnonymous,
  });

  @override
  State<PageQuestionnaireEdit> createState() => PageQuestionnaireEditState();
}

class QuestionsItem {
  final String id;
  final String questionCategory;
  final String questionStart;
  final String question;
  final String answerType;
  final List<String>? answersForRadio;
  final List<AnswersForCheck>? answersForCheck;
  int? answerForRadio;

  QuestionsItem({
    required this.id,
    required this.questionCategory,
    required this.questionStart,
    required this.question,
    required this.answerType,
    this.answersForRadio,
    this.answersForCheck,
    required this.answerForRadio,
  });
}

class AnswersForCheck {
  final String idAnswer;
  String answer;
  bool isSelect;

  AnswersForCheck({
    required this.idAnswer,
    required this.answer,
    this.isSelect = false,
  });
}

class PageQuestionnaireEditState extends State<PageQuestionnaireEdit> {
  /// API
  final ApiQuestionnaire _api = ApiQuestionnaire();

  /// Параметры
  late int _role;
  late String _patientsId;
  late String _recordId;
  DateTime _date = getMoscowDateTime();
  int? _creationDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _other = '';
  late DataQuestionnaire _thisData;
  late List<QuestionsItem> _listQuestions = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  late List<GlobalKey<FormState>> _formKeys;
  final GlobalKey<AnimatedColorScaleWidgetState> _keyPain =
      GlobalKey<AnimatedColorScaleWidgetState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.thisData != null) {
      _thisData = widget.thisData!;
    }
    _loadData();
    _formKeys = List.generate(36, (index) => GlobalKey<FormState>());
  }

  void _loadData() async {
    if (!widget.isAnonymous) {
      _role = await getUserRole();
      _patientsId = await readSecureData(SecureKey.patientsId);
    } else {
      _role = Roles.anonymous;
    }
    setState(() {
      if (widget.isEditForm) {
        _recordId = _thisData.id!;
        _date = _thisData.questdate;
        _creationDate = _thisData.creationDate;
        _other = _thisData.otherDevices;
      }
      _listQuestions = [
        QuestionsItem(
          id: 'q1',
          questionCategory: _labeldressAndToilet,
          questionStart: _questionStart,
          question:
              'Одеться, включая завязывание шнурков и застёгивание пуговиц?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q1 : null,
        ),
        QuestionsItem(
          id: 'q2',
          questionCategory: _labeldressAndToilet,
          questionStart: _questionStart,
          question: 'Вымыть шампунем свои волосы?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q2 : null,
        ),
        QuestionsItem(
          id: 'q3',
          questionCategory: _labeldressAndToilet,
          questionStart: _questionStart,
          question: 'Снять носки?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q3 : null,
        ),
        QuestionsItem(
          id: 'q4',
          questionCategory: _labeldressAndToilet,
          questionStart: _questionStart,
          question: 'Подстричь ногти?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q4 : null,
        ),
        QuestionsItem(
          id: 'q5',
          questionCategory: _labeWakeUp,
          questionStart: _questionStart,
          question: 'Встать с низкого кресла или пола?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q5 : null,
        ),
        QuestionsItem(
          id: 'q6',
          questionCategory: _labeWakeUp,
          questionStart: _questionStart,
          question: 'Лечь и встать с постели либо встать в детской кроватке?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q6 : null,
        ),
        QuestionsItem(
          id: 'q7',
          questionCategory: _labeEat,
          questionStart: _questionStart,
          question: 'Порезать кусок мяса?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q7 : null,
        ),
        QuestionsItem(
          id: 'q8',
          questionCategory: _labeEat,
          questionStart: _questionStart,
          question: 'Поднести ко рту чашку или стакан?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q8 : null,
        ),
        QuestionsItem(
          id: 'q9',
          questionCategory: _labeEat,
          questionStart: _questionStart,
          question: 'Открыть новую коробку с кукурузными хлопьями?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q9 : null,
        ),
        QuestionsItem(
          id: 'q10',
          questionCategory: _labelWalk,
          questionStart: _questionStart,
          question: 'Ходить вне дома по ровной земле?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q10 : null,
        ),
        QuestionsItem(
          id: 'q11',
          questionCategory: _labelWalk,
          questionStart: _questionStart,
          question: 'Подняться на пять ступеней?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q11 : null,
        ),
        QuestionsItem(
            id: check1,
            questionCategory: _labelDevisesAndAdditionalHelp,
            questionStart: '',
            question:
                'Укажите, какие ПРИСПОСОБЛЕНИЯ использует Ваш ребенок, выполняя указанные функции (одевание и туалет, подъем, еда, ходьба):',
            answersForCheck: [
              AnswersForCheck(
                  idAnswer: 'rod',
                  answer: 'Трость',
                  isSelect: (widget.isEditForm) ? _thisData.rod : false),
              AnswersForCheck(
                  idAnswer: 'hod',
                  answer: 'Ходилки',
                  isSelect: (widget.isEditForm) ? _thisData.hod : false),
              AnswersForCheck(
                  idAnswer: 'kos',
                  answer: 'Костыли',
                  isSelect: (widget.isEditForm) ? _thisData.kos : false),
              AnswersForCheck(
                  idAnswer: 'inv',
                  answer: 'Инвалидное кресло',
                  isSelect: (widget.isEditForm) ? _thisData.inv : false),
              AnswersForCheck(
                  idAnswer: 'odev',
                  answer:
                      'При одевании (пуговичный крючок для молнии, обувной рожок с длинной ручкой и т.д.)',
                  isSelect: (widget.isEditForm) ? _thisData.odev : false),
              AnswersForCheck(
                  idAnswer: 'pencil',
                  answer: 'Толстый карандаш или специальные приспособления',
                  isSelect: (widget.isEditForm) ? _thisData.pencil : false),
              AnswersForCheck(
                  idAnswer: 'chair',
                  answer: 'Специальное или возвышенное кресло',
                  isSelect: (widget.isEditForm) ? _thisData.chair : false),
              AnswersForCheck(
                  idAnswer: 'other',
                  answer: 'Другие',
                  isSelect: (widget.isEditForm) ? _thisData.other : false),
            ],
            answerType: _answerTypeCheck,
            answerForRadio: null),
        QuestionsItem(
            id: check2,
            questionCategory: _labelDevisesAndAdditionalHelp,
            questionStart: '',
            question:
                'Укажите, при каких ежедневных действия ребенка ему требуется ИЗ-ЗА БОЛЕЗНИ дополнительная помощь других лиц:',
            answersForCheck: [
              AnswersForCheck(
                  idAnswer: 'hputon',
                  answer: 'Одевание и туалет',
                  isSelect: (widget.isEditForm) ? _thisData.hputon : false),
              AnswersForCheck(
                  idAnswer: 'hgetup',
                  answer: 'Подъем',
                  isSelect: (widget.isEditForm) ? _thisData.hgetup : false),
              AnswersForCheck(
                  idAnswer: 'heat',
                  answer: 'Еда',
                  isSelect: (widget.isEditForm) ? _thisData.heat : false),
              AnswersForCheck(
                  idAnswer: 'hwalk',
                  answer: 'Ходьба',
                  isSelect: (widget.isEditForm) ? _thisData.hwalk : false),
            ],
            answerType: _answerTypeCheck,
            answerForRadio: null),
        QuestionsItem(
          id: 'q12',
          questionCategory: _labelHygiene,
          questionStart: _questionStart,
          question: 'Вымыть и вытереть всё тело?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q12 : null,
        ),
        QuestionsItem(
          id: 'q13',
          questionCategory: _labelHygiene,
          questionStart: _questionStart,
          question: 'Войти и выйти из ванны?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q13 : null,
        ),
        QuestionsItem(
          id: 'q14',
          questionCategory: _labelHygiene,
          questionStart: _questionStart,
          question: 'Сесть и встать с унитаза или горшка?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q14 : null,
        ),
        QuestionsItem(
          id: 'q15',
          questionCategory: _labelHygiene,
          questionStart: _questionStart,
          question: 'Чистить зубы?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q15 : null,
        ),
        QuestionsItem(
          id: 'q16',
          questionCategory: _labelHygiene,
          questionStart: _questionStart,
          question: 'Причесаться?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q16 : null,
        ),
        QuestionsItem(
          id: 'q17',
          questionCategory: _labelGetAnything,
          questionStart: _questionStart,
          question:
              'Взять на уровне головы и опустить вниз тяжелую вещь (большую игру, книги)?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q17 : null,
        ),
        QuestionsItem(
          id: 'q18',
          questionCategory: _labelGetAnything,
          questionStart: _questionStart,
          question: 'Нагнуться и поднять с пола одежду или лист бумаги?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q18 : null,
        ),
        QuestionsItem(
          id: 'q19',
          questionCategory: _labelGetAnything,
          questionStart: _questionStart,
          question: 'Надеть свитер через голову?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q19 : null,
        ),
        QuestionsItem(
          id: 'q20',
          questionCategory: _labelGetAnything,
          questionStart: _questionStart,
          question: 'Повернув шею, посмотреть назад?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q20 : null,
        ),
        QuestionsItem(
          id: 'q21',
          questionCategory: _labelCompression,
          questionStart: _questionStart,
          question: 'Писать ручкой или карандашом?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q21 : null,
        ),
        QuestionsItem(
          id: 'q22',
          questionCategory: _labelCompression,
          questionStart: _questionStart,
          question: 'Открыть дверь автомобиля?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q22 : null,
        ),
        QuestionsItem(
          id: 'q23',
          questionCategory: _labelCompression,
          questionStart: _questionStart,
          question: 'Открыть ранее вскрытую банку?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q23 : null,
        ),
        QuestionsItem(
          id: 'q24',
          questionCategory: _labelCompression,
          questionStart: _questionStart,
          question: 'Открыть и закрыть водопроводный кран?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q24 : null,
        ),
        QuestionsItem(
          id: 'q25',
          questionCategory: _labelCompression,
          questionStart: _questionStart,
          question: 'Отворить дверь, предварительно повернув дверную ручку?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q25 : null,
        ),
        QuestionsItem(
          id: 'q26',
          questionCategory: _labelFunction,
          questionStart: _questionStart,
          question: 'Выполнить поручения вне дома, ходить в магазин?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q26 : null,
        ),
        QuestionsItem(
          id: 'q27',
          questionCategory: _labelFunction,
          questionStart: _questionStart,
          question:
              'Войти и выйти из машины, детской машины, школьного автобуса?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q27 : null,
        ),
        QuestionsItem(
          id: 'q28',
          questionCategory: _labelFunction,
          questionStart: _questionStart,
          question: 'Ездить на велосипеде?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q28 : null,
        ),
        QuestionsItem(
          id: 'q29',
          questionCategory: _labelFunction,
          questionStart: _questionStart,
          question:
              'Выполнять работу по дому (мыть посуду, выносить мусор, пылесосить, работать во дворе, убирать постель и комнату)?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q29 : null,
        ),
        QuestionsItem(
          id: 'q30',
          questionCategory: _labelFunction,
          questionStart: _questionStart,
          question: 'Бегать и играть?',
          answersForRadio: _listRadioAnswer,
          answerType: _answerTypeRadio,
          answerForRadio: (widget.isEditForm) ? _thisData.q30 : null,
        ),
        QuestionsItem(
            id: check3,
            questionCategory: _labelDevisesAndAdditionalHelp,
            questionStart: '',
            question:
                'Укажите ПРИСПОСОБЛЕНИЯ, необходимые ребенку при выполнении следующих функций (гигиена, что-нибудь достать, сжатие и открывание предметов, выполнение поручений и работа по дому):',
            answersForCheck: [
              AnswersForCheck(
                  idAnswer: 'sidun',
                  answer: 'Приподнятое сидение унитаза',
                  isSelect: (widget.isEditForm) ? _thisData.sidun : false),
              AnswersForCheck(
                  idAnswer: 'sidvan',
                  answer: 'Специальное сидение в ванной',
                  isSelect: (widget.isEditForm) ? _thisData.sidvan : false),
              AnswersForCheck(
                  idAnswer: 'kons',
                  answer: 'Консервный нож (если банка уже вскрыта)',
                  isSelect: (widget.isEditForm) ? _thisData.kons : false),
              AnswersForCheck(
                  idAnswer: 'per',
                  answer: 'Специальная перекладина в ванной комнате',
                  isSelect: (widget.isEditForm) ? _thisData.per : false),
              AnswersForCheck(
                  idAnswer: 'longget',
                  answer: 'Предметы с длинной ручкой, чтобы что-то достать',
                  isSelect: (widget.isEditForm) ? _thisData.longget : false),
              AnswersForCheck(
                  idAnswer: 'longwash',
                  answer: 'Предметы с длинной ручкой для мытья в ванной',
                  isSelect: (widget.isEditForm) ? _thisData.longwash : false),
            ],
            answerType: _answerTypeCheck,
            answerForRadio: null),
        QuestionsItem(
            id: check4,
            questionCategory: _labelDevisesAndAdditionalHelp,
            questionStart: '',
            question:
                'Укажите повседневные функции, при выполнении которых ребенок ИЗ-ЗА БОЛЕЗНИ нуждается в дополнительной помощи других лиц:',
            answersForCheck: [
              AnswersForCheck(
                  idAnswer: 'gig',
                  answer: 'Гигиена',
                  isSelect: (widget.isEditForm) ? _thisData.gig : false),
              AnswersForCheck(
                  idAnswer: 'questget',
                  answer: 'Для того, чтобы что-нибудь достать',
                  isSelect: (widget.isEditForm) ? _thisData.questget : false),
              AnswersForCheck(
                  idAnswer: 'questopen',
                  answer: 'Сжатие и открывание предметов',
                  isSelect: (widget.isEditForm) ? _thisData.questopen : false),
              AnswersForCheck(
                  idAnswer: 'home',
                  answer: 'Выполнение поручений и работа по дому',
                  isSelect: (widget.isEditForm) ? _thisData.home : false),
            ],
            answerType: _answerTypeCheck,
            answerForRadio: null),
        QuestionsItem(
          id: 'painAsses',
          questionCategory: 'БОЛЬ',
          questionStart: '',
          question: 'Установите оценку боли',
          answerType: _answerTypeScale,
          answerForRadio: (widget.isEditForm) ? _thisData.painAsses : 0,
        ),
        QuestionsItem(
          id: 'condAsses',
          questionCategory: 'ФИНАЛЬНАЯ ОЦЕНКА',
          questionStart: '',
          question: 'Установите оценку состояния',
          answerType: _answerTypeScale,
          answerForRadio: (widget.isEditForm) ? _thisData.condAsses : 0,
        ),
      ];
    });
  }

  void _changeData() async {
    setState(() {
      _isLoading = true;
    });

    DataQuestionnaire? result = await _request();

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      _showResultDialog(result);
    } else {
      ShowMessage.show(context: context, message: 'Неизвестная ошибка');
    }
  }

  Future<DataQuestionnaire?> _request() async {
    DataQuestionnaire thisData = DataQuestionnaire(
      id: widget.isEditForm ? _recordId : null,
      questdate: _date,
      q1: getAnswerForRadio('q1'),
      q2: getAnswerForRadio('q2'),
      q3: getAnswerForRadio('q3'),
      q4: getAnswerForRadio('q4'),
      q5: getAnswerForRadio('q5'),
      q6: getAnswerForRadio('q6'),
      q7: getAnswerForRadio('q7'),
      q8: getAnswerForRadio('q8'),
      q9: getAnswerForRadio('q9'),
      q10: getAnswerForRadio('q10'),
      q11: getAnswerForRadio('q11'),
      q12: getAnswerForRadio('q12'),
      q13: getAnswerForRadio('q13'),
      q14: getAnswerForRadio('q14'),
      q15: getAnswerForRadio('q15'),
      q16: getAnswerForRadio('q16'),
      q17: getAnswerForRadio('q17'),
      q18: getAnswerForRadio('q18'),
      q19: getAnswerForRadio('q19'),
      q20: getAnswerForRadio('q20'),
      q21: getAnswerForRadio('q21'),
      q22: getAnswerForRadio('q22'),
      q23: getAnswerForRadio('q23'),
      q24: getAnswerForRadio('q24'),
      q25: getAnswerForRadio('q25'),
      q26: getAnswerForRadio('q26'),
      q27: getAnswerForRadio('q27'),
      q28: getAnswerForRadio('q28'),
      q29: getAnswerForRadio('q29'),
      q30: getAnswerForRadio('q30'),
      rod: getAnswerForCheck(check1, 'rod'),
      hod: getAnswerForCheck(check1, 'hod'),
      kos: getAnswerForCheck(check1, 'kos'),
      inv: getAnswerForCheck(check1, 'inv'),
      odev: getAnswerForCheck(check1, 'odev'),
      pencil: getAnswerForCheck(check1, 'pencil'),
      chair: getAnswerForCheck(check1, 'chair'),
      other: getAnswerForCheck(check1, 'other'),
      otherDevices: _other,
      hputon: getAnswerForCheck(check2, 'hputon'),
      hgetup: getAnswerForCheck(check2, 'hgetup'),
      heat: getAnswerForCheck(check2, 'heat'),
      hwalk: getAnswerForCheck(check2, 'hwalk'),
      sidun: getAnswerForCheck(check3, 'sidun'),
      sidvan: getAnswerForCheck(check3, 'sidvan'),
      kons: getAnswerForCheck(check3, 'kons'),
      per: getAnswerForCheck(check3, 'per'),
      longget: getAnswerForCheck(check3, 'longget'),
      longwash: getAnswerForCheck(check3, 'longwash'),
      gig: getAnswerForCheck(check4, 'gig'),
      questget: getAnswerForCheck(check4, 'questget'),
      questopen: getAnswerForCheck(check4, 'questopen'),
      home: getAnswerForCheck(check4, 'home'),
      painAsses: getAnswerForRadio('painAsses'),
      condAsses: getAnswerForRadio('condAsses'),
      creationDate: _creationDate,
    );
    return widget.isEditForm
        ? await _api.put(
            patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : !widget.isAnonymous
            ? await _api.post(patientsId: _patientsId, thisData: thisData)
            : await _api.postAnonymous(thisData: thisData);
  }

  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _other != '' || // Заполнено ли поле "Другие приборы"
          _listQuestions.any((q) =>
              (q.answerType == _answerTypeRadio ||
                  q.answerType == _answerTypeScale) &&
              q.answerForRadio != null &&
              q.answerForRadio != 0) || // Заполнен ли какой-то radio/scale
          _listQuestions.any((q) =>
              q.answerType == _answerTypeCheck &&
              q.answersForCheck!
                  .any((a) => a.isSelect)); // Выбран ли какой-то чекбокс
    }

    // Иначе сравниваем поля с исходными данными
    final w = widget.thisData!;
    bool areQuestionsDifferent = false;

    // Сравнение вопросов
    for (var q in _listQuestions) {
      if (q.answerType == _answerTypeRadio ||
          q.answerType == _answerTypeScale) {
        int originalValue;
        switch (q.id) {
          case 'q1':
            originalValue = w.q1;
            break;
          case 'q2':
            originalValue = w.q2;
            break;
          case 'q3':
            originalValue = w.q3;
            break;
          case 'q4':
            originalValue = w.q4;
            break;
          case 'q5':
            originalValue = w.q5;
            break;
          case 'q6':
            originalValue = w.q6;
            break;
          case 'q7':
            originalValue = w.q7;
            break;
          case 'q8':
            originalValue = w.q8;
            break;
          case 'q9':
            originalValue = w.q9;
            break;
          case 'q10':
            originalValue = w.q10;
            break;
          case 'q11':
            originalValue = w.q11;
            break;
          case 'q12':
            originalValue = w.q12;
            break;
          case 'q13':
            originalValue = w.q13;
            break;
          case 'q14':
            originalValue = w.q14;
            break;
          case 'q15':
            originalValue = w.q15;
            break;
          case 'q16':
            originalValue = w.q16;
            break;
          case 'q17':
            originalValue = w.q17;
            break;
          case 'q18':
            originalValue = w.q18;
            break;
          case 'q19':
            originalValue = w.q19;
            break;
          case 'q20':
            originalValue = w.q20;
            break;
          case 'q21':
            originalValue = w.q21;
            break;
          case 'q22':
            originalValue = w.q22;
            break;
          case 'q23':
            originalValue = w.q23;
            break;
          case 'q24':
            originalValue = w.q24;
            break;
          case 'q25':
            originalValue = w.q25;
            break;
          case 'q26':
            originalValue = w.q26;
            break;
          case 'q27':
            originalValue = w.q27;
            break;
          case 'q28':
            originalValue = w.q28;
            break;
          case 'q29':
            originalValue = w.q29;
            break;
          case 'q30':
            originalValue = w.q30;
            break;
          case 'painAsses':
            originalValue = w.painAsses;
            break;
          case 'condAsses':
            originalValue = w.condAsses;
            break;
          default:
            originalValue = 0; // По умолчанию для неизвестных ID
        }
        if (q.answerForRadio != originalValue) {
          areQuestionsDifferent = true;
          break;
        }
      } else if (q.answerType == _answerTypeCheck) {
        switch (q.id) {
          case 'check1':
            if (getAnswerForCheck('check1', 'rod') != w.rod ||
                getAnswerForCheck('check1', 'hod') != w.hod ||
                getAnswerForCheck('check1', 'kos') != w.kos ||
                getAnswerForCheck('check1', 'inv') != w.inv ||
                getAnswerForCheck('check1', 'odev') != w.odev ||
                getAnswerForCheck('check1', 'pencil') != w.pencil ||
                getAnswerForCheck('check1', 'chair') != w.chair ||
                getAnswerForCheck('check1', 'other') != w.other) {
              areQuestionsDifferent = true;
            }
            break;
          case 'check2':
            if (getAnswerForCheck('check2', 'hputon') != w.hputon ||
                getAnswerForCheck('check2', 'hgetup') != w.hgetup ||
                getAnswerForCheck('check2', 'heat') != w.heat ||
                getAnswerForCheck('check2', 'hwalk') != w.hwalk) {
              areQuestionsDifferent = true;
            }
            break;
          case 'check3':
            if (getAnswerForCheck('check3', 'sidun') != w.sidun ||
                getAnswerForCheck('check3', 'sidvan') != w.sidvan ||
                getAnswerForCheck('check3', 'kons') != w.kons ||
                getAnswerForCheck('check3', 'per') != w.per ||
                getAnswerForCheck('check3', 'longget') != w.longget ||
                getAnswerForCheck('check3', 'longwash') != w.longwash) {
              areQuestionsDifferent = true;
            }
            break;
          case 'check4':
            if (getAnswerForCheck('check4', 'gig') != w.gig ||
                getAnswerForCheck('check4', 'questget') != w.questget ||
                getAnswerForCheck('check4', 'questopen') != w.questopen ||
                getAnswerForCheck('check4', 'home') != w.home) {
              areQuestionsDifferent = true;
            }
            break;
        }
        if (areQuestionsDifferent) break;
      }
    }

    return _other != w.otherDevices || // Сравнение поля "Другие приборы"
        areQuestionsDifferent; // Сравнение вопросов
  }


  @override
  Widget build(BuildContext context) {
    if (_listQuestions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    double progress = (_currentIndex + 1) / _listQuestions.length;
    QuestionsItem qItem = _listQuestions[_currentIndex];
    return Scaffold(
      appBar: AppBarWidget(
        title: getFormTitle(Roles.asPatient.contains(_role) ? widget.isEditForm : null),
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () {
          onBack(context, (_areDifferent()));
        },
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormHeaderWidget(title: widget.title),
              // Прогресс-бар с текстом поверх
              Stack(
                children: [
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.deepPurple.shade300,
                        minHeight: 25,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '${_currentIndex + 1} / ${_listQuestions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade400,
                      ),
                      child: Center(
                        child: Text(
                          qItem.questionCategory,
                          style: captionWhiteTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              if (qItem.questionStart.isNotEmpty)
                Text(qItem.questionStart, style: labelStyle),
              if (qItem.questionStart.isNotEmpty) const SizedBox(height: 5),
              Text(qItem.question, style: inputTextStyle),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: _form(qItem),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ButtonWidget(
                      labelText: 'Назад',
                      width: 145,
                      backgroundColor: Colors.green,
                      enabled: _currentIndex > 0 ? true : false,
                      listRoles: Roles.all,
                      role: _role,
                      onPressed: () {
                        setState(() {
                          if (_currentIndex > 0) {
                            _currentIndex--;
                            _isLoading = false;
                          }
                        });
                      },
                    ),
                    ButtonWidget(
                      labelText: _currentIndex < _listQuestions.length - 1
                          ? 'Далее'
                          : _role == Roles.patient
                              ? 'Сохранить'
                              : _role == Roles.anonymous
                                  ? 'Получить результат'
                                  : 'Закрыть',
                      width: 145,
                      showProgressIndicator:
                          _currentIndex < _listQuestions.length - 1
                              ? false
                              : _isLoading,
                      listRoles: Roles.all,
                      onPressed: () {
                        setState(() {
                          if (qItem.id == check1 &&
                              getAnswerForCheck(check1, 'other')) {
                            if (!_formKeys[_currentIndex]
                                .currentState!
                                .validate()) {
                              ShowMessage.show(context: context);
                            }
                          }
                          if ((_formKeys[_currentIndex]
                                      .currentState
                                      ?.validate() ??
                                  false) &&
                              _formKey.currentState!.validate()) {
                            if (_currentIndex < _listQuestions.length - 1) {
                              _currentIndex++;
                            } else {
                              Roles.asPatient.contains(_role)
                                  ? _changeData()
                                  : Navigator.pop(context);
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showResultDialog(DataQuestionnaire dataResult) {
    showDialog(
        context: context,
        barrierDismissible: false, // Диалог не закроется при клике вне его
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext dialogContext, StateSetter dialogSetState) {
            return AlertDialog(
              title: Text(
                'Расчет индекса ФН',
                style: formHeaderStyle,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LabelJoinWidget(
                      labelText: 'Дата',
                      value: dateFormat(dataResult.questdate) ?? '',
                      isColumn: false,
                    ),
                    LabelJoinWidget(
                      labelText: 'Ваш индекс ФН',
                      value: dataResult.result ?? 'Нет данных',
                      isColumn: false,
                    ),
                  ],
                ),
              ),
              actions: [
                ButtonWidget(
                  labelText: 'ОК',
                  onlyText: true,
                  dialogForm: true,
                  listRoles: Roles.all,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }





  static const String _questionStart = 'Может ли Ваш ребенок:';

  static const String _labeldressAndToilet = 'ОДЕВАНИЕ И ТУАЛЕТ';
  static const String _labeWakeUp = 'ПОДЪЕМ';
  static const String _labeEat = 'ЕДА';
  static const String _labelWalk = 'ХОДЬБА';
  static const String _labelHygiene = 'ГИГИЕНА';
  static const String _labelGetAnything = 'ДОСТАТЬ ЧТО-ЛИБО';
  static const String _labelCompression = 'СЖАТИЕ';
  static const String _labelFunction = 'ФУНКЦИИ';
  static const String _labelDevisesAndAdditionalHelp =
      'ПРИСПОСОБЛЕНИЯ И ДОПОЛНИТЕЛЬНАЯ ПОМОЩЬ';

  static const String _answerTypeRadio = 'answerTypeRadio';
  static const String _answerTypeCheck = 'answerTypeCheck';
  static const String _answerTypeScale = 'answerTypeScale';

  static final List<String> _listRadioAnswer = [
    'Без затруднений',
    'Умеренные затруднения',
    'Серьезные трудности',
    'Не может выполнить',
    'Нельзя оценить',
  ];

  String check1 = 'check1';
  String check2 = 'check2';
  String check3 = 'check3';
  String check4 = 'check4';

// Функция для извлечения значения answerForCheck
  bool getAnswerForCheck(String questionId, String checkId) {
    // Найти QuestionsItem с нужным id
    QuestionsItem? questionItem = _listQuestions.firstWhere(
      (item) => item.id == questionId,
    );
    if (questionItem.answersForCheck != null) {
      // Найти CheckAnswerItem с нужным idAnswer
      AnswersForCheck? answersForCheck =
          questionItem.answersForCheck!.firstWhere(
        (item) => item.idAnswer == checkId,
      );
      return answersForCheck.isSelect;
    }
    return false; // Если элемент не найден
  }

  int getAnswerForRadio(String questionId) {
    QuestionsItem? questionItem = _listQuestions.firstWhere(
      (item) => item.id == questionId,
      orElse: () => QuestionsItem(
        id: questionId,
        questionCategory: '',
        questionStart: '',
        question: '',
        answerType: _answerTypeRadio,
        answerForRadio: null,
      ),
    );

    return questionItem.answerForRadio ?? 0; // По умолчанию 0 вместо null
  }

  // Функция для обновления значений isSelect
  void updateAnswersForCheck(String questionId, List<bool> newValues) {
    // Найти QuestionsItem с нужным id
    QuestionsItem? questionItem = _listQuestions.firstWhere(
      (item) => item.id == questionId,
    );

    if (questionItem.answersForCheck != null) {
      // Обновляем значения isSelect
      for (int i = 0; i < questionItem.answersForCheck!.length; i++) {
        questionItem.answersForCheck![i].isSelect = newValues[i];
      }
    }
  }

  Form _form(QuestionsItem qItem) {
    if (qItem.answerType == _answerTypeRadio) {
      return Form(
        key: _formKeys[_currentIndex],
        child: RadioGroupWidget(
          listAnswers: qItem.answersForRadio!,
          selectedIndex: qItem.answerForRadio,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              qItem.answerForRadio = value;
            });
          },
        ),
      );
    } else if (qItem.answerType == _answerTypeCheck) {
      return Form(
        key: _formKeys[_currentIndex],
        child: Column(
          children: [
            CheckboxGroupWidget(
              listAnswers: qItem.answersForCheck!.map((e) => e.answer).toList(),
              selectedIndexes:
                  qItem.answersForCheck!.map((e) => e.isSelect).toList(),
              required: false,
              listRoles: Roles.asPatient,
              role: _role,
              onChanged: (value) {
                setState(() {
                  updateAnswersForCheck(qItem.id, value);
                });
              },
            ),
            if (qItem.id == check1 && getAnswerForCheck(check1, 'other'))
              InputText(
                labelText: 'Другие приборы (уточните)',
                fieldKey: _keys[Enum.otherDevices]!,
                value: _other,
                required: (qItem.answersForCheck![7].isSelect) ? true : false,
                listRoles: Roles.asPatient,
                role: _role,
                onChanged: (value) {
                  setState(() {
                    _other = value;
                  });
                },
              ),
            SizedBox(height: 30.0),
          ],
        ),
      );
    } else {
      return Form(
          key: _formKeys[_currentIndex],
          child: AnimatedColorScaleWidget(
            key: _keyPain,
            value: _listQuestions[_currentIndex].answerForRadio!.toDouble(),
            labelStart: (qItem.id == 'painAsses') ? 'Не болит' : 'Хорошее',
            labelEnd: (qItem.id == 'painAsses') ? 'Очень болит' : 'Плохое',
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _listQuestions[_currentIndex].answerForRadio = value.toInt();
              });
            },
          ));
    }
  }
}
