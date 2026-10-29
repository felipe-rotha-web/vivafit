# AppVivaFit - Documentação Completa

## 📱 Descrição do Aplicativo

**AppVivaFit** é um aplicativo Flutter completo de saúde e bem-estar que ajuda os usuários a manter uma vida saudável através de tracking de atividades, metas, pontos e desafios personalizados.

---

## 🎯 Funcionalidades Implementadas

### 1. **Tela de Welcome (Inicial)**
- Logo do AppVivaFit com design moderno
- Nome e subtítulo do aplicativo
- Dois botões principais:
  - **Login** - Para usuários existentes
  - **Cadastrar Usuário** - Para novos usuários

**Arquivo:** `lib/src/pages/welcome_page.dart`

---

### 2. **Tela de Login**
**Campos:**
- Nome de Usuário
- Senha (com toggle de visibilidade)

**Funcionalidades:**
- Validação de campos obrigatórios
- Mostrar/ocultar senha
- Link "Esqueceu sua senha?"
- Loading ao fazer login
- Navegação para Home após login bem-sucedido

**Arquivo:** `lib/src/pages/login_page.dart`

---

### 3. **Tela de Cadastro de Usuário**
**Campos obrigatórios:**
- Nome Completo
- Idade
- Gênero (Masculino, Feminino, Outro)
- Nível de Atividade (Sedentário, Leve, Moderado, Intenso, Muito Intenso)
- Senha
- Confirmar Senha

**Funcionalidades:**
- Validação de senha mínima (6 caracteres)
- Verificação se senhas conferem
- Mostrar/ocultar senhas
- Mensagens de feedback
- Navegação para Home após cadastro

**Arquivo:** `lib/src/pages/cad_user_page.dart`

---

### 4. **Home Page (Dashboard Principal)**
Tela central com:
- Card de saudação com progresso diário (65% exemplo)
- **Grid de Estatísticas:**
  - Pontos: 1250
  - Hidratação: 2L / 3L
  - Tarefas: 13/20
  - Dias Intensivos: 7/10
- **Ações Rápidas:**
  - Botão "Ver Desafios Semanais"
  - Botão "Calcular Peso"
- Navegação via Bottom Navigation Bar

**Arquivo:** `lib/src/pages/home_page.dart`

---

### 5. **Cronograma Diário (Agenda de Tarefas)**
**Funcionalidades:**
- Lista de tarefas do dia com:
  - Título da atividade
  - Horário
  - Ícone representativo
  - Checkbox para marcar como concluída
- Resumo de progresso do dia (57% exemplo)
- Botão para adicionar nova tarefa
- Tarefas pré-carregadas como exemplo:
  - Academia - Treino de Perna
  - Café da manhã saudável
  - Meditação matinal
  - E mais...

**Arquivo:** `lib/src/pages/cronograma_page.dart`

---

### 6. **Sistema de Anotações**
**Funcionalidades:**
- Adicionar novas anotações (título + conteúdo)
- Lista de anotações anteriores com:
  - Título
  - Conteúdo
  - Data da anotação
- Deletar anotações (pressione e segure)
- Feedback visual ao adicionar/remover

**Arquivo:** `lib/src/pages/anotacoes_page.dart`

---

### 7. **Sistema de Lembretes**
**Funcionalidades:**
- Lista de lembretes com:
  - Título do lembrete
  - Horário
  - Toggle ativar/desativar
  - Tipo (Diário ou Única)
- Botão para criar novo lembrete
- Notificações (estrutura pronta para integração)
- Lembretes pré-carregados

**Arquivo:** `lib/src/pages/lembretes_page.dart`

---

### 8. **Sistema de Dias Intensivos**
**Funcionalidades:**
- Contador de dias intensivos (7/10 exemplo)
- Barra de progresso visual
- Botão "Registrar Dia Intensivo" (+1)
- Histórico de dias intensivos com:
  - Data
  - Dia da semana
  - Atividades realizadas
  - Status (concluído/não concluído)

**Arquivo:** `lib/src/pages/dias_intensivos_page.dart`

---

### 9. **Sistema de Pontuação e Metas**
**Funcionalidades:**
- Pontuação total (1250 pontos exemplo)
- Meta semanal com progresso (320/500)
- **Metas Identificadas:**
  - Meta de Exercício (100 pontos)
  - Meta de Hidratação (50 pontos)
  - Meta de Meditação (75 pontos)
  - E mais...
- **Histórico de Tarefas Concluídas** com pontos ganhos
- Identificação automática de metas cumpridas
- Sistema de recompensas

**Arquivo:** `lib/src/pages/pontuacao_page.dart`

---

### 10. **Desafios Semanais**
**Funcionalidades:**
- **Desafios Ativos:**
  - Semana Fitness (3/5)
  - Hidratação Extrema (6/7)
  - Meditador Semanal (4/7)
- **Desafios Disponíveis:**
  - Super Atleta (7/10)
- Nível de dificuldade (Fácil, Média, Difícil, Muito Difícil)
- Progresso visual com barras
- Pontos de recompensa por desafio
- Ativar novos desafios

**Arquivo:** `lib/src/pages/desafios_page.dart`

---

### 11. **Página de Perfil**
**Informações Pessoais:**
- Avatar do usuário
- Nome
- Nível de atividade

**Informações Exibidas:**
- Gênero
- Idade
- Nível de Atividade

**Seção de Saúde - Calculadora de Peso:**
- Peso Atual
- Meta de Peso
- Diferença
- Botão "Calcular Peso" (formulário)

**Configurações:**
- Editar Perfil
- Privacidade
- Notificações
- Sobre

**Botão Sair (com confirmação)**

**Arquivo:** `lib/src/pages/perfil_page.dart`

---

### 12. **Tutoriais**
**Funcionalidades:**
- Lista de tutoriais sobre atividades
- Informações:
  - Título
  - Descrição
  - Duração
  - Nível de dificuldade
  - Ícone
- Modal com conteúdo do tutorial
- Botão "Assistir Tutorial"

**Tutoriais Inclusos:**
- Como começar seu treino
- Técnicas de Meditação
- Nutrição Adequada
- Hidratação e Saúde
- Recuperação Muscular

**Arquivo:** `lib/src/pages/tutoriais_page.dart`

---

## 🎨 Design e Cores

**Paleta de Cores Principal:**
- **Roxo Escuro:** `#6A4C93` (Cor Primária)
- **Roxo Médio:** `#8B6BA3` (Cor Secundária)
- **Branco:** `#FFFFFF` (Fundo)
- **Cores Temáticas:**
  - Verde: Sucesso/Completo
  - Laranja: Pendente/Médio
  - Vermelho: Intenso/Crítico
  - Azul: Informação
  - Amarelo: Pontos/Recompensas

---

## 📁 Estrutura de Arquivos

```
lib/
├── main.dart
└── src/
    ├── app.dart (Configuração principal)
    └── pages/
        ├── welcome_page.dart
        ├── login_page.dart
        ├── cad_user_page.dart
        ├── home_page.dart
        ├── cronograma_page.dart
        ├── anotacoes_page.dart
        ├── lembretes_page.dart
        ├── dias_intensivos_page.dart
        ├── pontuacao_page.dart
        ├── desafios_page.dart
        ├── perfil_page.dart
        └── tutoriais_page.dart
```

---

## 🚀 Como Usar

### Fluxo Inicial
1. **App abre em WelcomePage**
2. Usuário clica em **Login** ou **Cadastro**
3. Após autenticação, vai para **HomePage** (Dashboard)
4. Uso da Bottom Navigation para acessar outras abas

### Navegação Principal
- **Home**: Dashboard com estatísticas
- **Cronograma**: Gerenciar tarefas diárias
- **Anotações**: Anotar observações
- **Lembretes**: Gerenciar notificações
- **Perfil**: Visualizar e editar dados

---

## 💡 Funcionalidades Principais Resumidas

| Funcionalidade | Status | Descrição |
|---|---|---|
| Tela de Welcome | ✅ Completo | Logo, nome e botões |
| Login | ✅ Completo | Campo nome + senha |
| Cadastro | ✅ Completo | Todos os campos obrigatórios |
| Dashboard | ✅ Completo | Estatísticas e ações rápidas |
| Cronograma | ✅ Completo | Agenda com checklist |
| Anotações | ✅ Completo | CRUD básico |
| Lembretes | ✅ Completo | Lista com toggle |
| Dias Intensivos | ✅ Completo | Sistema de contagem |
| Pontuação | ✅ Completo | Metas e pontos |
| Desafios | ✅ Completo | Semanais com dificuldade |
| Perfil | ✅ Completo | Info pessoal + calculadora peso |
| Tutoriais | ✅ Completo | Educação sobre atividades |

---

## 🔧 Tecnologias Utilizadas

- **Framework:** Flutter
- **Linguagem:** Dart
- **Design Pattern:** StatefulWidget/StatelessWidget
- **Navegação:** MaterialPageRoute / BottomNavigationBar
- **UI Components:** Material Design 3

---

## 📝 Notas Importantes

1. **Dados em Memória:** Os dados são armazenados em memória (StatefulWidget). Para persistência real, integre um banco de dados como SQLite ou Firebase.

2. **Autenticação:** O login/cadastro são simulados. Para autenticação real, use Firebase Authentication ou similar.

3. **Notificações:** A estrutura está pronta, mas precisa integração com push notifications (firebase_messaging).

4. **Responsividade:** Layout é responsivo para diferentes tamanhos de tela.

5. **Customização:** Todos os cores, textos e dados podem ser facilmente customizados.

---

## 🎓 Próximas Melhorias Sugeridas

1. Integrar banco de dados local (SQLite)
2. Autenticação real (Firebase)
3. Notificações push
4. Gráficos e análises
5. Sincronização com web
6. Modo escuro
7. Múltiplos idiomas
8. Social features (compartilhar desafios)

---

**Versão:** 1.0.0  
**Última Atualização:** 17 de Abril, 2026

---

## 📞 Suporte

Para dúvidas sobre a implementação, consulte os comentários nos arquivos .dart ou acesse a documentação oficial do Flutter.
