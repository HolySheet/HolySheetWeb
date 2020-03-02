import 'package:angular/angular.dart';

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

  ErrorComponent(this.changeRef);
}
