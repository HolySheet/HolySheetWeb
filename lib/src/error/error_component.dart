import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'error',
  styleUrls: ['error_component.css'],
  templateUrl: 'error_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class ErrorComponent {
  final ChangeDetectorRef changeRef;

  String text = '-';

  ErrorComponent(this.changeRef) {
      text = '404! Uh oh!';
  }
}
