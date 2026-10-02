import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tchip/data/models/transaction.dart';
import 'package:tchip/sms/parsers/moov_parser.dart';
import 'package:tchip/sms/parsers/mtn_parser.dart';
import 'package:tchip/sms/parsers/sms_parser.dart';

/// Fixtures: one anonymized real SMS per block, blocks separated by a blank line.
List<String> _fixtures(String name) => File('test/fixtures/sms/$name.txt')
    .readAsStringSync()
    .split(RegExp(r'\n\s*\n'))
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

typedef _Expected = (
  TransactionType type,
  int amount,
  int fee,
  String counterparty,
  String date,
  int balance,
);

const _s = TransactionType.send;
const _r = TransactionType.receive;
const _w = TransactionType.withdrawal;
const _p = TransactionType.payment;
const _b = TransactionType.bundle;

/// Same order as test/fixtures/sms/mtn.txt.
const _mtn = <_Expected>[
  (_r, 12500, 0, 'KOFFI AIME DOSSOU', '2026-09-30 08:12:37', 24998),
  (_p, 2125, 0, 'CANTINE ALPHA P2M', '2026-09-30 10:26:51', 23373),
  (_p, 500, 0, 'BOUTIQUE BETA P2M', '2026-09-30 11:04:24', 22873),
  (_p, 2125, 0, 'CANTINE ALPHA P2M', '2026-10-01 11:50:25', 6748),
  (_s, 1000, 0, 'AFI MARIE HOUNSOU', '2026-10-01 12:29:37', 5748),
  (_p, 3125, 0, 'CANTINE ALPHA P2M', '2026-10-02 09:41:21', 2623),
  (_p, 500, 0, 'BOUTIQUE BETA P2M', '2026-09-30 15:59:13', 22373),
  (_r, 500, 0, 'KOFFI AIME DOSSOU', '2026-09-30 08:16:36', 25498),
  (_w, 2500, 125, 'AGENCE POS GAMMA', '2026-09-29 20:50:46', 12498),
  (_s, 1200, 100, 'SENA JEAN PAUL AGBO', '2026-09-29 19:18:26', 15123),
  (_s, 1500, 100, 'IBRAHIM ALI SALAMI', '2026-09-28 20:42:05', 16423),
  (_w, 2500, 125, 'AGENCE POS GAMMA', '2026-09-28 19:52:31', 18023),
  (_s, 1200, 100, 'SENA JEAN PAUL AGBO', '2026-09-28 17:57:50', 20648),
  (_r, 27000, 0, 'KOFFI AIME DOSSOU', '2026-09-27 08:32:43', 27273),
  (_r, 5000, 0, 'ROMEO KODJO ZINSOU', '2026-09-21 13:11:07', 27698),
  (_s, 3300, 100, 'YASMINE BELLO', '2026-09-21 22:10:31', 18698),
  (_s, 1325, 100, 'CODJO MARC ANTOINE JUNIOR HOUNKPE', '2026-09-22 17:49:43', 15148),
  (_s, 1325, 100, 'SENA JEAN PAUL AGBO', '2026-09-22 17:52:22', 13723),
  (_w, 2000, 125, 'MAMA ET FILS (IFU) DELTA', '2026-09-22 21:21:07', 11598),
  (_s, 725, 100, 'EDGAR SEDJRO AHOUANDJINOU', '2026-09-23 09:12:34', 10773),
  (_b, 1000, 0, 'BUY DATA', '2026-07-23 17:21:02', 14431),
  (_p, 5000, 50, 'MFS DIRECT SBEE', '2026-08-08 23:30:07', 8291),
];

/// Same order as test/fixtures/sms/moov.txt.
const _moov = <_Expected>[
  (_w, 3000, 125, 'EPSILON', '2026-08-11 13:07:15', 210),
  (_r, 3300, 0, 'AHOUEFA ROSE MARIE CHRISTELLE', '2026-08-09 18:41:26', 3335),
  (_w, 1000, 125, 'ZETA-TELECOM 2', '2026-08-01 14:09:02', 35),
  (_r, 1100, 0, 'AHOUEFA ROSE MARIE CHRISTELLE', '2026-08-01 13:18:51', 1110),
];

void _checkOperator(String name, SmsParser parser, List<_Expected> expected) {
  group(name, () {
    final sms = _fixtures(name);

    test('fixture count matches the expected table', () {
      expect(sms.length, expected.length);
    });

    for (var i = 0; i < expected.length; i++) {
      final e = expected[i];
      test('#${i + 1} ${e.$1.name} ${e.$2} F', () {
        final t = parser.parse(sms[i]);
        expect(t, isNotNull, reason: sms[i]);
        expect(t!.operator, parser.operator);
        expect(t.type, e.$1);
        expect(t.amount, e.$2);
        expect(t.fee, e.$3);
        expect(t.counterparty, e.$4);
        expect(t.date, DateTime.parse(e.$5.replaceFirst(' ', 'T')));
        expect(t.balance, e.$6);
        expect(t.reference, isNotNull);
        expect(t.rawSms, sms[i]);
        expect(t.source, TransactionSource.sms);
      });
    }

    test('recognition rate above 95 %', () {
      final ok = sms.where((s) => parser.parse(s) != null).length;
      expect(ok / sms.length, greaterThan(0.95));
    });
  });
}

void main() {
  _checkOperator('mtn', const MtnParser(), _mtn);
  _checkOperator('moov', const MoovParser(), _moov);

  group('non-transaction SMS are ignored', () {
    const noise = [
      'Votre code de confirmation MoMo est 482913. Ne le partagez avec personne.',
      'Felicitations ! Vous avez gagne 500 Mo de bonus internet.',
      'Votre solde est de 12 500 FCFA. Merci d’utiliser Moov Money.',
    ];
    for (final s in noise) {
      test(s.substring(0, 30), () {
        expect(const MtnParser().parse(s), isNull);
        expect(const MoovParser().parse(s), isNull);
      });
    }
  });

  test('Moov transfer to a person is a send, not a withdrawal', () {
    const sms =
        'Vous avez envoye 2 000 FCFA à KOFFI AIME DOSSOU 2290110000000 '
        'le 12/10/2026 09:00:00. FRAIS: 50 FCFA.';
    final t = const MoovParser().parse(sms)!;
    expect(t.type, TransactionType.send);
    expect(t.counterparty, 'KOFFI AIME DOSSOU');
    expect(t.fee, 50);
  });
}
