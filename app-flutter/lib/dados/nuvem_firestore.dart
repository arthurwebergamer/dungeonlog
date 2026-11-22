// Nuvem de verdade: Cloud Firestore do projeto `questlog-d4c11` (o mesmo do app HTML). Só o `main.dart` importa este
// arquivo (os testes não). Caminhos e campos: ver lib/dominio/nuvem.dart.
//
// - Leitura do save sempre do SERVIDOR (`Source.server`): sem rede dá erro e o jogo segue local (nunca decide com cache).
// - Cache offline do Firestore desligado (ver [desligarCacheOffline]): uma gravação feita sem rede NÃO fica escondida
//   numa fila do plugin que poderia subir depois de "Sair" ou de outra conta entrar; quem guarda o que falta subir é o
//   marcador `questlog.sujo.v1.uid.<uid>` do próprio app, que tenta de novo.
// - Nada aqui escreve em `entitlements` (a regra nega; ver firestore.rules).
import 'package:cloud_firestore/cloud_firestore.dart';

import '../dominio/nuvem.dart';
import 'nuvem.dart';

class RepositorioNuvemFirestore implements RepositorioNuvem {
  RepositorioNuvemFirestore([FirebaseFirestore? db]) : _dbFixo = db;
  final FirebaseFirestore? _dbFixo;
  FirebaseFirestore get _db => _dbFixo ?? FirebaseFirestore.instance;

  /// Chamar uma vez logo depois de `Firebase.initializeApp`, antes de qualquer leitura/gravação.
  static void desligarCacheOffline() {
    try {
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
    } catch (_) {}
  }

  DocumentReference<Map<String, dynamic>> _save(String uid) => _db.collection('saves').doc(uid);

  Future<T> _traduz<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on FirebaseException catch (e) {
      throw ErroNuvem(e.code);
    } on ErroNuvem {
      rethrow;
    } catch (_) {
      throw const ErroNuvem('desconhecido');
    }
  }

  @override
  Future<DocSave?> lerSave(String uid) => _traduz(() async {
        final s = await _save(uid).get(const GetOptions(source: Source.server));
        final m = s.data();
        return s.exists && m != null ? docSaveDeMapa(m) : null;
      });

  @override
  Future<void> gravarSave(String uid, DocSave doc) => _traduz(() => _save(uid).set(doc.paraMapa()));

  @override
  Future<void> gravarHistorico(String uid, String id, {required String data, required Map<String, String> extras, required int em}) =>
      _traduz(() => _save(uid).collection('historico').doc(id).set({'data': data, 'extras': extras, 'em': em}));

  @override
  Future<PlanoServidor> lerPlano(String uid) => _traduz(() async {
        final s = await _db.collection('entitlements').doc(uid).get(const GetOptions(source: Source.server));
        return planoDeMapa(s.exists ? s.data() : null);
      });

  @override
  Future<void> apagarTudo(String uid) => _traduz(() async {
        final b = _db.batch();
        for (final id in idsHistorico) {
          b.delete(_save(uid).collection('historico').doc(id));
        }
        b.delete(_save(uid));
        await b.commit();
      });
}
