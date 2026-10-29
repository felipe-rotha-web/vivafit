## 🚀 GUIA RÁPIDO DE USO - AppVivaFit

### ⚡ Início Rápido

1. **Abra o terminal** na pasta do projeto:
   ```bash
   cd c:\Users\Etec\Desktop\appvivafit
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Execute o app**:
   ```bash
   flutter run
   ```

---

## 📱 Fluxo do Aplicativo

### **Tela 1: Welcome (Boas-vindas)**
```
┌─────────────────────┐
│    AppVivaFit       │
│   [Logo]            │
│                     │
│  [Login]            │
│  [Cadastro]         │
└─────────────────────┘
```

### **Tela 2: Login ou Cadastro**

**Login:**
- Nome de Usuário
- Senha (com toggle)
- Botão "Login"

**Cadastro:**
- Nome Completo
- Idade
- Gênero (dropdown)
- Nível Atividade (dropdown)
- Senha + Confirmar Senha
- Botão "Cadastrar"

### **Tela 3: Home (Dashboard)**
```
┌──────────────────────────┐
│  Bem-vindo! 65% completo │
├──────────────────────────┤
│ Pontos(1250) │ Hidr(2L)  │
│ Tarefas(13) │ Dias(7)   │
├──────────────────────────┤
│ [Ver Desafios]           │
│ [Calcular Peso]          │
└──────────────────────────┘
```

### **Navegação Inferior (Bottom Nav)**
- 🏠 **Home** - Dashboard principal
- 📅 **Cronograma** - Tarefas do dia
- 📝 **Anotações** - Notas rápidas
- 🔔 **Lembretes** - Notificações
- 👤 **Perfil** - Seus dados

---

## 📄 Páginas Disponíveis

### 1. **Cronograma** (📅)
- Veja todas as tarefas do dia
- Marque com ✅ ao concluir
- Veja progresso (57%)
- Adicione novas tarefas

### 2. **Anotações** (📝)
- Clique em "Nova Anotação"
- Digite título + conteúdo
- Pressione e segure para deletar

### 3. **Lembretes** (🔔)
- Ative/desative lembretes
- Veja horários
- Tipo: Diário ou Única

### 4. **Perfil** (👤)
- Veja suas informações
- **Calculadora de Peso:**
  - Digite peso atual
  - Digite meta de peso
  - Sistema calcula diferença
- Clique em "Sair" para fazer logout

### 5. **Pontuação** (⭐)
- Total de pontos: 1250
- Meta semanal: 320/500
- Metas ativas (clique em qualquer stat)
- Histórico de tarefas concluídas

### 6. **Desafios** (🏆)
- **Desafios Ativos:**
  - Semana Fitness
  - Hidratação Extrema
  - Meditador Semanal
- **Desafios Disponíveis:**
  - Super Atleta (clique em "Ativar")
- Nível: Fácil, Médio, Difícil, Muito Difícil

### 7. **Dias Intensivos** (🔥)
- Contador: 7/10
- Barra de progresso
- Clique em "Registrar Dia Intensivo" (+1)
- Veja histórico de dias

---

## 🎮 Como Testar

### **Teste 1: Login Básico**
1. Na Welcome, clique "Login"
2. Digite qualquer nome
3. Digite qualquer senha (min 6 chars)
4. Verá Dashboard

### **Teste 2: Cadastro**
1. Na Welcome, clique "Cadastrar"
2. Preencha todos os campos
3. Confirme a senha (deve ser igual)
4. Clique "Cadastrar"
5. Verá Dashboard

### **Teste 3: Cronograma**
1. No Dashboard, clique "Cronograma" (📅)
2. Veja tarefas do dia
3. Marque com ✅ as que fez
4. Veja progresso atualizar

### **Teste 4: Adicionar Anotação**
1. Clique "Anotações" (📝)
2. Clique "Nova Anotação"
3. Digite título: "Meu Treino"
4. Digite conteudo: "Fiz 10 séries"
5. Clique "Adicionar"
6. Pressione a anotação para deletar

### **Teste 5: Calcular Peso**
1. Clique "Perfil" (👤)
2. Clique "Calcular Peso"
3. Digite peso atual: 75.5
4. Digite meta: 70
5. Sistema mostra diferença: 5.5 kg

---

## 🎨 Cores no Aplicativo

- 🟣 **Roxo (#6A4C93)** - Principal, botões, títulos
- ⚪ **Branco** - Fundo de cards
- 🟢 **Verde** - Completo, sucesso
- 🟠 **Laranja** - Progresso, médio
- 🔴 **Vermelho** - Intenso, sair
- 🔵 **Azul** - Informação
- 🟡 **Amarelo** - Pontos, estrelas

---

## ❓ Dúvidas Frequentes

**P: Como faço login?**
R: Digite qualquer nome e senha (mín 6 caracteres). O app aceitará!

**P: Meus dados são salvos?**
R: Não, os dados são salvos em memória. Se fechar o app, será resetado.

**P: Como adiciono tarefas?**
R: Vá para Cronograma > clique "Adicionar Tarefa"

**P: Como marco pontos?**
R: Completa uma tarefa no Cronograma e ganha pontos automaticamente.

**P: Posso adicionar desafios?**
R: Sim! Em Desafios, clique "Ativar" em um desafio disponível.

---

## 📋 Checklist de Funcionalidades

- ✅ Tela Welcome com Logo
- ✅ Login e Cadastro
- ✅ Dashboard (Home)
- ✅ Cronograma com Checklist
- ✅ Anotações (add/delete)
- ✅ Lembretes (toggle on/off)
- ✅ Dias Intensivos (+1)
- ✅ Pontuação e Metas
- ✅ Desafios Semanais
- ✅ Perfil + Calculadora Peso
- ✅ Tutoriais
- ✅ Bottom Navigation
- ✅ Design Responsivo

---

## 🛠️ Customizar

### Mudar Cores
Abra `lib/src/app.dart` e altere:
```dart
Color(0xFF6A4C93) → Cor desejada
```

### Mudar Dados Padrão
Cada página tem uma lista de exemplos. Edite em `_` vars no topo da classe.

### Adicionar Nova Página
1. Crie novo arquivo: `nova_page.dart`
2. Estenda `StatefulWidget`
3. Adicione ao Bottom Navigation

---

**Aproveite seu AppVivaFit! 🎉**

*Para mais info: veja FUNCIONALIDADES.md*
