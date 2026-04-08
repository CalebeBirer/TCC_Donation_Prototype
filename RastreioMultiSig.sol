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
    // CRIA PEDIDO
    function criarPedido(address destino_, uint256 valorWei_, string memory descricao_) external soAprovador {
        //VALIDACAO
        require(destino_ != address(0), "Destino invalido");
        require(valorWei_ > 0, "Valor zero");

        pedidos.push(Pedido({
            destino: destino_, //cria e armazena no array
            valorWei: valorWei_,
            descricao: descricao_,
            aprovacoes: 0,
            executado: false
        }));

        uint256 id = pedidos.length - 1;
        emit PedidoCriado(id, msg.sender, destino_, valorWei_, descricao_);
    }

    // APROVA PEDIDO
    function aprovarPedido(uint256 id) external soAprovador {
        require(id < pedidos.length, "Pedido nao existe");
        require(!pedidos[id].executado, "Ja executado");
        require(!aprovou[id][msg.sender], "Ja aprovou");

        aprovou[id][msg.sender] = true;
        pedidos[id].aprovacoes += 1;

        emit PedidoAprovado(id, msg.sender, pedidos[id].aprovacoes);
    }

    // regras, nao executado, aprovacoes >= quorum e saldo do contrato suficiente
    function executarPedido(uint256 id) external soAprovador {
        require(id < pedidos.length, "Pedido nao existe");
        Pedido storage p = pedidos[id];

        require(!p.executado, "Ja executado");
        require(p.aprovacoes >= quorumMinimo, "Aprovacoes insuficientes");
        require(address(this).balance >= p.valorWei, "Saldo insuficiente no contrato");

        p.executado = true;
        (bool ok, ) = payable(p.destino).call{value: p.valorWei}("");
        require(ok, "Falha ao transferir");

        emit PedidoExecutado(id, p.destino, p.valorWei);
    }

    function totalPedidos() external view returns (uint256) {
        return pedidos.length;
    }

    // valida ID e retorna os campos do struct
    function getPedido(uint256 id) 
        external
        view
        returns (address destino, uint256 valorWei, string memory descricao, uint256 aprovacoes, bool executado)
    {
        require(id < pedidos.length, "Pedido nao existe");
        Pedido storage p = pedidos[id];
        return (p.destino, p.valorWei, p.descricao, p.aprovacoes, p.executado);
    }
}

