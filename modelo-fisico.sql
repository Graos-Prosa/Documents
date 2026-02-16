CREATE TABLE IF NOT EXISTS usuario (
    id_usuario BIGINT GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(100) NOT NULL,
    sobrenome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    aniversario DATE,
    deletado_em TIMESTAMP,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario)
);

CREATE TABLE IF NOT EXISTS credencial (
    id_credencial BIGINT GENERATED ALWAYS AS IDENTITY,
    id_usuario BIGINT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    criado_em TIMESTAMP NOT NULL,
    CONSTRAINT pk_credencial PRIMARY KEY (id_credencial),
    CONSTRAINT fk_usuario_credencial FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS endereco (
    id_endereco BIGINT GENERATED ALWAYS AS IDENTITY,
    id_usuario BIGINT NOT NULL,
    logradouro VARCHAR(150) NOT NULL,
    numero INTEGER NOT NULL,
    complemento VARCHAR(100),
    referencia VARCHAR(100),
    bairro VARCHAR(50) NOT NULL,
    cep VARCHAR(8) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    pais VARCHAR(100) NOT NULL,
    CONSTRAINT pk_endereco PRIMARY KEY (id_endereco),
    CONSTRAINT fk_usuario_endereco FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS produto (
    id_produto BIGINT GENERATED ALWAYS AS IDENTITY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco NUMERIC(10,2) NOT NULL CHECK (preco >= 0),
    quantidade INTEGER NOT NULL CHECK (quantidade >= 0),
    CONSTRAINT pk_produto PRIMARY KEY (id_produto)
);

CREATE TABLE IF NOT EXISTS cupom (
    id_cupom BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo VARCHAR(100) NOT NULL UNIQUE,
    valor NUMERIC(10,2) NOT NULL CHECK (valor >= 0),
    tipo VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    CONSTRAINT pk_cupom PRIMARY KEY (id_cupom)
);

CREATE TABLE IF NOT EXISTS pedido (
    id_pedido BIGINT GENERATED ALWAYS AS IDENTITY,
    id_usuario BIGINT NOT NULL,
    id_cupom BIGINT,
    estado VARCHAR(50) NOT NULL,
    desconto NUMERIC(10,2),
    data_pedido TIMESTAMP NOT NULL,
    valor_total NUMERIC(10,2),
    valor_final NUMERIC(10,2) NOT NULL CHECK (valor_final >= 0),
    CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
    CONSTRAINT fk_usuario_pedido FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_cupom FOREIGN KEY (id_cupom) REFERENCES cupom(id_cupom)
);

CREATE TABLE IF NOT EXISTS item (
    id_item BIGINT GENERATED ALWAYS AS IDENTITY,
    id_produto BIGINT NOT NULL,
    id_pedido BIGINT NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade >= 0),
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT pk_item PRIMARY KEY (id_item),
    CONSTRAINT fk_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    CONSTRAINT fk_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE
);

-- anotações:

-- troquei SERIAL PRIMARY KEY POR GENERATED ALWAYS AS IDENTITY PRIMARY KEY
-- motivo: a partir do postgres 10, é mais seguro usar GAAIPK e evita conflitos de duplicidade
-- que ocorriam no SERIAL

-- utilizei varchar em campos que podem ter tamanho definido e TEXT para campos de textos longos

-- usei NUMERIC(10,2) pois para projetos que vão para produção é mais recomendado

-- utilizei BIGINT e não INTEGER por possibilidade de escalabilidade

-- depois de vasculhar a documentação aprendi que CONSTRAINT seria melhor para interpretar 
-- futuros erros

-- usei date no aniversario para guardar apenas o dia e timestamp em data do pedido para guardar horas também

-- Coloquei um 'deletado_em' em usuario. No front end eu 
-- pergunto se ele quer apagar permanentemente ou nao, se for permanentemente eu coloco
-- valores 'lixo' nos campos dos dados dele, se não eu apenas atualizo o atributo com a data
-- para possível retorno dele.

-- efeitos cascata:

-- Se o usuário for deletado, os endereços e as credenciais dele também são