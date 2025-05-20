import 'dart:async';
import 'package:artrit/pages/page_chat_mesages.dart';
import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../my_functions.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/chat_provider.dart';
import 'menu.dart';

class PageChatMain extends StatefulWidget {
  final String title;

  const PageChatMain({
    super.key,
    required this.title,
  });

  @override
  State<PageChatMain> createState() => _PageChatMainState();
}

class _PageChatMainState extends State<PageChatMain> {
  late Future<void> _future;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initialize() async {
    // Инициализация уже выполняется в ChatProvider, просто ждём завершения
    await Provider.of<ChatProvider>(context, listen: false).refreshMessageCount(context: context);
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Фильтруем контакты на основе поискового запроса
        final filteredContacts = chatProvider.chatContacts.where((contact) {
          return contact.userFio.toLowerCase().contains(_searchQuery);
        }).toList()
          ..sort((b, a) => a.messageCount.compareTo(b.messageCount));

        return Scaffold(
          appBar: AppBarWidget(
            title: widget.title,
            showChat: false,
          ),
          endDrawer: const MenuDrawer(),
          body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return errorDataWidget(snapshot.error);
              }

              return GestureDetector(
                // Скрываем клавиатуру при касании пустого места
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: paddingFormAll,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Поиск...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onChanged: _filter,
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                child: Text(_getInitials(contact.userFio)),
                              ),
                              trailing: contact.messageCount > 0
                                  ? Badge.count(
                                backgroundColor: Colors.green,
                                textStyle: chatNewMsgCountStyle,
                                count: contact.messageCount,
                              )
                                  : null,
                              title: Text(
                                contact.userFio,
                                style: captionMiniTextStyle,
                              ),
                              // subtitle: Text(
                              //   'Хорошо бы тут отображать последнее сообщение пользователя, чтобы не открывать, когда там просто написано "Ок" или "Хорошо"',
                              //   maxLines: 2,
                              //   softWrap: true,
                              //   overflow: TextOverflow.ellipsis,
                              //   style: subtitleMiniTextStyle,
                              // ),
                              onTap: () {
                                navigateToPage(
                                  context,
                                  PageChatMessages(
                                    contact: contact,
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            height: 20,
                            thickness: 0.5,
                            color: Colors.black12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Функция, которая извлекает первую букву из фамилии и имени
  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) {
      return 'N';
    }

    List<String> parts = fullName.trim().split(RegExp(r'\s+'));

    if (parts.isNotEmpty) {
      String surname = parts[0];
      String name = parts.length > 1 ? parts[1] : '';

      if (surname.isNotEmpty && name.isNotEmpty) {
        return '${surname[0]}${name[0]}';
      }
      return surname.isNotEmpty
          ? surname[0]
          : name.isNotEmpty
          ? name[0]
          : 'N';
    }

    return 'N';
  }
}