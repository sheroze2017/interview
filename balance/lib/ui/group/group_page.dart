import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage(this.groupId, {super.key});

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();
  late final TransactionsDao _transactionDao = getIt.get<TransactionsDao>();

  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  final _editTransactionController = TextEditingController();
  int balance = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Group details"),
        ),
        body: Column(
          children: [
            StreamBuilder(
              stream: _groupsDao.watchGroup(widget.groupId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("Loading...");
                } else {
                  balance = snapshot.data!.balance;
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(snapshot.data?.name ?? ""),
                      Text(snapshot.data?.balance.toString() ?? ""),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _incomeController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"[0-9]"))
                            ],
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              suffixText: "\$",
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              final amount = int.parse(_incomeController.text);
                              balance = snapshot.data?.balance ?? 0;
                              _groupsDao.adjustBalance(
                                  balance + amount, widget.groupId);
                              balance = balance + amount;
                              _transactionDao.insertIncome(
                                  widget.groupId, amount);
                              _incomeController.text = "";
                            },
                            child: Text("Add income")),
                      ]),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expenseController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r"[0-9]"))
                            ],
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              suffixText: "\$",
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              final amount = int.parse(_expenseController.text);
                              balance = snapshot.data?.balance ?? 0;

                              _groupsDao.adjustBalance(
                                  balance - amount, widget.groupId);
                              balance = balance - amount;
                              _transactionDao.insertExpense(
                                  widget.groupId, amount, false);

                              _expenseController.text = "";
                            },
                            child: Text("Add expense")),
                      ]),
                    ],
                  );
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Transaction History'),
            ),
            StreamBuilder(
              stream: _transactionDao.watchTransaction(widget.groupId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("Loading...");
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.requireData.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data![index];
                        return ListTile(
                          title: Text(
                              'Last Modified ${snapshot.requireData[index].createdAt}'),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: isUuidVersion4(
                                        snapshot.requireData[index].id)
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                isUuidVersion4(snapshot.requireData[index].id)
                                    ? 'Expense'
                                    : 'Income',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          subtitle: Text(
                              'Amount ${snapshot.requireData[index].amount}'),
                          trailing: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Transaction Update'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText: 'Update Amount',
                                              hintText: data.amount.toString()),
                                          controller:
                                              _editTransactionController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r"[0-9]"))
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          _editTransactionController.clear();

                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Close'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final amount = int.parse(
                                              _editTransactionController.text);
                                          await _transactionDao.editTransaction(
                                              amount,
                                              data.groupId,
                                              data.id,
                                              data.createdAt);

                                          _groupsDao.adjustBalance(
                                              isUuidVersion4(data.id)
                                                  ? balance +
                                                      data.amount -
                                                      amount
                                                  : balance -
                                                      data.amount +
                                                      amount,
                                              data.groupId);
                                          balance = isUuidVersion4(data.id)
                                              ? balance + data.amount - amount
                                              : balance - data.amount + amount;
                                          _editTransactionController.clear();
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text(isUuidVersion4(
                                                snapshot.requireData[index].id)
                                            ? 'Expense Update'
                                            : 'Income Update'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.edit_document,
                              size: 20,
                            ),
                          ),
                        );
                      }),
                );
              },
            ),
          ],
        ),
      );
}

bool isUuidVersion1(String uuid) {
  RegExp regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-1[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
  return regex.hasMatch(uuid);
}

bool isUuidVersion4(String uuid) {
  RegExp regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
  return regex.hasMatch(uuid);
}
