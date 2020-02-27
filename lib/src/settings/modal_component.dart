import 'package:angular/angular.dart';

@Component(
  selector: 'hs-modal',
  styleUrls: ['modal_component.css'],
  templateUrl: 'modal_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class HSModalComponent {
  final ChangeDetectorRef changeRef;

  String title;
  Map<String, dynamic> content = {};
  Function() onConfirm;
  Function() onCancel;

  bool _show = false;

  set show(value) {
    _show = value;
    changeRef.markForCheck();
  }

  bool get show => _show;

  HSModalComponent(this.changeRef);

  void cancel() {
    show = false;
    onCancel?.call();
  }

  void confirm() {
    show = false;
    onConfirm?.call();
  }

  void openPrompt({Map<String, dynamic> content = const {}, Function() onConfirm, Function() onCancel}) {
    this.content = content;
    this.onConfirm = onConfirm;
    this.onCancel = onCancel;
    show = true;
    changeRef.markForCheck();
  }

  @override
  operator [](key) => content[key];
}
