// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:balance/core/database/dao/groups_dao.dart' as _i4;
import 'package:balance/core/database/dao/transactions_dao.dart' as _i5;
import 'package:balance/core/database/database.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.Database>(() => _i3.Database());
    gh.lazySingleton<_i4.GroupsDao>(() => _i4.GroupsDao(gh<_i3.Database>()));
    gh.lazySingleton<_i5.TransactionsDao>(
        () => _i5.TransactionsDao(gh<_i3.Database>()));
    return this;
  }
}
