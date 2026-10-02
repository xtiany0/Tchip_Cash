import '../../data/models/transaction.dart';
import 'sms_parser.dart';

/// Celtiis Cash. No real SMS sample yet, so no format is recognised.
/// Add the formats with their fixtures in test/fixtures/sms/celtiis.txt.
class CeltiisParser extends SmsParser {
  const CeltiisParser();

  @override
  Operator get operator => Operator.celtiis;

  @override
  Transaction? parse(String body) => null;
}
