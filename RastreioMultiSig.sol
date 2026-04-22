// SPDX-License-Identifier: MIT  -- uint overflows and underflows automatic revert
pragma solidity ^0.8.20;

contract RastreioMultiSig {
    mapping(address => bool) public ehAprovador;  //lista “set” de quem pode agir no contrato
    uint256 public quorumMinimo; //número mínimo de aprovações para executar um pedido -- como e publico o solidity cria getters automaticamente

    struct Pedido {
        address destino; //para onde o contrato vai mandar ETH
        uint256 valorWei; // valor em wei (1 ETH = 1e18 wei)
        string descricao; // texto livre (custo de armazenamento/gas maior)
        uint256 aprovacoes; // contador de aprovações
        bool executado; // trava para não executar duas vezes
    }

    Pedido[] public pedidos; //  array com todos os pedidos (IDs são os índices: 0,1,2,...)
    mapping(uint256 => mapping(address => bool)) public aprovou; // controla se um aprovador já aprovou aquele pedido, isso impede “votar 2x”.

    event PedidoCriado(uint256 id, address criador, address destino, uint256 valorWei, string descricao); // emite dados do pedido e criador
    event PedidoAprovado(uint256 id, address aprovador, uint256 aprovacoesAtuais); // mostra quem aprovou e total atual
    event PedidoExecutado(uint256 id, address destino, uint256 valorWei);// registra transferência final

    modifier soAprovador() {
        require(ehAprovador[msg.sender], "Apenas aprovador"); // Toda função com soAprovador só roda se msg.sender estiver marcado como aprovador.
        _; // O _ é o continua aqui(corpo da função).
    }

    constructor(address[] memory aprovadores_, uint256 quorum_) {
        require(aprovadores_.length > 0, "Sem aprovadores"); // Tem que existir pelo menos 1 aprovador, Quórum tem que ser >=1 e <= número de aprovadores
        require(quorum_ > 0 && quorum_ <= aprovadores_.length, "Quorum invalido"); // proibe endereço zero e aprovador repetido

        quorumMinimo = quorum_;

        for (uint256 i = 0; i < aprovadores_.length; i++) {
            address a = aprovadores_[i];
            require(a != address(0), "Aprovador zero");
            require(!ehAprovador[a], "Aprovador repetido");
            ehAprovador[a] = true;
        }
    }

    receive() external payable {} //Permite enviar ETH diretamente para o contrato (transfer/metamask).

    // CRIA PEDIDO - Função externa para criar um novo pedido de doação
    function criarPedido(address destino_, uint256 valorWei_, string memory descricao_) external soAprovador {
        // VALIDAÇÃO - impede que o endereço destino seja nulo (endereço zero)
        require(destino_ != address(0), "Destino invalido");
        // VALIDAÇÃO - garante que o valor da doação seja maior que zero
        require(valorWei_ > 0, "Valor zero");

        // ARMAZENAMENTO - cria e adiciona a estrutura do pedido ao array dinâmico ‘pedidos’
        pedidos.push(Pedido({
            destino: destino_, //cria e armazena no array
            valorWei: valorWei_,
            descricao: descricao_,
            aprovacoes: 0,
            executado: false
        }));

        // RASTREABILIDADE - captura o ID gerado e emite um evento para auditoria na rede
        uint256 id = pedidos.length - 1;
        emit PedidoCriado(id, msg.sender, destino_, valorWei_, descricao_);
    }

    // APROVA PEDIDO - Função externa para registrar a aprovação de um pedido
    function aprovarPedido(uint256 id) external soAprovador {
        // VALIDAÇÃO - verifica se o ID informado existe no histórico do contrato
        require(id < pedidos.length, "Pedido nao existe");

        // SEGURANÇA - impede a aprovação de um pedido que já foi liquidado financeiramente
        require(!pedidos[id].executado, "Ja executado");

        // REGRA DE INTEGRIDADE - impede que o mesmo endereço assine o pedido mais de uma vez
        require(!aprovou[id][msg.sender], "Ja aprovou");

        // REGISTRO - marca o endereço como ‘true’ para este ID específico
        aprovou[id][msg.sender] = true;

        // GOVERNANÇA - incrementa o contador de assinaturas para atingir o quórum mínimo
        pedidos[id].aprovacoes += 1;

        // RASTREABILIDADE: emite um evento capturando o aprovador e o total de assinaturas
        emit PedidoAprovado(id, msg.sender, pedidos[id].aprovacoes);
    }

    // Função externa para liquidar o pedido após atingir o “quórum”, regras, aprovacoes >= quorum e saldo do contrato suficiente
    function executarPedido(uint256 id) external soAprovador {
        // Validação - garante que o identificador (ID) informado é válido
        require(id < pedidos.length, "Pedido nao existe");
        // Referência - acessa os dados do pedido na memória permanente
        Pedido storage p = pedidos[id];

        // Segurança - trava de reentrada que impede que o pedido seja pago duas vezes
        require(!p.executado, "Ja executado");
        //Governança - verifica se o “quórum” mínimo de assinaturas foi atingido
        require(p.aprovacoes >= quorumMinimo, "Aprovacoes insuficientes");
        // Integridade financeira - garante que o contrato possui saldo para a transferência
        require(address(this).balance >= p.valorWei, "Saldo insuficiente no contrato");

        p.executado = true;
        // Transferência - realiza o envio de ETH para o endereço destino
        (bool ok, ) = payable(p.destino).call{value: p.valorWei}("");
        require(ok, "Falha ao transferir");

        // Rastreabilidade - emite um evento final confirmando a liquidação pública
        emit PedidoExecutado(id, p.destino, p.valorWei);
    }

    function totalPedidos() external view returns (uint256) {
        return pedidos.length;
    }

    // CONSULTA PEDIDO - Função externa de consulta que retorna os campos da estrutura Pedido
    function getPedido(uint256 id) 
        external
        view
        returns (address destino, uint256 valorWei, string memory descricao, uint256 aprovacoes, bool executado)
    {
        // VALIDAÇÃO: garante que o identificador (ID) solicitado existe no histórico do contrato
        require(id < pedidos.length, "Pedido nao existe");

         // LOCALIZAÇÃO: cria uma referência temporária para o pedido armazenado na 'blockchain' (storage)
        Pedido storage p = pedidos[id];

         // RETORNO: disponibiliza de forma estruturada os metadados para fins de auditor
        return (p.destino, p.valorWei, p.descricao, p.aprovacoes, p.executado);
    }
}

