import 'package:flutter_test/flutter_test.dart';
import 'package:banca_do_palpite/core/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parseia todos os campos', () {
      final json = {
        'id': 'user-1',
        'name': 'Rafael',
        'email': 'r@t.com',
        'avatarUrl': 'https://example.com/avatar.png',
        'provider': 'google',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.name, 'Rafael');
      expect(user.email, 'r@t.com');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.provider, 'google');
    });

    test('campos opcionais nulos são permitidos', () {
      final json = {'id': 'u1', 'name': 'X', 'email': 'x@t.com'};
      final user = UserModel.fromJson(json);

      expect(user.avatarUrl, isNull);
      expect(user.provider, 'email'); // default
    });
  });

  group('UserModel.toJson', () {
    test('serializa corretamente', () {
      const user = UserModel(id: 'u1', name: 'X', email: 'x@t.com');
      final json = user.toJson();

      expect(json['id'], 'u1');
      expect(json['name'], 'X');
      expect(json['email'], 'x@t.com');
    });
  });

  group('UserModel.copyWith', () {
    test('atualiza nome mantendo os outros campos', () {
      const user = UserModel(id: 'u1', name: 'Antigo', email: 'x@t.com');
      final updated = user.copyWith(name: 'Novo');

      expect(updated.name, 'Novo');
      expect(updated.id, 'u1');
      expect(updated.email, 'x@t.com');
    });
  });
}
