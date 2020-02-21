import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';

@Injectable()
class ContextService {
  final contextMenus = <Context>[];

  StreamSubscription _contextMenuSub;
  StreamSubscription _clickSub;

  List<Context> get contextShowing =>
      contextMenus.where((context) => context.showing).toList();

  // The ID of the file that has the context menu for it, if any
  String _fileContextId;
  String get fileContextId => _fileContextId;

  void init() {
    _contextMenuSub = document.onContextMenu.listen((event) {
      HtmlElement currElement = event.target;
      _fileContextId = null;
      do {
        if (_activateContext(event, currElement)) {
          return;
        }

        currElement = currElement.parent;
      } while (currElement != null);
    });

    _clickSub = document.onClick.listen((event) {
      final clicked = event.target as HtmlElement;

      var clickedOn = contextShowing.firstWhere(
          (context) =>
              document
                  .querySelector(context.contextSelector)
                  ?.contains(clicked) ??
              false,
          orElse: () => null);

      if (clickedOn != null) {
        // Clicked on a context menu
        return;
      }

      var clickedButton = contextMenus
          .where((context) => context.buttonSelector != null)
          .firstWhere(
              (context) => document
                  .querySelector(context.buttonSelector)
                  ?.contains(clicked) ?? false,
              orElse: () => null);

      if (clickedButton != null) {
        _activeDropdown(clickedButton);
        return;
      }

      // Clicked in an insignificant area
      for (var context in contextShowing) {
        context.showing = false;
      }
    });
  }

  void _activeDropdown(Context context) {
    if (!(context.showing = !context.showing)) {
      return;
    }

    final button = document.querySelector(context.buttonSelector);
    final dropdown = document.querySelector(context.contextSelector);

    var height = button.clientHeight;
    var width = button.clientWidth;

    var top = button.offset.top;
    var left = button.offset.left;

    var dropdownHeight = dropdown.clientHeight;
    var dropdownWidth = dropdown.clientWidth;

    var documentHeight = document.body.clientHeight;
    var documentWidth = document.body.clientWidth;

    if (top + height + dropdownHeight > documentHeight) {
      dropdown.style.top = '${top - dropdownHeight}px';
    } else {
      dropdown.style.top = '${top + height}px';
    }

    if (left + dropdownWidth > documentWidth) {
      dropdown.style.left = '${left + width - dropdownWidth}px';
    } else {
      dropdown.style.left = '${left}px';
    }

    context.showing = true;
  }

  bool _activateContext(MouseEvent event, HtmlElement target) {
    if (!target.matches('.contextmenu-toggle')) {
      return false;
    }

    final context = getContextMenu(target.getAttribute('data-contextName'));

    if (context == null) {
      return false;
    }

    var contextNode = document.querySelector(context.contextSelector);

    if (contextNode == null) {
      // True as going up a parent won't do anything
      return true;
    }

    event.preventDefault();

    for (var context in contextShowing) {
      context.showing = false;
    }

    if (!(context.showing = !context.showing)) {
      return true;
    }

    _fileContextId = target.getAttribute('data-id');

    var x = event.page.x;
    var y = event.page.y;

    var dropdownHeight = contextNode.clientHeight;
    var dropdownWidth = contextNode.clientWidth;

    var documentHeight = document.body.clientHeight;
    var documentWidth = document.body.clientWidth;

    if (y + dropdownHeight > documentHeight) {
      contextNode.style.top = '${y - dropdownHeight}px';
    } else {
      contextNode.style.top = '${y}px';
    }

    if (x + dropdownWidth > documentWidth) {
      contextNode.style.left = '${x - dropdownWidth}px';
    } else {
      contextNode.style.left = '${x}px';
    }

    context.showing = true;
    context.onShowContext?.call(_fileContextId);

    return true;
  }

  void hideContext() {
    for (var context in contextShowing) {
      context.showing = false;
    }
  }

  void destroy() {
    _contextMenuSub?.cancel();
    _clickSub?.cancel();
  }

  void registerContext(String name, String selector, {String buttonSelector, Function(String) onShowContext}) {
    contextMenus.removeWhere((context) => context.name == name);

    contextMenus.add(Context(name, selector, buttonSelector, onShowContext));
  }

  Context getContextMenu(String name) => name == null
      ? null
      : contextMenus.firstWhere((context) => context.name == name,
          orElse: () => null);
}

class Context {
  final String name;
  final String contextSelector;
  final String buttonSelector;
  Function(String) onShowContext; // Gives the file ID

  bool _showing = false;

  bool get showing => _showing;

  set showing(value) {
    if (value != _showing) {
      var node = document.querySelector(contextSelector);
      if (value) {
        node.classes.add('context-display');
      } else {
        node.classes.remove('context-display');
      }
      _showing = value;
    }
  }

  Context(this.name, this.contextSelector, this.buttonSelector, [this.onShowContext]);
}
