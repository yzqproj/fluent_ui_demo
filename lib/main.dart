import 'package:fluent_ui_demo/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:url_launcher/link.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/forms/auto_suggest_box.dart';
import 'screens/forms/combobox.dart';
import 'screens/forms/date_picker.dart';
import 'screens/forms/text_box.dart';
import 'screens/forms/time_picker.dart';
import 'screens/home.dart';
import 'screens/inputs/button.dart';
import 'screens/inputs/checkbox.dart';
import 'screens/inputs/slider.dart';
import 'screens/inputs/toggle_switch.dart';
import 'screens/navigation/tab_view.dart';
import 'screens/navigation/tree_view.dart';
import 'screens/settings.dart';
import 'screens/surface/acrylic.dart';
import 'screens/surface/commandbars.dart';
import 'screens/surface/content_dialog.dart';
import 'screens/surface/expander.dart';
import 'screens/surface/flyouts.dart';
import 'screens/surface/info_bars.dart';
import 'screens/surface/progress_indicators.dart';
import 'screens/surface/tooltip.dart';
import 'screens/theming/colors.dart';
import 'screens/theming/icons.dart';
import 'screens/theming/typography.dart';
import 'theme.dart';

const String appTitle = 'Fluent UI Showcase for Flutter';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  setPathUrlStrategy();

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(350, 600));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: ThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          initialRoute: '/',
          routes: {'/': (context) => const MyHomePage()},
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;

  int index = 0;

  final settingsController = ScrollController();
  final viewKey = GlobalKey();

  final key = GlobalKey();
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  void resetSearch() => searchController.clear();
  String get searchValue => searchController.text;
  final List<NavigationPaneItem> originalItems = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
    ),
    PaneItemSeparator(),
    PaneItemHeader(header: const Text('Inputs')),
    PaneItem(
      icon: const Icon(FluentIcons.button_control),
      title: const Text('Button'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.checkbox_composite),
      title: const Text('Checkbox'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.slider),
      title: const Text('Slider'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.toggle_left),
      title: const Text('ToggleSwitch'),
    ),
    PaneItemHeader(
      header: const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Text('Form'),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.text_field),
      title: const Text('TextBox'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.page_list),
      title: const Text('AutoSuggestBox'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.combobox),
      title: const Text('Combobox'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.time_picker),
      title: const Text('TimePicker'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.date_time),
      title: const Text('DatePicker'),
    ),
    PaneItemHeader(
      header: const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Text('Navigation'),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.navigation_flipper),
      title: const Text('NavigationView'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.table_header_row),
      title: const Text('TabView'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.bulleted_tree_list),
      title: const Text('TreeView'),
    ),
    PaneItemHeader(
      header: const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Text('Surfaces'),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.un_set_color),
      title: const Text('Acrylic'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.customize_toolbar),
      title: const Text('CommandBar'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.comment_urgent),
      title: const Text('ContentDialog'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.expand_all),
      title: const Text('Expander'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.info_solid),
      title: const Text('InfoBar'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.progress_ring_dots),
      title: const Text('Progress Indicators'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.hint_text),
      title: const Text('Tooltip'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.pop_expand),
      title: const Text('Flyout'),
    ),
    PaneItemHeader(
      header: const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Text('Theming'),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.color_solid),
      title: const Text('Colors'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.font_color_a),
      title: const Text('Typography'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.icon_sets_flag),
      title: const Text('Icons'),
    ),
  ];
  late List<NavigationPaneItem> items = originalItems;

  final content = <Page>[
    HomePage(),
    // inputs
    ButtonPage(),
    CheckboxPage(),
    SliderPage(),
    ToggleSwitchPage(),
    // forms
    TextBoxPage(),
    AutoSuggestBoxPage(),
    ComboboxPage(),
    TimePickerPage(),
    DatePickerPage(),
    // navigation
    EmptyPage(),
    TabViewPage(),
    TreeViewPage(),
    // surfaces
    AcrylicPage(),
    CommandBarsPage(),
    ContentDialogPage(),
    ExpanderPage(),
    InfoBarPage(),
    ProgressIndicatorsPage(),
    TooltipPage(),
    const FlyoutPage().toPage(),
    // theming
    ColorsPage(),
    const TypographyPage().toPage(),
    const IconsPage().toPage(),
    // others
    Settings(),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    searchController.addListener(() {
      setState(() {
        if (searchValue.isEmpty) {
          items = originalItems;
        } else {
          items = originalItems
              .whereType<PaneItem>()
              .where((item) {
                assert(item.title is Text);
                final text = (item.title as Text).data!;
                return text.toLowerCase().contains(searchValue.toLowerCase());
              })
              .toList()
              .cast<NavigationPaneItem>();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    settingsController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) {
            return const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            );
          }
          return const DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            ),
          );
        }(),
        actions: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            ToggleSwitch(
              content: const Text('Dark Mode'),
              checked: FluentTheme.of(context).brightness.isDark,
              onChanged: (v) {
                if (v) {
                  appTheme.mode = ThemeMode.dark;
                } else {
                  appTheme.mode = ThemeMode.light;
                }
              },
            ),
            if (!kIsWeb) const WindowButtons(),
          ],
        ),
      ),
      pane: NavigationPane(
        selected: () {
          // if not searching, return the current index
          if (searchValue.isEmpty) return index;

          final indexOnScreen = items.indexOf(
            originalItems.whereType<PaneItem>().elementAt(index),
          );
          if (indexOnScreen.isNegative) return null;
          return indexOnScreen;
        }(),
        onChanged: (i) {
          // If searching, the values will have different indexes
          if (searchValue.isNotEmpty) {
            final equivalentIndex = originalItems
                .whereType<PaneItem>()
                .toList()
                .indexOf(items[i] as PaneItem);
            i = equivalentIndex;
          }
          resetSearch();
          setState(() => index = i);
        },
        size: const NavigationPaneSize(
          openMinWidth: 250.0,
          openMaxWidth: 320.0,
        ),
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: FlutterLogo(
            style: appTheme.displayMode == PaneDisplayMode.top
                ? FlutterLogoStyle.markOnly
                : FlutterLogoStyle.horizontal,
            size: appTheme.displayMode == PaneDisplayMode.top ? 24 : 100.0,
          ),
        ),
        displayMode: appTheme.displayMode,
        indicator: () {
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return const EndNavigationIndicator();
            case NavigationIndicators.sticky:
            default:
              return const StickyNavigationIndicator();
          }
        }(),
        items: items,
        autoSuggestBox: TextBox(
          key: key,
          controller: searchController,
          placeholder: 'Search',
          focusNode: searchFocusNode,
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
          ),
          _LinkPaneItemAction(
            icon: const Icon(FluentIcons.open_source),
            title: const Text('Source code'),
            link: 'https://github.com/bdlukaa/fluent_ui',
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: content.transform(context),
      ),
    );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends PaneItem {
  _LinkPaneItemAction({
    required Widget icon,
    required this.link,
    title,
    infoBadge,
    focusNode,
    autofocus = false,
  }) : super(
          icon: icon,
          title: title,
          infoBadge: infoBadge,
          focusNode: focusNode,
          autofocus: autofocus,
        );

  final String link;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (context, followLink) => super.build(
        context,
        selected,
        followLink,
        displayMode: displayMode,
        showTextOnTop: showTextOnTop,
        autofocus: autofocus,
      ),
    );
  }
}
