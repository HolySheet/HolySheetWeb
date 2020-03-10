import 'package:angular/angular.dart';

@Component(
  selector: 'icon',
  templateUrl: 'icon_component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class Icon {
  @Input()
  String icon = '';
}
