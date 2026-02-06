import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/pauza_dependencies.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/permissions/permission_helper.dart';
import 'package:pauza/src/core/routing/pauza_router.dart';
import 'package:pauza/src/features/blocking/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/blocking/data/app_fuse_active_mode_storage.dart';
import 'package:pauza/src/features/modes/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/data/modes_repository.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PauzaApp extends StatefulWidget {
  const PauzaApp({super.key});

  static final themes = <Brightness, ThemeData>{
    Brightness.light: PauzaTheme.light,
    Brightness.dark: PauzaTheme.dark,
  };

  static const localizationsDelegates = AppLocalizations.localizationsDelegates;

  static final supportedLanguages = <Locale, String>{
    const Locale('en'): 'English',
    const Locale('uz'): 'O\'zbek',
    const Locale('ru'): 'Русский',
  };

  @override
  State<PauzaApp> createState() => _PauzaAppState();
}

class _PauzaAppState extends State<PauzaApp>
    with RouterStateMixin<PauzaApp>, WidgetsBindingObserver {
  late final PauzaDependencies _dependencies;
  late final ModesBloc _modesBloc;
  late final BlockingBloc _blockingBloc;

  @override
  PauzaPermissionGate get permissionGate => _dependencies.permissionGate;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    context.changeAppLocale(PauzaApp.supportedLanguages.keys.first);

    _dependencies = PauzaDependencies.of(context);
    _modesBloc = ModesBloc(modesRepository: _dependencies.modesRepository)
      ..add(ModesRequested(platform: PauzaPlatform.current));
    _blockingBloc = BlockingBloc(
      blockingRepository: _dependencies.blockingRepository,
      modesRepository: _dependencies.modesRepository,
      activeModeStorage: AppFuseActiveModeStorage(fuseController: AppFuseScope.controller(context)),
    )..add(const BlockingSyncRequested());
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dependencies.permissionGate.dispose();
    _modesBloc.close();
    _blockingBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _blockingBloc.add(const BlockingSyncRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<ModesRepository>.value(value: _dependencies.modesRepository),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ModesBloc>.value(value: _modesBloc),
          BlocProvider<BlockingBloc>.value(value: _blockingBloc),
        ],
        child: MaterialApp.router(
          locale: context.watchFuseState.locale,
          supportedLocales: context.readFuseState.supportedLocales,
          localizationsDelegates: context.readFuseState.localizationsDelegates,
          themeMode: context.watchFuseState.themeMode,
          theme: context.readFuseState.lightTheme,
          darkTheme: context.readFuseState.darkTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
