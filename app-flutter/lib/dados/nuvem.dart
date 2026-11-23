// Ponte com a nuvem (Fase 6, parte B). O app só conhece [RepositorioNuvem]; quem fala com o Firestore de verdade é
// `nuvem_firestore.dart` (só o `main.dart` importa). Os testes usam [RepositorioNuvemMemoria] e nunca iniciam o Firebase.
//
// SEGURANÇA: a interface só sabe GRAVAR em `saves/{uid}` e `saves/{uid}/historico/{h0..h5,d0..d13}` (o que o
// firestore.rules permite ao dono) e só LER `entitlements/{uid}`. Não existe método para escrever em `entitlements`
// (a regra nega de qualquer jeito), nem em `fcmTokens`/`contadorGlobal` (fora desta fase).
import 'dart:async';

import '../dominio/nuvem.dart';

/// Falha ao falar com a nuvem. [codigo] é o do Firestore (`unavailable`, `permission-denied`, ...) ou `timeout`.
class ErroNuvem implements Exception {
  const ErroNuvem(this.codigo);
  final String codigo;
  @override
  String toString() => 'ErroNuvem($codigo)';
}

abstract class RepositorioNuvem {
  /// `getDoc(saves/{uid})` DO SERVIDOR (nunca do cache: um cache velho decidiria errado). null = documento não existe.
  Future<DocSave?> lerSave(String uid);

  /// `setDoc(saves/{uid}, {data, extras, atualizadoEm, pj})` (substitui o documento inteiro, como o original).
  Future<void> gravarSave(String uid, DocSave doc);

  /// `setDoc(saves/{uid}/historico/{id}, {data, extras, em})`.
  Future<void> gravarHistorico(String uid, String id, {required String data, required Map<String, String> extras, required int em});

  /// `getDoc(entitlements/{uid})`, só leitura. Doc ausente = sem plano.
  Future<PlanoServidor> lerPlano(String uid);

  /// Excluir conta: apaga `saves/{uid}` e todo o histórico (o original só apagava `saves/{uid}`).
  Future<void> apagarTudo(String uid);
}

/// O gancho `apagarNuvem` do excluir conta, com teto de tempo: sem rede (cache offline desligado) o `commit` do batch
/// só termina quando a rede volta, e a folha "Excluir conta" (que não fecha durante a exclusão) ficaria presa. Estourado o
/// limite, o serviço de conta segue (como em qualquer falha do gancho) e o batch, que ficou na fila do Firestore, ainda
/// chega quando a rede voltar.
Future<void> Function(String uid) apagarNuvemComLimite(RepositorioNuvem repo, {Duration limite = const Duration(seconds: 10)}) =>
    (uid) => repo.apagarTudo(uid).timeout(limite);

/// Nuvem falsa em memória (testes). Simula as regras do firestore.rules: com [logado] definido, qualquer acesso a um
/// uid diferente dá `permission-denied`.
class RepositorioNuvemMemoria implements RepositorioNuvem {
  final Map<String, DocSave> saves = {};
  final Map<String, Map<String, ({String data, Map<String, String> extras, int em})>> historico = {};
  final Map<String, PlanoServidor> planos = {};

  /// Quem está logado no "Firebase" falso (null = não confere).
  String? logado;

  /// Toda operação falha com este código enquanto não for null (sem rede, regra...).
  String? falhar;

  /// Só as gravações falham com este código.
  String? falharEscrita;

  /// Se não for null, toda operação espera por ele (rede lenta / escrita em voo).
  Completer<void>? segurar;

  /// Registro em ordem ("ler saves/u1", "gravar saves/u1", "gravar historico/u1/h0", ...).
  final List<String> chamadas = [];
  int get gravacoesSave => chamadas.where((c) => c.startsWith('gravar saves/')).length;
  int get leiturasSave => chamadas.where((c) => c.startsWith('ler saves/')).length;

  Future<void> _passo(String nome, String uid, {bool escrita = false}) async {
    chamadas.add(nome);
    if (segurar != null) await segurar!.future;
    if (falhar != null) throw ErroNuvem(falhar!);
    if (escrita && falharEscrita != null) throw ErroNuvem(falharEscrita!);
    if (logado != null && logado != uid) throw const ErroNuvem('permission-denied');
  }

  @override
  Future<DocSave?> lerSave(String uid) async {
    await _passo('ler saves/$uid', uid);
    return saves[uid];
  }

  @override
  Future<void> gravarSave(String uid, DocSave doc) async {
    await _passo('gravar saves/$uid', uid, escrita: true);
    saves[uid] = DocSave(data: doc.data ?? '', extras: Map.of(doc.extras), atualizadoEm: doc.atualizadoEm, pj: doc.pj);
  }

  @override
  Future<void> gravarHistorico(String uid, String id, {required String data, required Map<String, String> extras, required int em}) async {
    await _passo('gravar historico/$uid/$id', uid, escrita: true);
    (historico[uid] ??= {})[id] = (data: data, extras: Map.of(extras), em: em);
  }

  @override
  Future<PlanoServidor> lerPlano(String uid) async {
    await _passo('ler entitlements/$uid', uid);
    return planos[uid] ?? const PlanoServidor();
  }

  @override
  Future<void> apagarTudo(String uid) async {
    await _passo('apagar saves/$uid', uid, escrita: true);
    saves.remove(uid);
    historico.remove(uid);
  }
}
