import 'package:angular/angular.dart';

@Component(
  selector: 'error',
  styleUrls: ['error_component.css', '../home/landing_styles.css'],
  templateUrl: 'error_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class ErrorComponent {
}
