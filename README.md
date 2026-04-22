# Transparência de Doações com Blockchain: Protótipo de Rastreabilidade

Este repositório contém o código-fonte e a documentação do protótipo desenvolvido para o Trabalho de Conclusão de Curso (TCC) do **MBA em Engenharia de Software** da **USP/Esalq** (Ano: 2026).

---

## 📌 Contexto e Problema

O projeto aborda o desafio da transparência em sistemas de doações. Embora muitas organizações façam trabalhos essenciais, a falta de visibilidade sobre o fluxo financeiro pode gerar desconfiança nos doadores.

A blockchain é uma solução imutável e descentralizada, mas apresenta o desafio do pseudonimato (dificuldade de identificar quem está por trás dos endereços). Este projeto propõe o uso de **Smart Contracts** e governança **Multisig (Multi-assinatura)** para resolver este problema técnico e demonstrar a viabilidade de um fluxo de doação auditável *on-chain*.

## 🎯 Objetivo

Desenvolver e validar um protótipo experimental que permita:

1.  **Rastrear** a entrada e saída de doações.
2.  **Garantir** a transparência total do fluxo financeiro.
3.  **Permitir** a auditoria pública e descentralizada.
4.  **Demonstrar** a viabilidade econômica do modelo através da análise de custos de *gas*.

## 🛠️ Tecnologias e Arquitetura

O protótipo foi construído utilizando as seguintes tecnologias:

* **Solidity:** Linguagem de programação para os Smart Contracts (EVM compatível).
* **Ethereum Testnet (Sepolia):** Ambiente de teste para simulação em rede pública real.
* **Remix IDE:** Ambiente de desenvolvimento para compilação, testes e *deploy*.
* **MetaMask:** Carteira para interação com a rede Sepolia e gerenciamento de ETH fictício.
* **Mecanismo:** Governança baseada em Multisig (requer $N$ de $M$ aprovadores pré-definidos).

### Estrutura do Protótipo (Funções Principais)

O contrato `RastreioMultiSigSimples.sol` implementa:

| Função | Descrição |
| :--- | :--- |
| `criarPedido` | Registra uma nova solicitação de doação (destino, valor, descrição). |
| `aprovarPedido` | Permite que um aprovador autorizado assine o pedido. |
| `executarPedido` | Transfere os fundos *após* atingir o quórum de aprovações necessário. |
| `getPedido` | Função pública para auditoria em tempo real de qualquer pedido. |

## 📊 Métricas Coletadas

Para análise de viabilidade, foram coletadas métricas reais de consumo de *gas* (medida de esforço computacional na EVM) durante os testes na rede Sepolia (usando 1 Gwei como Gas Price Base).

*Consulte a seção de 'Resultados' na documentação completa para gráficos comparativos de custos.*

## 🚀 Como Executar o Protótipo

Para testar o protótipo no Remix IDE, siga os passos abaixo:

1.  Acesse o [Remix IDE](https://remix.ethereum.org/).
2.  Crie um novo arquivo `.sol` e cole o código do arquivo `contracts/RastreioMultiSigSimples.sol`.
3.  Compile o contrato (certifique-se de usar a versão correta do compilador).
4.  No campo `Deploy & Run Transactions`, selecione o ambiente `Injected Provider - MetaMask`.
5.  Certifique-se de que sua MetaMask está conectada na rede **Sepolia** e possui saldo de ETH fictício (você pode obter em *faucets*).
6.  No `Deploy`, defina o número mínimo de assinaturas necessárias (quórum) e o array de endereços dos aprovadores (ex: `["0x123...", "0x456..."]`).
7.  Clique em `Transact` para fazer o *deploy* e interaja com as funções.

## ⚠️ Limitações e Trabalhos Futuros

O protótipo demonstrou a rastreabilidade on-chain, mas possui as seguintes limitações:

* **Pseudonimato:** A blockchain rastreia o endereço, não a identidade civil. A confiança reside na camada de governança dos aprovadores (Multisig).
* **Custo de Escrita:** A operação `SSTORE` (gravação de dados) na EVM é a mais cara, o que reflete no custo de Gas da ONG.
* **Melhoria Futura:** Desenvolvimento de um sistema dinâmico onde doadores relevantes possam ser incluídos na lista de aprovadores após auditoria.

## 👤 Autor

* **Calebe Birer** - [https://www.linkedin.com/in/calebe-birer/]
* **Orientador - Luciano Bergamo** [https://www.linkedin.com/in/luciano-b%C3%A9rgamo-3373b2114/]

## 📝 Licença

Este projeto está licenciado sob a licença MIT - consulte o arquivo `LICENSE` para detalhes.
