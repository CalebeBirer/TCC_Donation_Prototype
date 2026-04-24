#Transparência de Doações com Blockchain: Protótipo de Rastreabilidade
Este repositório contém o código-fonte e a documentação de um protótipo funcional de um contrato inteligente ("smart contract") desenvolvido para garantir a transparência e a auditabilidade em fluxos de doações financeiras
.
O projeto utiliza a tecnologia "blockchain" para substituir a confiança centralizada por verificações criptográficas imutáveis, permitindo que doadores e auditores acompanhem a destinação dos recursos em tempo real
.
🚀 Objetivo do Projeto
O objetivo central é mitigar a opacidade em transações digitais através de um sistema de governança descentralizada. O protótipo implementa a lógica de assinaturas múltiplas ("multisig"), onde a movimentação de fundos depende da aprovação de um "quórum" mínimo de participantes autorizados
.
🛠️ Tecnologias Utilizadas
Linguagem: "Solidity" (versão ^0.8.20)
.
Ambiente de Desenvolvimento: "Remix IDE"
.
Rede de Testes: "Ethereum Sepolia Testnet"
.
Carteira Digital: "MetaMask" para assinatura criptográfica de transações
.
Explorador de Blocos: "Etherscan" para auditoria pública dos registros
.
📜 Estrutura do Contrato Inteligente
O contrato RastreioMultiSigSimples possui as seguintes funcionalidades principais
:
Governança: Definição de endereços aprovadores e quórum mínimo no momento da implantação (constructor)
.
Criação de Pedidos: Apenas aprovadores podem registrar novas demandas de doação (criarPedido), informando destino, valor e descrição
.
Sistema de Quórum: Registro individual de aprovações (aprovarPedido), impedindo que um mesmo endereço vote duas vezes
.
Execução Automatizada: A transferência dos fundos só é liberada (executarPedido) após o quórum ser atingido e a segurança financeira ser validada
.
Auditabilidade: Emissão de eventos (emit) para rastreio permanente "on-chain" e função de consulta pública (getPedido)
.
📖 Passo a Passo para Execução
Siga estas etapas para compilar, implantar e testar o protótipo:
1. Configuração do Ambiente
Instale a extensão "MetaMask" no seu navegador e crie uma carteira.
Altere a rede para "Sepolia" e obtenha saldo fictício em um "faucet" (torneira de testes)
.
2. Compilação no Remix IDE
Acesse o Remix IDE.
Crie um novo arquivo chamado RastreioMultiSigSimples.sol e cole o código contido na pasta /contracts deste repositório.
No menu lateral, selecione o "Solidity Compiler", defina a versão para 0.8.20 e clique em "Compile"
.
3. Implantação ("Deployment")
Vá para a aba "Deploy & Run Transactions".
No campo "Environment", selecione "Injected Provider - MetaMask".
No botão "Deploy", insira os parâmetros iniciais:
aprovadores_: Uma lista de endereços autorizados (ex: ["0xAddress1", "0xAddress2"]).
quorum_: O número mínimo de assinaturas (ex: 2)
.
Confirme a transação na sua "MetaMask".
4. Testando o Fluxo de Rastreabilidade
Criar Pedido: Use a função criarPedido preenchendo o endereço de destino e o valor em "Wei"
.
Aprovar: Com uma conta autorizada, chame aprovarPedido informando o ID gerado
.
Consultar: A qualquer momento, use getPedido para verificar o status e quantas aprovações foram coletadas
.
Executar: Após atingir o quórum, chame executarPedido para realizar a transferência automática
.
📊 Métricas de Desempenho
Durante os testes, observou-se que a eficiência da "Ethereum Virtual Machine" (EVM) reduz o custo de "gas" em aprovações sucessivas devido ao uso de "slots" de memória já inicializados
:
Função
Custo de Execução (Gas)
Implantação
1.406.910
Criar Pedido
101.407
1ª Aprovação
54.542
2ª Aprovação
37.442 (Redução de ~31%)
⚖️ Licença
Este projeto foi desenvolvido como parte de um Trabalho de Conclusão de Curso (TCC) do MBA USP/Esalq em Engenharia de Software
. O código é distribuído sob a licença MIT
.

--------------------------------------------------------------------------------
Autor: Calebe Ocanha Isacc Birer
