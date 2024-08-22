# Desafio Técnico em PL/SQL

# Siga os passos abaixo para plena e correta execução do que foi pedido no desafio.

# 1. Criar as Tabelas e Sequências
   Primeiro, certifique-se de que as tabelas e as sequências necessárias estão criadas:

# 2. Criar o XML no formato CLOB
   Aqui está um exemplo de XML que representa um pedido. 
   Vamos criar o CLOB a partir desse XML:

```shell script
   DECLARE
     v_order_xml CLOB := '<Order>
       <CustomerName>John Doe</CustomerName>
       <OrderDate>2024-08-19</OrderDate>
         <Items>
           <Item>
              <ProductName>Product A</ProductName>
              <Quantity>2</Quantity>
              <Price>19.99</Price>
           </Item>
           <Item>
              <ProductName>Product B</ProductName>
              <Quantity>1</Quantity>
              <Price>9.99</Price>
           </Item>
       </Items>
     </Order>';
   BEGIN
   -- Processar o XML
   OrderPackage.ProcessOrderXML(v_order_xml);
   END;
   /
```

# 3. Consultar os Itens do Pedido
   Agora, para verificar se os itens foram inseridos corretamente, 
   você pode usar a função GetOrderItems para retornar os itens de um pedido específico.

```shell script
   DECLARE
     v_order_items SYS_REFCURSOR;
     v_product_name VARCHAR2(100);
     v_quantity NUMBER;
     v_price NUMBER;
   BEGIN

     -- Chamar a função GetOrderItems passando o OrderId
     v_order_items := OrderPackage.GetOrderItems(1);  -- Supondo que o OrderId é 1

     -- Loop para exibir os itens do pedido
     LOOP
       FETCH v_order_items INTO v_product_name, v_quantity, v_price;
       EXIT WHEN v_order_items%NOTFOUND;
       DBMS_OUTPUT.PUT_LINE('Produto: ' || v_product_name || ', Quantidade: ' || v_quantity || ', Preço: ' || v_price);
     END LOOP;

     -- Fechar o cursor
     CLOSE v_order_items;
   END;
   /
```

# 4. Verificar a Saída
   Após a execução dos comandos, você deverá ver a saída exibindo os itens do pedido processado:

   Produto: Product A, Quantidade: 2, Preço: 19.99
   Produto: Product B, Quantidade: 1, Preço: 9.99

# 5. Tratamento de Exceções
   Teste a inserção de um pedido com produtos duplicados para verificar o tratamento de exceções:

```shell script
   DECLARE
     v_order_xml CLOB := '<Order>
     <CustomerName>Jane Smith</CustomerName>
     <OrderDate>2024-08-20</OrderDate>
       <Items>
         <Item>
            <ProductName>Product C</ProductName>
               <Quantity>1</Quantity>
               <Price>15.00</Price>
         </Item>
         <Item>
           <ProductName>Product C</ProductName>
           <Quantity>1</Quantity>
           <Price>15.00</Price>
         </Item>
       </Items>
     </Order>';
   BEGIN
   -- Processar o XML com produto duplicado
   OrderPackage.ProcessOrderXML(v_order_xml);
   EXCEPTION
   WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(SQLERRM);  -- Espera-se um erro de produto duplicado
   END;
   /
```