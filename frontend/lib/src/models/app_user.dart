
// Classe AppUser representa um componente ou widget da interface.
class AppUser {
  const AppUser({
    required this.nome,
    required this.senha,
    required this.idade,
    required this.genero,
    required this.nivelAtividade,
    this.email = '',
    this.id,
    this.peso,
    this.altura,
  });

  final int? id;
  final String nome;
  final String email;
  final String senha;
  final int idade;
  final String genero;
  final String nivelAtividade;
  final double? peso;
  final double? altura;
}

