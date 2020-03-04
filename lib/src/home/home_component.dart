import 'dart:async';

import 'package:HolySheetWeb/src/primary_routes.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'home',
  styleUrls: ['home_component.css'],
  templateUrl: 'home_component.html',
  directives: [
    NgFor,
    NgIf,
    NgClass,
    NgSwitch,
    NgSwitchWhen,
    MaterialIconComponent,
  ],
  exports: [HomeTab, Repo],
)
class HomeComponent implements OnInit, OnActivate {
  final AuthService authService;
  final Router router;

  HomeTab activeTab = HomeTab.Overview;

  HomeComponent(this.authService, this.router);

  @override
  void onActivate(RouterState previous, RouterState current) {
    activeTab = HomeTab.fromParam((current?.parameters ?? {})['id']);
  }

  @override
  Future<Null> ngOnInit() async {}

  void goToFiles() {
    router.navigate(RoutePaths.files.path);
  }

  void launch() {
    if (authService.checkSignedIn) {
      router.navigate(RoutePaths.files.path);
    } else {
      authService.loginUser().then((user) {
        if (authService.checkSignedIn) {
          router.navigate(RoutePaths.files.path);
        }
      });
    }
  }

  void switchTab(HomeTab tab) {
    router.navigate(RoutePaths.homeTab.toUrl(parameters: {'id': tab.param}));
  }

  Map<String, bool> getClasses(HomeTab tab) => {
        'is-active': tab == activeTab,
        'menu-item-primary': tab == activeTab,
      };
}

class Repo {
  static const HolySheet = Repo('HolySheet', ['This is the core program for HolySheet. This can interface with other applications such as the desktop app and webserver.', 'This also features a CLI to have full functionality over HolySheet files completely locally.'], langs: ['Java']);
  static const HolySheetWeb =
      Repo('HolySheet Website', ['This is the static frontend for the HolySheet website.', 'This provides an easy-to-use website interface to manage files from any device.'], repoName: 'HolySheetWeb', langs: ['HTML']);
  static const HolySheetWebserver =
      Repo('HolySheet API', ['The REST API for HolySheet, allowing other applications to manage files.', 'Provides a distributed solution via Docker and Kubernetes to allow for an extreme amount of users.'], repoName: 'HolySheetWebserver', langs: ['Dart']);
  static const SheetyGUI = Repo('SheetyGUI', ['The Desktop GUI app, written in Flutter to be cross-platform to allow for an easy to use, local solution to manage files.'], langs: ['Dart']);
  static const HolySheetDocs =
      Repo('Docs', ['The REST API docs to use the public API.'], repoName: 'HolySheetDocs', langs: ['Markdown']);

  static const values = <Repo>[
    HolySheet,
    HolySheetWeb,
    HolySheetWebserver,
    SheetyGUI,
    HolySheetDocs
  ];

  final String name;
  final String repoName;
  final List<String> description;
  final List<String> langs;

  const Repo(this.name, this.description, {this.repoName = '', this.langs = const []});
}

class HomeTab {
  static const Overview = HomeTab('Overview', 'bookmark', '');
  static const BehindTheScenes =
      HomeTab('Behind the scenes', 'visibility', 'behind-the-scenes');
  static const OpenSource = HomeTab('Open source', 'code', 'open-source');

  static const values = <HomeTab>[Overview, BehindTheScenes, OpenSource];

  final String display;
  final String icon;
  final String param;

  const HomeTab(this.display, this.icon, this.param);

  static HomeTab fromParam(String param) => [BehindTheScenes, OpenSource]
      .firstWhere((tab) => tab.param == param, orElse: () => Overview);

  @override
  String toString() {
    return 'HomeTab{$display}';
  }
}
