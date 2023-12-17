import 'package:balance/core/database/database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../tables/transactions.dart';
part 'transactions_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<Database>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future insertIncome(String groupId, int amount) {
    return into(transactions).insert(TransactionsCompanion.insert(
      id: const Uuid().v1(),
      amount: Value(amount),
      createdAt: DateTime.now(),
      groupId: groupId,
    ));
  }

  Future insertExpense(String groupId, int amount, bool expense) {
    return into(transactions).insert(TransactionsCompanion.insert(
      id: const Uuid().v4(),
      amount: Value(amount),
      createdAt: DateTime.now(),
      groupId: groupId,
    ));
  }

  Future editTransaction(
      int newAmount, String groupId, String id, DateTime dateTime) async {
    final companion = TransactionsCompanion(
      amount: Value(newAmount),
      createdAt: Value(DateTime.now()),
    );
    return (update(transactions)..where((tbl) => tbl.id.equals(id)))
        .write(companion);
  }

  Stream<List<Transaction>> watch() => select(transactions).watch();

  Stream<List<Transaction>> watchTransaction(String groupId) {
    return (select(transactions)..where((tbl) => tbl.groupId.equals(groupId)))
        .watch();
  }
}
