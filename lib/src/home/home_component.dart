import 'dart:async';
import 'dart:html';

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
  exports: [HomeTab, Repo, BTSDesc],
)
class HomeComponent implements OnActivate {
  final AuthService authService;
  final Router router;

  HomeTab activeTab = HomeTab.Overview;

  HomeComponent(this.authService, this.router);

  @override
  void onActivate(RouterState previous, RouterState current) {
    activeTab = HomeTab.fromParam((current?.fragment ?? ''));
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

  void download() => router.navigate(RoutePaths.download.path);

  void switchTab(HomeTab tab) {
    window.location.hash = tab.param;
  }

  Map<String, bool> getClasses(HomeTab tab) => {
        'is-active': tab == activeTab,
        'menu-item-primary': tab == activeTab,
      };
}

class Repo {
  static const HolySheet = Repo('HolySheet', [
    'This is the core program for HolySheet. This can interface with other applications such as the desktop app and webserver.',
    'This also features a CLI to have full functionality over HolySheet files completely locally.'
  ], langs: [
    'Java'
  ]);
  static const HolySheetWeb = Repo(
      'HolySheet Website',
      [
        'This is the static frontend for the HolySheet website.',
        'This provides an easy-to-use website interface to manage files from any device.'
      ],
      repoName: 'HolySheetWeb',
      langs: ['HTML', 'Dart']);
  static const HolySheetWebserver = Repo(
      'HolySheet API',
      [
        'The REST API for HolySheet, allowing other applications to manage files.',
        'Provides a distributed solution via Docker and Kubernetes to allow for an extreme amount of users.'
      ],
      repoName: 'HolySheetWebserver',
      langs: ['Dart']);
  static const SheetyGUI = Repo('SheetyGUI', [
    'The Desktop GUI app, written in Flutter to be cross-platform to allow for an easy to use, local solution to manage files.'
  ], langs: [
    'Dart'
  ]);
  static const HolySheetDocs = Repo(
      'Docs', ['The REST API docs to use the public API.'],
      repoName: 'HolySheetDocs', langs: ['Markdown']);

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

  const Repo(this.name, this.description,
      {this.repoName = '', this.langs = const []});
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
}

class BTSDesc {
  static const Upload = BTSDesc('1. Upload the file', [
    'Files are uploaded in 4MB chunks through Websockets, to allow for more stable and controlled sending of data.',
    'Data is sent from the client when the server is done processing the previous data chunk as to conserve server-side power.'
  ]);
  static const Encode = BTSDesc('2. Encode the file', [
    'While the data is being streamed to the HolySheet core, every 10MB recieved will be encoded via a modified Base91 and sent to Google Sheets.'
  ]);
  static const Base91 = BTSDesc('3. Base91', [
    'To encode and decode files, a modified version of Base91 is used. This is similar to encoding a file with Base64, but with most printable characters available, resulting in less overhead.',
    'Characters are replaced from the original spec to allow for easier use with Google Sheets, and broken up into lines of 16,383 (0x3FFF) characters, as to satisfy Google Sheets\' undocumented limits.',
    'The algorithm also turns this data into a CSV file, which is the most efficient way to upload this data in a single request.'
  ]);
  static const Storage = BTSDesc('4. Storage', [
    'All data is stored in a "sheetStore" directory as the roo, with files represented as folders within.',
    'Properties are added to the files for data like data size, sheet count, path, etc. to make listing of files more efficient.',
    'File paths are stored in the properties, with empty folders being stored as a property in the "sheetStore" root, as folders in HolySheet do not reflect folders in Google Drive.'
  ]);
  static const Downloading = BTSDesc('5. Downloading', [
    'Files are downloaded by reconstructing and decoding the Base91 content, writing the data to disk. Once complete, this file is served and deleted soon after.',
  ]);

  static const values = <BTSDesc>[Upload, Encode, Base91, Storage, Downloading];

  final String title;
  final List<String> description;

  const BTSDesc(this.title, this.description);
}
